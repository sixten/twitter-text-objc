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

- (NSString *)autoLink:(NSString *)text {
  return [self autoLinkUsernamesAndLists:[self autoLinkURLs:[self autoLinkHashtags:text]]];
}

- (NSString *)autoLinkUsernamesAndLists:(NSString *)text {
  NSMutableString* buffer = [[NSMutableString alloc] initWithCapacity:[text length]];
  NSArray* chunks = [text componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
  
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
      NSRange searchRange = NSMakeRange(0, [chunk length]);
      while( YES ) {
        NSString* pattern = [TWRegex autoLinkUsernamesOrLists];
        NSRange matchRange = [chunk RKL_METHOD_PREPEND(rangeOfRegex):pattern inRange:searchRange];
        if( matchRange.location == NSNotFound ) {
          break;
        }
        
        [buffer appendString:[chunk substringWithRange:NSMakeRange(searchRange.location, matchRange.location-searchRange.location)]];
        
        NSRange listRange = [chunk RKL_METHOD_PREPEND(rangeOfRegex):pattern options:RKLNoOptions inRange:matchRange capture:TWRegexGroupsAutoLinkUsernameOrListList error:NULL];
        
        if( listRange.location == NSNotFound ) {
          // Username only
          NSRange afterRange = NSMakeRange(NSMaxRange(matchRange), 1);
          
          if( afterRange.location >= [chunk length] || ![[chunk substringWithRange:afterRange] RKL_METHOD_PREPEND(isMatchedByRegex):[TWRegex screenNameMatchEnd]] ) {
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
            [buffer appendString:[[chunk substringWithRange:matchRange] RKL_METHOD_PREPEND(stringByReplacingOccurrencesOfRegex):pattern withString:replacement]];
          }
          else {
            // Not a screen name valid for linking
            [buffer appendString:[text substringWithRange:matchRange]];
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
          [buffer appendString:[[chunk substringWithRange:matchRange] RKL_METHOD_PREPEND(stringByReplacingOccurrencesOfRegex):pattern withString:replacement]];
        }
        
        searchRange = NSMakeRange(NSMaxRange(matchRange), [chunk length] - NSMaxRange(matchRange));
      }
      [buffer appendString:[text substringWithRange:searchRange]];
    }
  }
  
  NSString* result = [[buffer copy] autorelease];
  [buffer release];
  
  return result;
}

- (NSString *)autoLinkHashtags:(NSString *)text {
  NSString* replacement = [NSString stringWithFormat:@"$%i<a href=\"%@$%i\" title=\"#$%i\" class=\"%@ %@\"%@>$%i$%i</a>", TWRegexGroupsAutoLinkHashtagBefore, self.hashtagUrlBase, TWRegexGroupsAutoLinkHashtagTag, TWRegexGroupsAutoLinkHashtagTag, self.urlClass, self.hashtagClass, (self.noFollow ? TWAutolinkNoFollowAttribute : @""), TWRegexGroupsAutoLinkHashtagHash, TWRegexGroupsAutoLinkHashtagTag];
  
  return [text RKL_METHOD_PREPEND(stringByReplacingOccurrencesOfRegex):[TWRegex autoLinkHashtags] withString:replacement];
}

- (NSString *)autoLinkURLs:(NSString *)text {
  return nil;
}

@end
