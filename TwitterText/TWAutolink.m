//
//  TWAutolink.m
//  TwitterText
//
//  Created by Sixten Otto on 5/18/11.
//  Copyright 2011 Sixten Otto. All rights reserved.
//

#import "TWAutolink.h"

#import "TWRegex.h"

#import "RegexKitLite.h"


NSString *const TWAutolinkDefaultURLClass = @"tweet-url";
NSString *const TWAutolinkDefaultListClass = @"list-slug";
NSString *const TWAutolinkDefaultUsernameClass = @"username";
NSString *const TWAutolinkDefaultHashtagClass = @"hashtag";
NSString *const TWAutolinkDefaultUsernameURLBase = @"http://twitter.com/";
NSString *const TWAutolinkDefaultListURLBase = @"http://twitter.com/";
NSString *const TWAutolinkDefaultHashtagURLBase = @"http://twitter.com/search?q=%23";
NSString *const TWAutolinkNoFollowAttribute = @" rel=\"nofollow\"";




@implementation TWAutolink

@synthesize urlClass = tw_urlClass;
@synthesize listClass = tw_listClass;
@synthesize usernameClass = tw_usernameClass;
@synthesize hashtagClass = tw_hashtagClass;
@synthesize usernameUrlBase = tw_usernameUrlBase;
@synthesize listUrlBase = tw_listUrlBase;
@synthesize hashtagUrlBase = tw_hashtagUrlBase;
@synthesize noFollow = tw_noFollow;

- (id)init {
  self = [super init];
  if (self) {
    self.urlClass = TWAutolinkDefaultURLClass;
    self.listClass = TWAutolinkDefaultListClass;
    self.usernameClass = TWAutolinkDefaultUsernameClass;
    self.hashtagClass = TWAutolinkDefaultHashtagClass;
    self.usernameUrlBase = TWAutolinkDefaultUsernameURLBase;
    self.listUrlBase = TWAutolinkDefaultListURLBase;
    self.hashtagUrlBase = TWAutolinkDefaultHashtagURLBase;
    self.noFollow = YES;
  }
  return self;
}

- (void)dealloc {
  [tw_urlClass release];
  [tw_listClass release];
  [tw_usernameClass release];
  [tw_hashtagClass release];
  [tw_usernameUrlBase release];
  [tw_listUrlBase release];
  [tw_hashtagUrlBase release];
  [super dealloc];
}


- (NSString *)stringByEscapingHTMLMetacharactersInString:(NSString *)text {
  static NSCharacterSet* _metaChars = nil;
  if( _metaChars == nil ) {
    _metaChars = [[NSCharacterSet characterSetWithCharactersInString:@"&\"'><"] retain];
  }
  
  if( [text rangeOfCharacterFromSet:_metaChars].location == NSNotFound ) return text;
  
  NSMutableString* newText = [text mutableCopy];
  NSRange searchRange = NSMakeRange(0, [text length]);
  
  while( searchRange.location < [newText length] ) {
    NSRange matchRange = [newText rangeOfCharacterFromSet:_metaChars options:0 range:searchRange];
    if( matchRange.location == NSNotFound ) break;
    
    NSString* replacement = nil;
    switch ([newText characterAtIndex:matchRange.location]) {
      case '&':
        replacement = @"&amp;";
        break;
      case '"':
        replacement = @"&quot;";
        break;
      case '\'':
        replacement = @"&#39;";
        break;
      case '<':
        replacement = @"&lt;";
        break;
      case '>':
        replacement = @"&gt;";
        break;
    }
    [newText replaceCharactersInRange:matchRange withString:replacement];
    
    searchRange = NSMakeRange(NSMaxRange(matchRange), [newText length] - NSMaxRange(matchRange));
  }
  
  text = [[newText copy] autorelease];
  [newText release];
  
  return text;
}


- (NSString *)autoLink:(NSString *)text {
  return [self autoLinkUsernamesAndLists:[self autoLinkURLs:[self autoLinkHashtags:text]]];
}

