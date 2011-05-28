//
//  HitHighlighterConformanceSpec.m
//  TwitterText
//
//  Created by Sixten Otto on 5/18/11.
//  Copyright 2011 Sixten Otto. All rights reserved.
//

#import "Kiwi.h"

#import "CGYAML.h"

#import "TWHitHighlighter.h"


SPEC_BEGIN(HitHighlighterConformanceSpec)

describe(@"TWHitHighlighter", ^{

  __block NSDictionary* tests = nil;
  __block TWHitHighlighter* highlighter = nil;
  
  beforeAll(^{
    NSString* path = [[NSBundle bundleWithIdentifier:@"com.twitter.TwitterTextTests"] pathForResource:@"hit_highlighting" ofType:@"yml"];
    CGYAML *yaml = [[CGYAML alloc] initWithPath:path];
    NSDictionary* doc = [[yaml documents] lastObject];
    tests = [[doc objectForKey:@"tests"] retain];
    [yaml release];
    assert(tests != nil);
  });
  
  beforeEach(^{
    highlighter = [[TWHitHighlighter alloc] init];
  });
  
  afterEach(^{
    [highlighter release];
  });
  
  afterAll(^{
    [tests release];
  });
  
  
  NSRange (^rangeFromExpectedIndices)(NSArray*) = ^( NSArray* indices ){
    NSRange r = NSMakeRange([[indices objectAtIndex:0] integerValue], [[indices objectAtIndex:1] integerValue]);
    r.length -= r.location;
    return r;
  };
  
  
  NSArray* (^rangesFromArrayOfExpectedIndices)(NSDictionary*) = ^( NSDictionary* expectedResults ){
    NSArray* indices = [expectedResults objectForKey:@"hits"];
    NSMutableArray* ranges = [NSMutableArray arrayWithCapacity:[indices count]];
    for( NSArray* index in indices ) {
      [ranges addObject:[NSValue valueWithRange:rangeFromExpectedIndices(index)]];
    }
    return ranges;
  };

  
  context(@"highlighting", ^{
    it(@"should work on plain text", ^{
      for( NSDictionary* test in [tests objectForKey:@"plain_text"] ) {
        NSArray* hits = rangesFromArrayOfExpectedIndices(test);
        id result = [highlighter highlightHits:hits inText:[test objectForKey:@"text"]];
        
        [result shouldNotBeNil];
        [[result should] equal:[test objectForKey:@"expected"]];
      }
    });
    
    it(@"should work on strings with links", ^{
      for( NSDictionary* test in [tests objectForKey:@"with_links"] ) {
        NSArray* hits = rangesFromArrayOfExpectedIndices(test);
        id result = [highlighter highlightHits:hits inText:[test objectForKey:@"text"]];
        
        [result shouldNotBeNil];
        [[result should] equal:[test objectForKey:@"expected"]];
      }
    });
  });

});

SPEC_END
