//
//  ExtractorSpec.m
//  TwitterText
//
//  Created by Sixten Otto on 5/14/11.
//  Copyright 2011 Sixten Otto. All rights reserved.
//

#import "Kiwi.h"

#import "TWExtractor.h"
#import "TWEntity.h"


SPEC_BEGIN(ExtractorSpec)

describe(@"TWExtractor", ^{
  
  __block NSDictionary* urls = nil;
  __block TWExtractor* extractor = nil;
  
  beforeAll(^{
    NSString* path = [[NSBundle bundleWithIdentifier:@"com.twitter.TwitterTextTests"] pathForResource:@"TestURLs" ofType:@"plist"];
    urls = [[NSDictionary dictionaryWithContentsOfFile:path] retain];
  });
  
  beforeEach(^{
    extractor = [[TWExtractor alloc] init];
  });
  
  afterEach(^{
    [extractor release];
  });
  
  afterAll(^{
    [urls release];
  });
  
  
  describe(@"mentions", ^{
    context(@"single screen name alone", ^{
      it(@"should be linked", ^{
        id result = [extractor extractMentionedScreennames:@"@alice"];
        
        [result shouldNotBeNil];
        [[result should] beKindOfClass:[NSArray class]];
        [[result should] haveCountOf:1];
        [[result should] contain:@"alice"];
      });

      it(@"should be linked with _", ^{
        id result = [extractor extractMentionedScreennames:@"@alice_adams"];
        
        [result shouldNotBeNil];
        [[result should] beKindOfClass:[NSArray class]];
        [[result should] haveCountOf:1];
        [[result should] contain:@"alice_adams"];
      });

      it(@"should be linked if numeric", ^{
        id result = [extractor extractMentionedScreennames:@"@1234"];
        
        [result shouldNotBeNil];
        [[result should] beKindOfClass:[NSArray class]];
        [[result should] haveCountOf:1];
        [[result should] contain:@"1234"];
      });
    });

    context(@"multiple screen names", ^{
      it(@"should both be linked", ^{
        id result = [extractor extractMentionedScreennames:@"@alice @bob"];
        
        [result shouldNotBeNil];
        [[result should] beKindOfClass:[NSArray class]];
        [[result should] haveCountOf:2];
        [[result should] containObjects:@"alice", @"bob", nil];
      });
    });

    context(@"screen names embedded in text", ^{
      it(@"should be linked in Latin text", ^{
        id result = [extractor extractMentionedScreennames:@"waiting for @alice to arrive"];
        
        [result shouldNotBeNil];
        [[result should] beKindOfClass:[NSArray class]];
        [[result should] haveCountOf:1];
        [[result should] contain:@"alice"];
      });
      
      it(@"should be linked in Japanese text", ^{
        id result = [extractor extractMentionedScreennames:@"の@aliceに到着を待っている"];
        
        [result shouldNotBeNil];
        [[result should] beKindOfClass:[NSArray class]];
        [[result should] haveCountOf:1];
        [[result should] contain:@"alice"];
      });
      
      pending(@"should accept a block argument and call it in order", ^{
        // support for iOS 4+/blocks TBD
      });
    });
  });
  
  describe(@"mentions with indices", ^{
    void (^matchMentionsInText)(NSString*,NSArray*) = ^( NSString* text, NSArray* matches ){
      id result = [extractor extractMentionedScreennamesWithIndices:text];
      NSLog(@"Attempted to extract mentions from «%@»:\n  expected %@\n  got %@", text, matches, result);
      
      [result shouldNotBeNil];
      [[result should] beKindOfClass:[NSArray class]];
      [[result should] haveCountOf:[matches count]];
      [[result should] equal:matches];
    };
    
    context(@"single screen name alone", ^{
      it(@"should be linked", ^{
        matchMentionsInText(@"@alice",
                            [NSArray arrayWithObject:
                             [TWEntity entityWithValue:@"alice" rangeInText:NSMakeRange(0, 6) type:TWEntityTypeMention]
                             ]);
      });
      
      it(@"should be linked with _", ^{
        matchMentionsInText(@"@alice_adams",
                            [NSArray arrayWithObject:
                             [TWEntity entityWithValue:@"alice_adams" rangeInText:NSMakeRange(0, 12) type:TWEntityTypeMention]
                             ]);
      });
      
      it(@"should be linked if numeric", ^{
        matchMentionsInText(@"@1234",
                            [NSArray arrayWithObject:
                             [TWEntity entityWithValue:@"1234" rangeInText:NSMakeRange(0, 5) type:TWEntityTypeMention]
                             ]);
      });
    });
    
    context(@"multiple screen names", ^{
      it(@"should both be linked with the correct indices", ^{
        matchMentionsInText(@"@alice @bob",
                            [NSArray arrayWithObjects:
                             [TWEntity entityWithValue:@"alice" rangeInText:NSMakeRange(0, 6) type:TWEntityTypeMention],
                             [TWEntity entityWithValue:@"bob" rangeInText:NSMakeRange(7, 4) type:TWEntityTypeMention],
                             nil]);
      });
      
      it(@"should be linked with the correct indices even when repeated", ^{
        matchMentionsInText(@"@alice @alice @bob",
                            [NSArray arrayWithObjects:
                             [TWEntity entityWithValue:@"alice" rangeInText:NSMakeRange(0, 6) type:TWEntityTypeMention],
                             [TWEntity entityWithValue:@"alice" rangeInText:NSMakeRange(7, 6) type:TWEntityTypeMention],
                             [TWEntity entityWithValue:@"bob" rangeInText:NSMakeRange(14, 4) type:TWEntityTypeMention],
                             nil]);
      });
    });
    
    context(@"screen names embedded in text", ^{
      it(@"should be linked in Latin text with the correct indices", ^{
        matchMentionsInText(@"waiting for @alice to arrive",
                            [NSArray arrayWithObject:
                             [TWEntity entityWithValue:@"alice" rangeInText:NSMakeRange(12, 6) type:TWEntityTypeMention]
                             ]);
      });
      
      it(@"should be linked in Japanese text with the correct indices", ^{
        matchMentionsInText(@"の@aliceに到着を待っている",
                            [NSArray arrayWithObject:
                             [TWEntity entityWithValue:@"alice" rangeInText:NSMakeRange(1, 6) type:TWEntityTypeMention]
                             ]);
      });
    });

    pending(@"should accept a block argument and call it in order", ^{
      // support for iOS 4+/blocks TBD
    });
  });
  
  
  describe(@"replies", ^{
    context(@"should be extracted from", ^{
      it(@"should extract from lone name", ^{
        id result = [extractor extractReplyScreenname:@"@alice"];
        
        [result shouldNotBeNil];
        [[result should] beKindOfClass:[NSString class]];
        [[result should] equal:@"alice"];
      });
      
      it(@"should extract from the start", ^{
        id result = [extractor extractReplyScreenname:@"@alice reply text"];
        
        [result shouldNotBeNil];
        [[result should] beKindOfClass:[NSString class]];
        [[result should] equal:@"alice"];
      });
      
      it(@"should extract preceded by a space", ^{
        id result = [extractor extractReplyScreenname:@" @alice reply text"];
        
        [result shouldNotBeNil];
        [[result should] beKindOfClass:[NSString class]];
        [[result should] equal:@"alice"];
      });
      
      it(@"should extract preceded by a full-width space", ^{
        id result = [extractor extractReplyScreenname:@"\u3000@alice reply text"];
        
        [result shouldNotBeNil];
        [[result should] beKindOfClass:[NSString class]];
        [[result should] equal:@"alice"];
      });
    });
    
    context(@"should not be extracted from", ^{
      it(@"should not be extracted when preceded by text", ^{
        id result = [extractor extractReplyScreenname:@"reply @alice text"];
        
        [result shouldBeNil];
      });
      
      it(@"should not be extracted when preceded by puctuation", ^{
        for( NSString* punct in [NSArray arrayWithObjects:@".", @"/", @"_", @"-", @"+", @"#", @"!", @"@", nil] ) {
          NSString* text = [NSString stringWithFormat:@"%@@alice text", punct];
          id result = [extractor extractReplyScreenname:text];
          
          [result shouldBeNil];
        }
      });
    });
    
    context(@"should accept a block arugment", ^{
      pending(@"should call the block on match", ^{
        // support for iOS 4+/blocks TBD
      });
      
      pending(@"should not call the block on no match", ^{
        // support for iOS 4+/blocks TBD
      });
    });
  });
  
  
  describe(@"urls", ^{
    context(@"matching URLS", ^{
      //NSLog(@"test with valid URLs %@", [urls objectForKey:@"VALID"]);

      it(@"should extract bare URLs", ^{
        for( NSString* url in [urls objectForKey:@"VALID"] ) {
          id result = [extractor extractURLs:url];
          
          [result shouldNotBeNil];
          [[result should] beKindOfClass:[NSArray class]];
          [[result should] haveCountOf:1];
          [[result should] contain:url];
        }
      });
      
      it(@"should match URLs when they're embedded in other text", ^{
        for( NSString* url in [urls objectForKey:@"VALID"] ) {
          NSString* text = [NSString stringWithFormat:@"Sweet url: %@ I found. #awesome", url];
          id result = [extractor extractURLs:text];
          
          [result shouldNotBeNil];
          [[result should] beKindOfClass:[NSArray class]];
          [[result should] haveCountOf:1];
          [[result should] contain:url];
        }
      });
    });
    
    context(@"invalid URLS", ^{
      it(@"does not link urls with invalid domains", ^{
        id result = [extractor extractURLs:@"http://tld-too-short.x"];
        
        [result shouldNotBeNil];
        [[result should] beKindOfClass:[NSArray class]];
        [[result should] beEmpty];
      });
    });
  });
  
  
  describe(@"urls with indices", ^{
    void (^matchURLInText)(NSString*,NSString*,NSUInteger) = ^( NSString* url, NSString* text, NSUInteger offset ){
      TWEntity* target   = [[TWEntity alloc] initWithValue:url rangeInText:NSMakeRange(offset, [url length]) type:TWEntityTypeURL];
      
      id result = [extractor extractURLsWithIndices:text];
      //NSLog(@"Attempted to extract «%@» from «%@»: %@", url, text, result);
      
      [result shouldNotBeNil];
      [[result should] beKindOfClass:[NSArray class]];
      [[result should] haveCountOf:1];
      
      id match = [result lastObject];
      [[match should] equal:target];
      
      [target release];
    };
    
    context(@"matching URLS", ^{
      //NSLog(@"test with valid URLs %@", [urls objectForKey:@"VALID"]);
      
      it(@"should extract bare URLs", ^{
        for( NSString* url in [urls objectForKey:@"VALID"] ) {
          matchURLInText(url, url, 0);
        }
      });
      
      it(@"should match URLs when they're embedded in other text", ^{
        for( NSString* url in [urls objectForKey:@"VALID"] ) {
          NSString* text = [NSString stringWithFormat:@"Sweet url: %@ I found. #awesome", url];
          matchURLInText(url, text, 11);
        }
      });
    });
    
    context(@"invalid URLS", ^{
      it(@"does not link urls with invalid domains", ^{
        id result = [extractor extractURLsWithIndices:@"http://tld-too-short.x"];
        
        [result shouldNotBeNil];
        [[result should] beKindOfClass:[NSArray class]];
        [[result should] beEmpty];
      });
    });
  });
  
  
  describe(@"hashtags", ^{
    context(@"extracts latin/numeric hashtags", ^{
      NSArray* tests = [NSArray arrayWithObjects:@"text", @"text123", @"123text", nil];
      
      it(@"should extract bare hashtags", ^{
        for( NSString* hashtag in tests ) {
          NSString* text = [@"#" stringByAppendingString:hashtag];
          id result = [extractor extractHashtags:text];
          //NSLog(@"Attempted to extract «%@» from «%@»: %@", hashtag, text, result);
          
          [result shouldNotBeNil];
          [[result should] beKindOfClass:[NSArray class]];
          [[result should] haveCountOf:1];
          [[result should] contain:hashtag];
        }
      });
      
      it(@"should extract hashtags within text", ^{
        for( NSString* hashtag in tests ) {
          NSString* text = [NSString stringWithFormat:@"pre-text #%@ post-text", hashtag];
          id result = [extractor extractHashtags:text];
          //NSLog(@"Attempted to extract «%@» from «%@»: %@", hashtag, text, result);
          
          [result shouldNotBeNil];
          [[result should] beKindOfClass:[NSArray class]];
          [[result should] haveCountOf:1];
          [[result should] contain:hashtag];
        }
      });
    });
    
    context(@"international hashtags", ^{
      context(@"should allow accents", ^{
        NSArray* tests = [NSArray arrayWithObjects:@"mañana", @"café", @"münchen", nil];
        
        it(@"should extract bare hashtags", ^{
          for( NSString* hashtag in tests ) {
            id result = [extractor extractHashtags:[@"#" stringByAppendingString:hashtag]];
            
            [result shouldNotBeNil];
            [[result should] beKindOfClass:[NSArray class]];
            [[result should] haveCountOf:1];
            [[result should] contain:hashtag];
          }
        });
        
        it(@"should extract hashtags within text", ^{
          for( NSString* hashtag in tests ) {
            id result = [extractor extractHashtags:[NSString stringWithFormat:@"pre-text #%@ post-text", hashtag]];
            
            [result shouldNotBeNil];
            [[result should] beKindOfClass:[NSArray class]];
            [[result should] haveCountOf:1];
            [[result should] contain:hashtag];
          }
        });
        
        it(@"should not allow the multiplication character", ^{
          id result = [extractor extractHashtags:@"#pre\u00d7post"];
          
          [result shouldNotBeNil];
          [[result should] beKindOfClass:[NSArray class]];
          [[result should] haveCountOf:1];
          [[result should] contain:@"pre"];
        });
        
        it(@"should not allow the division character", ^{
          id result = [extractor extractHashtags:@"#pre\u00f7post"];
          
          [result shouldNotBeNil];
          [[result should] beKindOfClass:[NSArray class]];
          [[result should] haveCountOf:1];
          [[result should] contain:@"pre"];
        });
      });
      
      context(@"should NOT allow Japanese", ^{
        NSArray* tests = [NSArray arrayWithObjects:@"会議中", @"ハッシュ", nil];
        
        it(@"should NOT extract bare hashtags", ^{
          for( NSString* hashtag in tests ) {
            NSString* text = [@"#" stringByAppendingString:hashtag];
            id result = [extractor extractHashtags:text];
            //NSLog(@"Attempted to extract «%@» from «%@»: %@", hashtag, text, result);
            
            [result shouldNotBeNil];
            [[result should] beKindOfClass:[NSArray class]];
            [[result should] beEmpty];
          }
        });
        
        it(@"should NOT extract hashtags within text", ^{
          for( NSString* hashtag in tests ) {
            NSString* text = [NSString stringWithFormat:@"pre-text #%@ post-text", hashtag];
            id result = [extractor extractHashtags:text];
            //NSLog(@"Attempted to extract «%@» from «%@»: %@", hashtag, text, result);
            
            [result shouldNotBeNil];
            [[result should] beKindOfClass:[NSArray class]];
            [[result should] beEmpty];
          }
        });
      });
    });
    
    it(@"should not extract numeric hashtags", ^{
      id result = [extractor extractHashtags:@"#1234"];
      
      [result shouldNotBeNil];
      [[result should] beKindOfClass:[NSArray class]];
      [[result should] beEmpty];
    });
  });
  
  
  describe(@"hashtags with indices", ^{
    void (^matchHashtagInText)(NSString*,NSString*,NSUInteger) = ^( NSString* hashtag, NSString* text, NSUInteger offset ){
      TWEntity* target   = [[TWEntity alloc] initWithValue:hashtag rangeInText:NSMakeRange(offset, [hashtag length]+1) type:TWEntityTypeHashtag];
      
      id result = [extractor extractHashtagsWithIndices:text];
      //NSLog(@"Attempted to extract «%@» from «%@»: %@", hashtag, text, result);
      
      [result shouldNotBeNil];
      [[result should] beKindOfClass:[NSArray class]];
      [[result should] haveCountOf:1];
      
      id match = [result lastObject];
      [[match should] equal:target];
      
      [target release];
    };
    
    void (^noMatchHashtagInText)(NSString*) = ^( NSString* text ){
      id result = [extractor extractHashtagsWithIndices:text];
      
      [result shouldNotBeNil];
      [[result should] beKindOfClass:[NSArray class]];
      [[result should] beEmpty];
    };
    
    context(@"extracts latin/numeric hashtags", ^{
      NSArray* tests = [NSArray arrayWithObjects:@"text", @"text123", @"123text", nil];
      
      it(@"should extract bare hashtags", ^{
        for( NSString* hashtag in tests ) {
          matchHashtagInText(hashtag, [@"#" stringByAppendingString:hashtag], 0);
        }
      });
      
      it(@"should extract hashtags within text", ^{
        for( NSString* hashtag in tests ) {
          matchHashtagInText(hashtag, [NSString stringWithFormat:@"pre-text #%@ post-text", hashtag], 9);
        }
      });
    });
    
    context(@"international hashtags", ^{
      context(@"should allow accents", ^{
        NSArray* tests = [NSArray arrayWithObjects:@"mañana", @"café", @"münchen", nil];
        
        it(@"should extract bare hashtags", ^{
          for( NSString* hashtag in tests ) {
            matchHashtagInText(hashtag, [@"#" stringByAppendingString:hashtag], 0);
          }
        });
        
        it(@"should extract hashtags within text", ^{
          for( NSString* hashtag in tests ) {
            matchHashtagInText(hashtag, [NSString stringWithFormat:@"pre-text #%@ post-text", hashtag], 9);
          }
        });
        
        it(@"should not allow the multiplication character", ^{
          matchHashtagInText(@"pre", @"#pre\u00d7post", 0);
        });
        
        it(@"should not allow the division character", ^{
          matchHashtagInText(@"pre", @"#pre\u00f7post", 0);
        });
      });
      
      context(@"should NOT allow Japanese", ^{
        NSArray* tests = [NSArray arrayWithObjects:@"会議中", @"ハッシュ", nil];
        
        it(@"should NOT extract bare hashtags", ^{
          for( NSString* hashtag in tests ) {
            NSString* text = [@"#" stringByAppendingString:hashtag];
            noMatchHashtagInText(text);
          }
        });
        
        it(@"should NOT extract hashtags within text", ^{
          for( NSString* hashtag in tests ) {
            NSString* text = [NSString stringWithFormat:@"pre-text #%@ post-text", hashtag];
            noMatchHashtagInText(text);
          }
        });
      });
    });
    
    it(@"should not extract numeric hashtags", ^{
      noMatchHashtagInText(@"#1234");
    });
  
  });

});

SPEC_END
