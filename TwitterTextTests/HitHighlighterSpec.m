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
  
  
  context(@"with options", ^{
    __block NSString* original = nil;
    __block NSArray* hits = nil;
    
    beforeEach(^{
      original = @"Testing this hit highliter";
      hits = [NSArray arrayWithObject:[NSValue valueWithRange:NSMakeRange(13, 3)]];
    });
    
    it(@"should default to <em> tags", ^{
      id result = [highlighter highlightHits:hits inText:original];
      
      [result shouldNotBeNil];
      [[result should] equal:@"Testing this <em>hit</em> highliter"];
    });
    
    it(@"should allow tag override", ^{
      highlighter.tag = @"b";
      id result = [highlighter highlightHits:hits inText:original];
      
      [result shouldNotBeNil];
      [[result should] equal:@"Testing this <b>hit</b> highliter"];
    });
  });
  
  context(@"without links", ^{
    __block NSString* original = nil;
    
    beforeEach(^{
      original = @"Hey! this is a test tweet";
    });
    
    it(@"should return original when no hits are provided", ^{
      id result = [highlighter highlightHits:nil inText:original];
      
      [result shouldNotBeNil];
      [[result should] equal:original];
    });
    
    it(@"should highlight one hit", ^{
      NSArray* hits = [NSArray arrayWithObject:[NSValue valueWithRange:NSMakeRange(5, 4)]];
      id result = [highlighter highlightHits:hits inText:original];
      
      [result shouldNotBeNil];
      [[result should] equal:@"Hey! <em>this</em> is a test tweet"];
    });
    
    it(@"should highlight two hits", ^{
      NSArray* hits = [NSArray arrayWithObjects:
                       [NSValue valueWithRange:NSMakeRange(5, 4)],
                       [NSValue valueWithRange:NSMakeRange(15, 4)],
                       nil];
      id result = [highlighter highlightHits:hits inText:original];
      
      [result shouldNotBeNil];
      [[result should] equal:@"Hey! <em>this</em> is a <em>test</em> tweet"];
    });
    
    it(@"should correctly highlight first-word hits", ^{
      NSArray* hits = [NSArray arrayWithObject:[NSValue valueWithRange:NSMakeRange(0, 3)]];
      id result = [highlighter highlightHits:hits inText:original];
      
      [result shouldNotBeNil];
      [[result should] equal:@"<em>Hey</em>! this is a test tweet"];
    });
    
    it(@"should correctly highlight last-word hits", ^{
      NSArray* hits = [NSArray arrayWithObject:[NSValue valueWithRange:NSMakeRange(20, 5)]];
      id result = [highlighter highlightHits:hits inText:original];
      
      [result shouldNotBeNil];
      [[result should] equal:@"Hey! this is a test <em>tweet</em>"];
    });
  });
  
  context(@"with links", ^{
    it(@"should highlight with a single link", ^{
      NSArray* hits = [NSArray arrayWithObject:[NSValue valueWithRange:NSMakeRange(9, 4)]];
      id result = [highlighter highlightHits:hits inText:@"@<a>bcherry</a> this was a test tweet"];
      
      [result shouldNotBeNil];
      [[result should] equal:@"@<a>bcherry</a> <em>this</em> was a test tweet"];
    });
    
    it(@"should highlight with link at the end", ^{
      NSArray* hits = [NSArray arrayWithObject:[NSValue valueWithRange:NSMakeRange(5, 4)]];
      id result = [highlighter highlightHits:hits inText:@"test test <a>test</a>"];
      
      [result shouldNotBeNil];
      [[result should] equal:@"test <em>test</em> <a>test</a>"];
    });
    
    it(@"should highlight with a link at the beginning", ^{
      NSArray* hits = [NSArray arrayWithObject:[NSValue valueWithRange:NSMakeRange(5, 4)]];
      id result = [highlighter highlightHits:hits inText:@"<a>test</a> test test"];
      
      [result shouldNotBeNil];
      [[result should] equal:@"<a>test</a> <em>test</em> test"];
    });
    
    it(@"should highlight an entire link", ^{
      NSArray* hits = [NSArray arrayWithObject:[NSValue valueWithRange:NSMakeRange(5, 4)]];
      id result = [highlighter highlightHits:hits inText:@"test <a>test</a> test"];
      
      [result shouldNotBeNil];
      [[result should] equal:@"test <a><em>test</em></a> test"];
    });
    
    it(@"should highlight within a link", ^{
      NSArray* hits = [NSArray arrayWithObject:[NSValue valueWithRange:NSMakeRange(6, 2)]];
      id result = [highlighter highlightHits:hits inText:@"test <a>test</a> test"];
      
      [result shouldNotBeNil];
      [[result should] equal:@"test <a>t<em>es</em>t</a> test"];
    });
    
    it(@"should highlight around a link", ^{
      NSArray* hits = [NSArray arrayWithObject:[NSValue valueWithRange:NSMakeRange(3, 8)]];
      id result = [highlighter highlightHits:hits inText:@"test <a>test</a> test"];
      
      [result shouldNotBeNil];
      [[result should] equal:@"tes<em>t <a>test</a> t</em>est"];
    });
    
    it(@"should highlight an entire link at the end", ^{
      NSArray* hits = [NSArray arrayWithObject:[NSValue valueWithRange:NSMakeRange(10, 4)]];
      id result = [highlighter highlightHits:hits inText:@"test test <a>test</a>"];
      
      [result shouldNotBeNil];
      [[result should] equal:@"test test <a><em>test</em></a>"];
    });
    
    it(@"should fail gracefully with bad hits", ^{
      NSArray* hits = [NSArray arrayWithObject:[NSValue valueWithRange:NSMakeRange(5, 15)]];
      id result = [highlighter highlightHits:hits inText:@"test test"];
      
      [result shouldNotBeNil];
      [[result should] equal:@"test <em>test</em>"];
    });
    
    it(@"should not mess up with touching tags", ^{
      NSArray* hits = [NSArray arrayWithObject:[NSValue valueWithRange:NSMakeRange(3, 3)]];
      id result = [highlighter highlightHits:hits inText:@"<a>foo</a><a>foo</a>"];
      
      [result shouldNotBeNil];
      [[result should] equal:@"<a>foo</a><a><em>foo</em></a>"];
    });
  });

});

SPEC_END
