//
//  ExtractorConformanceSpec.m
//  TwitterText
//
//  Created by Sixten Otto on 5/17/11.
//  Copyright 2011 Sixten Otto. All rights reserved.
//

#import "Kiwi.h"

#import "CGYAML.h"

#import "TWExtractor.h"
#import "TWEntity.h"


SPEC_BEGIN(ExtractorConformanceSpec)

describe(@"TWExtractor", ^{
  
  __block NSDictionary* tests = nil;
  __block TWExtractor* extractor = nil;
  
  beforeAll(^{
    NSString* path = [[NSBundle bundleWithIdentifier:@"com.twitter.TwitterTextTests"] pathForResource:@"extract" ofType:@"yml"];
    CGYAML *yaml = [[CGYAML alloc] initWithPath:path];
    tests = [[[yaml documents] lastObject] retain];
    [yaml release];
  });
  
  beforeEach(^{
    extractor = [[TWExtractor alloc] init];
  });
  
  afterEach(^{
    [extractor release];
  });
  
  afterAll(^{
    [tests release];
  });
  
  
  NSRange (^rangeFromExpectedIndices)(NSDictionary*) = ^( NSDictionary* expectedResults ){
    NSArray* indices = [expectedResults objectForKey:@"indices"];
    NSRange r = NSMakeRange([[indices objectAtIndex:0] integerValue], [[indices objectAtIndex:1] integerValue]);
    r.length -= r.location;
    return r;
  };
  
  
  context(@"mentions", ^{
    it(@"should extract strings", ^{
      for( NSDictionary* test in [tests objectForKey:@"mentions"] ) {
        id result = [extractor extractMentionedScreennames:[test objectForKey:@"text"]];
        
        [result shouldNotBeNil];
        [[result should] beKindOfClass:[NSArray class]];
        [[result should] equal:[tests objectForKey:@"expected"]];
      }
    });
    
    it(@"should extract strings with indices", ^{
      for( NSDictionary* test in [tests objectForKey:@"mentions_with_indices"] ) {
        id result = [extractor extractMentionedScreennamesWithIndices:[test objectForKey:@"text"]];
        
        NSArray* expected = [tests objectForKey:@"expected"];
        
        [result shouldNotBeNil];
        [[result should] beKindOfClass:[NSArray class]];
        [[result should] haveCountOf:[expected count]];
        
        for( NSUInteger i=0; i < [expected count]; i++ ) {
          NSDictionary* expect = [expected objectAtIndex:i];
          TWEntity* ent = [result objectAtIndex:i];
          //NSLog(@"test %@ against %@", ent, expect);
          [[ent.value should] equal:[expect objectForKey:@"screen_name"]];
          [[theValue(ent.rangeInText) should] equal:theValue(rangeFromExpectedIndices(expect))];
          [[theValue(ent.type) should] equal:theValue(TWEntityTypeMention)];
        }
      }
    });
  });
  
  
  context(@"replies", ^{
    it(@"should extract usernames", ^{
      for( NSDictionary* test in [tests objectForKey:@"replies"] ) {
        id result = [extractor extractReplyScreenname:[test objectForKey:@"text"]];
        
        NSString* expected = [tests objectForKey:@"expected"];
        
        if( expected == nil || (id)expected == [NSNull null] ) {
          [result shouldBeNil];
        }
        else {
          [result shouldNotBeNil];
          [[result should] equal:expected];
        }
      }
    });
  });
  
  
  context(@"urls", ^{
    it(@"should extract strings", ^{
      for( NSDictionary* test in [tests objectForKey:@"urls"] ) {
        id result = [extractor extractURLs:[test objectForKey:@"text"]];
        
        [result shouldNotBeNil];
        [[result should] beKindOfClass:[NSArray class]];
        [[result should] equal:[tests objectForKey:@"expected"]];
      }
    });
    
    it(@"should extract strings with indices", ^{
      for( NSDictionary* test in [tests objectForKey:@"urls_with_indices"] ) {
        id result = [extractor extractURLsWithIndices:[test objectForKey:@"text"]];
        
        NSArray* expected = [tests objectForKey:@"expected"];
        
        [result shouldNotBeNil];
        [[result should] beKindOfClass:[NSArray class]];
        [[result should] haveCountOf:[expected count]];
        
        for( NSUInteger i=0; i < [expected count]; i++ ) {
          NSDictionary* expect = [expected objectAtIndex:i];
          TWEntity* ent = [result objectAtIndex:i];
          //NSLog(@"test %@ against %@", ent, expect);
          [[ent.value should] equal:[expect objectForKey:@"url"]];
          [[theValue(ent.rangeInText) should] equal:theValue(rangeFromExpectedIndices(expect))];
          [[theValue(ent.type) should] equal:theValue(TWEntityTypeMention)];
        }
      }
    });
  });
  
  
  context(@"hashtags", ^{
    it(@"should extract strings", ^{
      for( NSDictionary* test in [tests objectForKey:@"hashtags"] ) {
        id result = [extractor extractHashtags:[test objectForKey:@"text"]];
        
        [result shouldNotBeNil];
        [[result should] beKindOfClass:[NSArray class]];
        [[result should] equal:[tests objectForKey:@"expected"]];
      }
    });
    
    it(@"should extract strings with indices", ^{
      for( NSDictionary* test in [tests objectForKey:@"hashtags_with_indices"] ) {
        id result = [extractor extractHashtagsWithIndices:[test objectForKey:@"text"]];
        
        NSArray* expected = [tests objectForKey:@"expected"];
        
        [result shouldNotBeNil];
        [[result should] beKindOfClass:[NSArray class]];
        [[result should] haveCountOf:[expected count]];
        
        for( NSUInteger i=0; i < [expected count]; i++ ) {
          NSDictionary* expect = [expected objectAtIndex:i];
          TWEntity* ent = [result objectAtIndex:i];
          //NSLog(@"test %@ against %@", ent, expect);
          [[ent.value should] equal:[expect objectForKey:@"hashtag"]];
          [[theValue(ent.rangeInText) should] equal:theValue(rangeFromExpectedIndices(expect))];
          [[theValue(ent.type) should] equal:theValue(TWEntityTypeMention)];
        }
      }
    });
  });

});

SPEC_END
