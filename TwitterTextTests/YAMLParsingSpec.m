//
//  YAMLParsingSpec.m
//  TwitterText
//
//  Created by Sixten Otto on 5/14/11.
//  Copyright 2011 Sixten Otto. All rights reserved.
//

#import "Kiwi.h"

#import "CGYAML.h"


SPEC_BEGIN(YAMLParsingSpec)

describe(@"this test target", ^{
  
  __block NSDictionary* tests = nil;

  beforeAll(^{
    NSString* path = [[NSBundle bundleWithIdentifier:@"com.twitter.TwitterTextTests"] pathForResource:@"extract" ofType:@"yml"];
    CGYAML *yaml = [[CGYAML alloc] initWithPath:path];
    tests = [[[yaml documents] lastObject] retain];
    [yaml release];
  });
  
  afterAll(^{
    [tests release];
  });
  
  it(@"should find some test data", ^{
    [tests shouldNotBeNil];
    [[tests objectForKey:@"tests"] shouldNotBeNil];
    [[[tests objectForKey:@"tests"] shouldNot] beEmpty];
  });

});

SPEC_END
