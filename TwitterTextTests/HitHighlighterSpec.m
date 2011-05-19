//
//  HitHighlighterSpec.m
//  TwitterText
//
//  Created by Sixten Otto on 5/18/11.
//  Copyright 2011 Sixten Otto. All rights reserved.
//

#import "Kiwi.h"

#import "TWHitHighlighter.h"


SPEC_BEGIN(HitHighlighterSpec)

describe(@"TWHitHighlighter", ^{

  __block TWHitHighlighter* highlighter = nil;
  
  beforeEach(^{
    highlighter = [[TWHitHighlighter alloc] init];
  });
  
  afterEach(^{
    [highlighter release];
  });
  
  
  it(@"should do something", ^{
    // perform the test
  });

});

SPEC_END
