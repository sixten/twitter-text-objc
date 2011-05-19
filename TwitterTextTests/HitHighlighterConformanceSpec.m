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
    tests = [[[yaml documents] lastObject] retain];
    [yaml release];
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

  
  it(@"should do something", ^{
    // perform the test
  });

});

SPEC_END
