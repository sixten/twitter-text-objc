//
//  ExtractorSpec.m
//  TwitterText
//
//  Created by Sixten Otto on 5/14/11.
//  Copyright 2011 Sixten Otto. All rights reserved.
//

#import "Kiwi.h"

#import "TWExtractor.h"


SPEC_BEGIN(ExtractorSpec)

describe(@"TWExtractor", ^{
  
  __block TWExtractor* extractor = nil;
  
  beforeEach(^{
    extractor = [[TWExtractor alloc] init];
  });
  
  afterEach(^{
    [extractor release];
  });
  
  
  describe(@"mentions", ^{
  
  });
  
  
  describe(@"mentions with indices", ^{
  
  });
  
  
  describe(@"replies", ^{
  
  });
  
  
  describe(@"urls", ^{
  
  });
  
  
  describe(@"urls with indices", ^{
  
  });
  
  
  describe(@"hashtags", ^{
  
  });
  
  
  describe(@"hashtags with indices", ^{
  
  });

});

SPEC_END
