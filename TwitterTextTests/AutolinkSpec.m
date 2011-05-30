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
  
  // pick up a few cases that aren't covered in the conformance tests
  describe(@"auto-linking", ^{
    it(@"should allow url/hashtag overlap", ^{
      id result = [autolink autoLink:@"http://twitter.com/#search"];
      
      [result shouldNotBeNil];
      [[result should] equal:@"<a href=\"http://twitter.com/#search\" rel=\"nofollow\">http://twitter.com/#search</a>"];
    });
    
    it(@"should link a hashtag preceded by Japanese", ^{
      id result = [autolink autoLink:@"の#twj_dev"];
      
      [result shouldNotBeNil];
      [[result should] equal:@"の<a href=\"http://twitter.com/search?q=%23twj_dev\" title=\"#twj_dev\" class=\"tweet-url hashtag\" rel=\"nofollow\">#twj_dev</a>"];
    });
    
    it(@"should link Wikipedia-style URLs", ^{
      id result = [autolink autoLink:@"http://en.wikipedia.org/wiki/Madonna_(artist)"];
      
      [result shouldNotBeNil];
      [[result should] equal:@"<a href=\"http://en.wikipedia.org/wiki/Madonna_(artist)\" rel=\"nofollow\">http://en.wikipedia.org/wiki/Madonna_(artist)</a>"];
    });
    
    it(@"should link balanced parens with a double quote inside", ^{
      id result = [autolink autoLink:@"http://foo.bar/foo_(\")_bar"];
      
      [result shouldNotBeNil];
      [[result should] equal:@"<a href=\"http://foo.bar/foo_\" rel=\"nofollow\">http://foo.bar/foo_</a>(\")_bar"];
    });
    
    it(@"should link multiple URLs in different formats", ^{
      id result = [autolink autoLink:@"http://foo.com https://bar.com http://mail.foobar.org"];
      
      [result shouldNotBeNil];
      [[result should] equal:@"<a href=\"http://foo.com\" rel=\"nofollow\">http://foo.com</a> <a href=\"https://bar.com\" rel=\"nofollow\">https://bar.com</a> <a href=\"http://mail.foobar.org\" rel=\"nofollow\">http://mail.foobar.org</a>"];
    });
    
    // See Also: http://github.com/mzsanford/twitter-text-rb/issues#issue/5
    it(@"should link Blogspot URLs", ^{
      autolink.noFollow = NO;
      id result = [autolink autoLink:@"Url: http://samsoum-us.blogspot.com/2010/05/la-censure-nuit-limage-de-notre-pays.html"];
      
      [result shouldNotBeNil];
      [[result should] equal:@"Url: <a href=\"http://samsoum-us.blogspot.com/2010/05/la-censure-nuit-limage-de-notre-pays.html\">http://samsoum-us.blogspot.com/2010/05/la-censure-nuit-limage-de-notre-pays.html</a>"];
    });
    
    // See also: https://github.com/mzsanford/twitter-text-java/issues/8
    it(@"should handle URLs with regex-like dollar signs", ^{
      autolink.noFollow = NO;
      id result = [autolink autoLink:@"Url: http://example.com/$ABC"];
      
      [result shouldNotBeNil];
      [[result should] equal:@"Url: <a href=\"http://example.com/$ABC\">http://example.com/$ABC</a>"];
    });
    
  });
  
  describe(@"auto-linking options", ^{
    it(@"should not add a class attribute by default", ^{
      id result = [autolink autoLink:@"http://example.com/"];
      
      [result shouldNotBeNil];
      [[result should] equal:@"<a href=\"http://example.com/\" rel=\"nofollow\">http://example.com/</a>"];
    });
    
    pending(@"should apply urlClass as a CSS class if it is not the default value", ^{
      autolink.urlClass = @"myclass";
      id result = [autolink autoLink:@"http://example.com/"];
      
      [result shouldNotBeNil];
      [[result should] equal:@"<a href=\"http://example.com/\" class=\"myclass\" rel=\"nofollow\">http://example.com/</a>"];
    });
    
    it(@"should add rel=nofollow by default", ^{
      id result = [autolink autoLink:@"http://example.com/"];
      
      [result shouldNotBeNil];
      [[result should] equal:@"<a href=\"http://example.com/\" rel=\"nofollow\">http://example.com/</a>"];
    });
    
    it(@"should not add rel=nofollow when noFollow is NO", ^{
      autolink.noFollow = NO;
      id result = [autolink autoLink:@"http://example.com/"];
      
      [result shouldNotBeNil];
      [[result should] equal:@"<a href=\"http://example.com/\">http://example.com/</a>"];
    });
    
    it(@"should not add a target attribute by default", ^{
      id result = [autolink autoLink:@"http://example.com/"];
      
      [result shouldNotBeNil];
      [[result should] equal:@"<a href=\"http://example.com/\" rel=\"nofollow\">http://example.com/</a>"];
    });
    
    pending(@"should respect the :target option", ^{
      // this option is present in the Ruby version, but not Java
    });
  });
  
  describe(@"HTML escaping", ^{
    it(@"should escape HTML entities properly", ^{
      [[autolink stringByEscapingHTMLMetacharactersInString:nil] shouldBeNil];
      [[[autolink stringByEscapingHTMLMetacharactersInString:@"there are no entities in me!"] should] equal:@"there are no entities in me!"];
      [[[autolink stringByEscapingHTMLMetacharactersInString:@"&"] should] equal:@"&amp;"];
      [[[autolink stringByEscapingHTMLMetacharactersInString:@">"] should] equal:@"&gt;"];
      [[[autolink stringByEscapingHTMLMetacharactersInString:@"<"] should] equal:@"&lt;"];
      [[[autolink stringByEscapingHTMLMetacharactersInString:@"\""] should] equal:@"&quot;"];
      [[[autolink stringByEscapingHTMLMetacharactersInString:@"'"] should] equal:@"&#39;"];
      [[[autolink stringByEscapingHTMLMetacharactersInString:@"&<>\""] should] equal:@"&amp;&lt;&gt;&quot;"];
      [[[autolink stringByEscapingHTMLMetacharactersInString:@"<div>"] should] equal:@"&lt;div&gt;"];
      [[[autolink stringByEscapingHTMLMetacharactersInString:@"a&b"] should] equal:@"a&amp;b"];
      [[[autolink stringByEscapingHTMLMetacharactersInString:@"<a href=\"http://twitter.com\" target=\"_blank\">twitter & friends</a>"]
        should] equal:@"&lt;a href=&quot;http://twitter.com&quot; target=&quot;_blank&quot;&gt;twitter &amp; friends&lt;/a&gt;"];
      [[[autolink stringByEscapingHTMLMetacharactersInString:@"&amp;"] should] equal:@"&amp;amp;"];
    });
  });
  
});

SPEC_END
