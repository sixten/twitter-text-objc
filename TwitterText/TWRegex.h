//
//  TWRegex.h
//  TwitterText
//
//  Created by Sixten Otto on 5/15/11.
//  Copyright 2011 Sixten Otto. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
  TWRegexGroupsAutoLinkHashtagEntireMatch = 0,
  TWRegexGroupsAutoLinkHashtagBefore,
  TWRegexGroupsAutoLinkHashtagHash,
  TWRegexGroupsAutoLinkHashtagTag,
} TWRegexGroupsAutoLinkHashtag;

typedef enum {
  TWRegexGroupsAutoLinkUsernameOrListEntireMatch = 0,
  TWRegexGroupsAutoLinkUsernameOrListBefore,
  TWRegexGroupsAutoLinkUsernameOrListAt,
  TWRegexGroupsAutoLinkUsernameOrListUsername,
  TWRegexGroupsAutoLinkUsernameOrListList,
} TWRegexGroupsAutoLinkUsernameOrList;

typedef enum {
  TWRegexGroupsExtractMentionEntireMatch = 0,
  TWRegexGroupsExtractMentionBefore,
  TWRegexGroupsExtractMentionUsername,
  TWRegexGroupsExtractMentionAfter,
} TWRegexGroupsExtractMention;

typedef enum {
  TWRegexGroupsExtractReplyEntireMatch = 0,
  TWRegexGroupsExtractReplyUsername,
} TWRegexGroupsExtractReply;

typedef enum {
  TWRegexGroupsValidURLEntireMatch = 0,
  TWRegexGroupsValidURLComplete,
  TWRegexGroupsValidURLBefore,
  TWRegexGroupsValidURLURL,
  TWRegexGroupsValidURLProtocol,
  TWRegexGroupsValidURLDomain,
  TWRegexGroupsValidURLPort,
  TWRegexGroupsValidURLPath,
  TWRegexGroupsValidURLQueryString,
} TWRegexGroupsValidURL;


@interface TWRegex : NSObject {}

+ (NSString *)autoLinkHashtags;
+ (NSString *)autoLinkUsernamesOrLists;

+ (NSString *)extractMentions;
+ (NSString *)screenNameMatchEnd;

+ (NSString *)extractReply;

+ (NSString *)validURL;

@end