- (NSString *)autoLinkUsernamesAndLists:(NSString *)text {
  NSMutableString* buffer = [[NSMutableString alloc] initWithCapacity:[text length]];
  NSArray* chunks = [text componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
  NSString* pattern = [TWRegex autoLinkUsernamesOrLists];
  
  for( NSUInteger i=0; i<[chunks count]; i++ ) {
    if( i>0 ) {
      if( i%2 == 0 ) {
        [buffer appendString:@">"];
      }
      else {
        [buffer appendString:@"<"];
      }
    }
    
    if( i%4 != 0 ) {
      [buffer appendString:[chunks objectAtIndex:i]];
    }
    else {
      NSString* chunk = [chunks objectAtIndex:i];
      NSError* error;
      __block NSRange searchRange = NSMakeRange(0, [chunk length]);
      
      [chunk rkl_enumerateStringsMatchedByRegex:pattern options:RKLNoOptions inRange:searchRange error:&error enumerationOptions:RKLRegexEnumerationFastCapturedStringsXXX usingBlock:^(NSInteger captureCount, NSString *const *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
        NSUInteger matchEnd = NSMaxRange(capturedRanges[TWRegexGroupsAutoLinkUsernameOrListEntireMatch]);
        [buffer appendString:[chunk substringWithRange:NSMakeRange(searchRange.location, capturedRanges[TWRegexGroupsAutoLinkUsernameOrListEntireMatch].location-searchRange.location)]];
        
        if( capturedRanges[TWRegexGroupsAutoLinkUsernameOrListList].location == NSNotFound ) {
          // Username only
          NSRange afterRange = NSMakeRange(matchEnd, 1);
          
          if( afterRange.location >= [chunk length] || ![[chunk substringWithRange:afterRange] rkl_isMatchedByRegex:[TWRegex screenNameMatchEnd]] ) {
            NSString* replacement = [NSString stringWithFormat:@"$%i$%i<a class=\"%@ %@\" href=\"%@$%i\"%@>$%i</a>",
                                     TWRegexGroupsAutoLinkUsernameOrListBefore,
                                     TWRegexGroupsAutoLinkUsernameOrListAt,
                                     self.urlClass,
                                     self.usernameClass,
                                     self.usernameUrlBase,
                                     TWRegexGroupsAutoLinkUsernameOrListUsername,
                                     (self.noFollow ? TWAutolinkNoFollowAttribute : @""),
                                     TWRegexGroupsAutoLinkUsernameOrListUsername
                                     ];
            [buffer appendString:[capturedStrings[TWRegexGroupsAutoLinkUsernameOrListEntireMatch] rkl_stringByReplacingOccurrencesOfRegex:pattern withString:replacement]];
          }
          else {
            // Not a screen name valid for linking
            [buffer appendString:capturedStrings[TWRegexGroupsAutoLinkUsernameOrListEntireMatch]];
          }
        }
        else {
          // Username and list
          NSString* replacement = [NSString stringWithFormat:@"$%i$%i<a class=\"%@ %@\" href=\"%@$%i$%i\"%@>$%i$%i</a>",
                                   TWRegexGroupsAutoLinkUsernameOrListBefore,
                                   TWRegexGroupsAutoLinkUsernameOrListAt,
                                   self.urlClass,
                                   self.listClass,
                                   self.listUrlBase,
                                   TWRegexGroupsAutoLinkUsernameOrListUsername,
                                   TWRegexGroupsAutoLinkUsernameOrListList,
                                   (self.noFollow ? TWAutolinkNoFollowAttribute : @""),
                                   TWRegexGroupsAutoLinkUsernameOrListUsername,
                                   TWRegexGroupsAutoLinkUsernameOrListList
                                   ];
          [buffer appendString:[capturedStrings[TWRegexGroupsAutoLinkUsernameOrListEntireMatch] rkl_stringByReplacingOccurrencesOfRegex:pattern withString:replacement]];
        }
        
        searchRange = NSMakeRange(matchEnd, [chunk length] - matchEnd);
      }];
      
      [buffer appendString:[chunk substringWithRange:searchRange]];
    }
  }
  
  NSString* result = [[buffer copy] autorelease];
  [buffer release];
  
  return result;
}

- (NSString *)autoLinkHashtags:(NSString *)text {
  NSString* replacement = [NSString stringWithFormat:@"$%i<a href=\"%@$%i\" title=\"#$%i\" class=\"%@ %@\"%@>$%i$%i</a>", TWRegexGroupsAutoLinkHashtagBefore, self.hashtagUrlBase, TWRegexGroupsAutoLinkHashtagTag, TWRegexGroupsAutoLinkHashtagTag, self.urlClass, self.hashtagClass, (self.noFollow ? TWAutolinkNoFollowAttribute : @""), TWRegexGroupsAutoLinkHashtagHash, TWRegexGroupsAutoLinkHashtagTag];
  
  return [text rkl_stringByReplacingOccurrencesOfRegex:[TWRegex autoLinkHashtags] withString:replacement];
}

- (NSString *)autoLinkURLs:(NSString *)text {
  NSString* pattern = [TWRegex validURL];
  
  NSString* classAttribute = @"";
  if( ![TWAutolinkDefaultURLClass isEqualToString:self.urlClass] ) {
    classAttribute = [NSString stringWithFormat:@" class=\"%@\"", self.urlClass];
  }

  __block NSMutableString* buffer = [[NSMutableString alloc] initWithCapacity:[text length]];
  __block NSRange remainingRange = NSMakeRange(0, [text length]);
  
  [text rkl_enumerateStringsMatchedByRegex:pattern options:RKLNoOptions inRange:remainingRange error:NULL enumerationOptions:RKLRegexEnumerationFastCapturedStringsXXX usingBlock:^(NSInteger captureCount, NSString *const *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
    // everything from the end of the last match to the start of this
    NSRange prerange = NSMakeRange(remainingRange.location, capturedRanges[TWRegexGroupsValidURLEntireMatch].location-remainingRange.location);
    
    // only autolink URLs with protocol
    if( capturedRanges[TWRegexGroupsValidURLProtocol].location != NSNotFound ) {
      // query string needs to be html escaped
      NSString* url = capturedStrings[TWRegexGroupsValidURLURL];
      NSString* queryString = capturedStrings[TWRegexGroupsValidURLQueryString];
      if( [queryString length] > 0 ) {
        url = [url stringByReplacingOccurrencesOfString:queryString withString:[self stringByEscapingHTMLMetacharactersInString:queryString]];
      }
      url = [url stringByReplacingOccurrencesOfString:@"\\$" withString:@"\\\\\\$"];
      
      NSString* replacement = [NSString stringWithFormat:@"$%i<a href=\"%@\"%@%@>%@</a>",
                               TWRegexGroupsValidURLBefore,
                               url,
                               classAttribute,
                               (self.noFollow ? TWAutolinkNoFollowAttribute : @""),
                               url
                               ];
      [buffer appendString:[text substringWithRange:prerange]];
      [buffer appendString:[[text substringWithRange:capturedRanges[TWRegexGroupsValidURLEntireMatch]] rkl_stringByReplacingOccurrencesOfRegex:pattern withString:replacement]];      
      
      // remember where this match ended
      NSUInteger matchEnd = NSMaxRange(capturedRanges[TWRegexGroupsValidURLEntireMatch]);
      remainingRange = NSMakeRange(matchEnd, [text length] - matchEnd);
    }
  }];
  
  // add any unmatched text at the end of the text to the result
  [buffer appendString:[text substringWithRange:remainingRange]];
  
  NSString* result = [[buffer copy] autorelease];
  [buffer release];
  
  return result;
}

@end
