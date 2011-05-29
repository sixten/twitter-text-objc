//
//  TWRegex.m
//  TwitterText
//
//  Created by Sixten Otto on 5/15/11.
//  Copyright 2011 Sixten Otto. All rights reserved.
//

#import "TWRegex.h"

static NSString *const TWHashtagCharacters = @"[a-z0-9_\\u00c0-\\u00d6\\u00d8-\\u00f6\\u00f8-\\u00ff]";

static NSString *const TWSpaces = @"[\\u0009-\\u000d\\u0020\\u0085\\u00a0\\u1680\\u180E\\u2000-\\u200a\\u2028\\u2029\\u202F\\u205F\\u3000]";

static NSString *const TWAtSignChars = @"@\uFF20";

static NSString *const TWLatinAccentsChars = @"\u00c0-\u00d6\u00d8-\u00f6\u00f8-\u00ff";

static NSString *const URL_VALID_PRECEEDING_CHARS = @"(?:[^\\-/\"':!=A-Z0-9_@＠]+|^|\\:)";
static NSString *const URL_VALID_DOMAIN = @"(?:[^\\p{Punct}\\s][\\.-](?=[^\\p{Punct}\\s])|[^\\p{Punct}\\s]){1,}\\.[a-z]{2,}(?::[0-9]+)?";
static NSString *const URL_VALID_GENERAL_PATH_CHARS = @"[a-z0-9!\\*';:=\\+\\$/%#\\[\\]\\-_,~]";
static NSString *const URL_VALID_URL_QUERY_CHARS = @"[a-z0-9!\\*'\\(\\);:&=\\+\\$/%#\\[\\]\\-_\\.,~]";
static NSString *const URL_VALID_URL_QUERY_ENDING_CHARS = @"[a-z0-9_&=#/]";


@implementation TWRegex

+ (NSString *)atSigns {
  return [NSString stringWithFormat:@"[%@]", TWAtSignChars];
}

+ (NSString *)URLBalanceParens {
  return [NSString stringWithFormat:@"(?:\\(%@+\\))", URL_VALID_GENERAL_PATH_CHARS];
}

+ (NSString *)validURLPathChars {
  return [NSString stringWithFormat:@"(?:%@|@%@+/|[\\.,]?%@+)", [self URLBalanceParens], URL_VALID_GENERAL_PATH_CHARS, URL_VALID_GENERAL_PATH_CHARS];
}

+ (NSString *)validURLPathEndingChars {
  return [NSString stringWithFormat:@"(?:[a-z0-9=_#/\\-\\+]+|%@)", [self URLBalanceParens]];
}



+ (NSString *)autoLinkHashtags {
  static NSString* _regex = nil;
  if( _regex == nil ) {
    _regex = [[NSString alloc] initWithFormat:@"(?i)(^|[^0-9A-Z&/]+)(#|\uFF03)([0-9A-Z_]*[A-Z_]+%@*)", TWHashtagCharacters];
  }
  return _regex;
}

+ (NSString *)extractMentions {
  static NSString* _regex = nil;
  if( _regex == nil ) {
    _regex = [[NSString alloc] initWithFormat:@"(?i)(^|[^a-z0-9_])%@([a-z0-9_]{1,20})(?=(.|$))", [self atSigns]];
  }
  return _regex;
}

+ (NSString *)screenNameMatchEnd {
  return [NSString stringWithFormat:@"^(?:[%@%@]|://)", TWAtSignChars, TWLatinAccentsChars];
}

+ (NSString *)extractReply {
  static NSString* _regex = nil;
  if( _regex == nil ) {
    _regex = [[NSString alloc] initWithFormat:@"(?i)^(?:%@)*%@([a-z0-9_]{1,20}).*", TWSpaces, [self atSigns]];
  }
  return _regex;
}

+ (NSString *)validURL {
  static NSString* _regex = nil;
  if( _regex == nil ) {
    _regex = [[NSString alloc] initWithFormat:@"(?i)((%@)((https?://)(%@)(/(?:%@+%@|%@+%@?|%@)?)?(\\?%@*%@)?))", URL_VALID_PRECEEDING_CHARS, URL_VALID_DOMAIN, [self validURLPathChars], [self validURLPathEndingChars], [self validURLPathChars], [self validURLPathEndingChars], [self validURLPathEndingChars], URL_VALID_URL_QUERY_CHARS, URL_VALID_URL_QUERY_ENDING_CHARS];
  }
  return _regex;
}
/*
private static final String VALID_URL_PATTERN_STRING =
  "(" +                                                            //  $1 total match
    "(" + URL_VALID_PRECEEDING_CHARS + ")" +                       //  $2 Preceeding chracter
    "(" +                                                          //  $3 URL
      "(https?://)" +                                              //  $4 Protocol
      "(" + URL_VALID_DOMAIN + ")" +                               //  $5 Domain(s) and optional port number
      "(/" +
        "(?:" +
          URL_VALID_URL_PATH_CHARS + "+" +
            URL_VALID_URL_PATH_ENDING_CHARS + "|" +                //     1+ path chars and a valid last char
          URL_VALID_URL_PATH_CHARS + "+" +
            URL_VALID_URL_PATH_ENDING_CHARS + "?|" +               //     Optional last char to handle /@foo/ case
          URL_VALID_URL_PATH_ENDING_CHARS +                        //     Just a # case
        ")?" +
      ")?" +                                                       //  $6 URL Path and anchor
      "(\\?" + URL_VALID_URL_QUERY_CHARS + "*" +                   //  $7 Query String
              URL_VALID_URL_QUERY_ENDING_CHARS + ")?" +
    ")" +
  ")";
*/

@end
