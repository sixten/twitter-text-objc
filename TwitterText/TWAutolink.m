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
  return nil;
}

- (NSString *)autoLinkHashtags:(NSString *)text {
  NSString* replacement = [NSString stringWithFormat:@"$%i<a href=\"%@$%i\" title=\"#$%i\" class=\"%@ %@\"%@>$%i$%i</a>", TWRegexGroupsAutoLinkHashtagBefore, self.hashtagUrlBase, TWRegexGroupsAutoLinkHashtagTag, TWRegexGroupsAutoLinkHashtagTag, self.urlClass, self.hashtagClass, (self.noFollow ? TWAutolinkNoFollowAttribute : @""), TWRegexGroupsAutoLinkHashtagHash, TWRegexGroupsAutoLinkHashtagTag];
  
  return [text RKL_METHOD_PREPEND(stringByReplacingOccurrencesOfRegex):[TWRegex autoLinkHashtags] withString:replacement];
}

- (NSString *)autoLinkURLs:(NSString *)text {
  return nil;
}

@end
