//
//  AutolinkSpec.m
//  TwitterText
//
//  Created by Sixten Otto on 5/18/11.
//  Copyright 2011 Sixten Otto. All rights reserved.
//

#import "Kiwi.h"

#import "TWAutolink.h"


SPEC_BEGIN(AutolinkSpec)

describe(@"TWAutolink", ^{

  __block TWAutolink* autolink = nil;
  
  beforeEach(^{
    autolink = [[TWAutolink alloc] init];
  });
  
  afterEach(^{
    [autolink release];
  });
  
  
  it(@"should do something", ^{
    // perform the test
  });

});

SPEC_END
