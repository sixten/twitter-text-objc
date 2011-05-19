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
    tests = [[[yaml documents] lastObject] retain];
    [yaml release];
  });
  
  beforeEach(^{
    autolink = [[TWAutolink alloc] init];
  });
  
  afterEach(^{
    [autolink release];
  });
  
  afterAll(^{
    [tests release];
  });

  
  it(@"should do something", ^{
    // perform the test
  });

});

SPEC_END
