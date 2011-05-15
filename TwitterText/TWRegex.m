//
//  TWRegex.m
//  TwitterText
//
//  Created by Sixten Otto on 5/15/11.
//  Copyright 2011 Sixten Otto. All rights reserved.
//

#import "TWRegex.h"

static NSString *const TWHashtagCharacters = @"[a-z0-9_\\u00c0-\\u00d6\\u00d8-\\u00f6\\u00f8-\\u00ff]";


@implementation TWRegex

+ (NSString *)autoLinkHashtags {
  static NSString* _regex = nil;
  if( _regex == nil ) {
    _regex = [[NSString alloc] initWithFormat:@"(?i)(^|[^0-9A-Z&/]+)(#|\uFF03)([0-9A-Z_]*[A-Z_]+%@*)", TWHashtagCharacters];
  }
  return _regex;
}

@end
