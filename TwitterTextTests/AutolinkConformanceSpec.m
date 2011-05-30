//
//  AutolinkConformanceSpec.m
//  TwitterText
//
//  Created by Sixten Otto on 5/18/11.
//  Copyright 2011 Sixten Otto. All rights reserved.
//

#import "Kiwi.h"

#import "CGYAML.h"

#import "TWAutolink.h"


SPEC_BEGIN(AutolinkConformanceSpec)

describe(@"TWAutolink", ^{

  __block NSDictionary* tests = nil;
  __block TWAutolink* autolink = nil;
  
  beforeAll(^{
    NSString* path = [[NSBundle bundleWithIdentifier:@"com.twitter.TwitterTextTests"] pathForResource:@"autolink" ofType:@"yml"];
    CGYAML *yaml = [[CGYAML alloc] initWithPath:path];
    NSDictionary* doc = [[yaml documents] lastObject];
    tests = [[doc objectForKey:@"tests"] retain];
    [yaml release];
  });
  
  beforeEach(^{
    autolink = [[TWAutolink alloc] init];
    autolink.noFollow = NO;
  });
  
  afterEach(^{
    [autolink release];
  });
  
  afterAll(^{
    [tests release];
  });
  
  
  context(@"autolinking", ^{
    it(@"should work with usernames", ^{
      for( NSDictionary* test in [tests objectForKey:@"usernames"] ) {
        id result = [autolink autoLinkUsernamesAndLists:[test objectForKey:@"text"]];
        
        [result shouldNotBeNil];
        [[result should] equal:[test objectForKey:@"expected"]];
      }
    });
    
    it(@"should work with lists", ^{
      for( NSDictionary* test in [tests objectForKey:@"lists"] ) {
        id result = [autolink autoLinkUsernamesAndLists:[test objectForKey:@"text"]];
        
        [result shouldNotBeNil];
        [[result should] equal:[test objectForKey:@"expected"]];
      }
    });
    
    it(@"should work with hashtags", ^{
      for( NSDictionary* test in [tests objectForKey:@"hashtags"] ) {
        id result = [autolink autoLinkHashtags:[test objectForKey:@"text"]];
        
        [result shouldNotBeNil];
        [[result should] equal:[test objectForKey:@"expected"]];
      }
    });
    
    it(@"should work with urls", ^{
      for( NSDictionary* test in [tests objectForKey:@"urls"] ) {
        id result = [autolink autoLinkURLs:[test objectForKey:@"text"]];
        
        [result shouldNotBeNil];
        [[result should] equal:[test objectForKey:@"expected"]];
      }
    });
    
    it(@"should work with everything all at once", ^{
      for( NSDictionary* test in [tests objectForKey:@"all"] ) {
        NSLog(@"Auto-link tweet: »%@«", [test objectForKey:@"text"]);
        id result = [autolink autoLink:[test objectForKey:@"text"]];
        
        [result shouldNotBeNil];
        [[result should] equal:[test objectForKey:@"expected"]];
      }
    });
  });

});

SPEC_END
