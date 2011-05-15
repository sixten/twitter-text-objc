//
//  TWRegex.h
//  TwitterText
//
//  Created by Sixten Otto on 5/15/11.
//  Copyright 2011 Sixten Otto. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
  TWRegexGroupsAutoLinkHashtagsEntireMatch = 0,
  TWRegexGroupsAutoLinkHashtagsBefore,
  TWRegexGroupsAutoLinkHashtagsHash,
  TWRegexGroupsAutoLinkHashtagsTag
} TWRegexGroupsAutoLinkHashtags;


@interface TWRegex : NSObject {}

+ (NSString *)autoLinkHashtags;

@end
