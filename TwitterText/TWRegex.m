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

static NSString *const TWLatinAccentsChars = @"\u00c0-\u00d6\u00d8-\u00f6\u00f8-\u00ff\u015f";

static NSString *const URL_VALID_PRECEEDING_CHARS = @"(?:[^\\-/\"'!=A-Z0-9_@＠.\u202A-\u202E]|^)";
static NSString *const URL_VALID_UNICODE_CHARS = @"[.[^\\p{Punct}\\s\\p{Z}\\p{InGeneralPunctuation}]]";
static NSString *const URL_VALID_GTLD =
  @"(?:(?:aero|asia|biz|cat|com|coop|edu|gov|info|int|jobs|mil|mobi|museum|name|net|org|pro|tel|travel)(?=\\P{Alpha}|$))";
static NSString *const URL_VALID_CCTLD =
  @"(?:(?:ac|ad|ae|af|ag|ai|al|am|an|ao|aq|ar|as|at|au|aw|ax|az|ba|bb|bd|be|bf|bg|bh|bi|bj|bm|bn|bo|br|bs|bt|"
  @"bv|bw|by|bz|ca|cc|cd|cf|cg|ch|ci|ck|cl|cm|cn|co|cr|cs|cu|cv|cx|cy|cz|dd|de|dj|dk|dm|do|dz|ec|ee|eg|eh|"
  @"er|es|et|eu|fi|fj|fk|fm|fo|fr|ga|gb|gd|ge|gf|gg|gh|gi|gl|gm|gn|gp|gq|gr|gs|gt|gu|gw|gy|hk|hm|hn|hr|ht|"
  @"hu|id|ie|il|im|in|io|iq|ir|is|it|je|jm|jo|jp|ke|kg|kh|ki|km|kn|kp|kr|kw|ky|kz|la|lb|lc|li|lk|lr|ls|lt|"
  @"lu|lv|ly|ma|mc|md|me|mg|mh|mk|ml|mm|mn|mo|mp|mq|mr|ms|mt|mu|mv|mw|mx|my|mz|na|nc|ne|nf|ng|ni|nl|no|np|"
  @"nr|nu|nz|om|pa|pe|pf|pg|ph|pk|pl|pm|pn|pr|ps|pt|pw|py|qa|re|ro|rs|ru|rw|sa|sb|sc|sd|se|sg|sh|si|sj|sk|"
  @"sl|sm|sn|so|sr|ss|st|su|sv|sy|sz|tc|td|tf|tg|th|tj|tk|tl|tm|tn|to|tp|tr|tt|tv|tw|tz|ua|ug|uk|us|uy|uz|"
  @"va|vc|ve|vg|vi|vn|vu|wf|ws|ye|yt|za|zm|zw)(?=\\P{Alpha}|$))";
static NSString *const URL_PUNYCODE = @"(?:xn--[0-9a-z]+)";
static NSString *const URL_VALID_PORT_NUMBER = @"[0-9]++";
static NSString *const URL_VALID_URL_QUERY_CHARS = @"[a-z0-9!\\*'\\(\\);:&=\\+\\$/%#\\[\\]\\-_\\.,~\\|]";
static NSString *const URL_VALID_URL_QUERY_ENDING_CHARS = @"[a-z0-9_&=#/]";


@implementation TWRegex

#pragma mark - private hashtag-related methods

+ (NSString *)atSigns {
  return [NSString stringWithFormat:@"[%@]", TWAtSignChars];
}


#pragma mark - private URL-related methods

+ (NSString *)validURLChars {
  return [NSString stringWithFormat:@"[a-zA-Z0-9%@]", TWLatinAccentsChars];
}

+ (NSString *)validGeneralPathChars {
  // don't use the ICU \p{Alnum} class (which is Unicode-aware, and includes CJK codepoints); the Java version is ASCII-only!
  return [NSString stringWithFormat:@"[a-z0-9!\\*';:=\\+,.\\$/%%#\\[\\]\\-_~\\|&%@]", TWLatinAccentsChars];
}

+ (NSString *)balancedURLParens {
  return [NSString stringWithFormat:@"\\(%@+\\)", [self validGeneralPathChars]];
}

+ (NSString *)validPathEndingChars {
  return [NSString stringWithFormat:@"[a-z0-9=_#/\\-\\+%@]|(?:%@)", TWLatinAccentsChars, [self balancedURLParens]];
}

+ (NSString *)validSubdomain {
  NSString* validChars = [self validURLChars];
  return [NSString stringWithFormat:@"(?:(?:%@[%@\\-_]*)?%@\\.)", validChars, validChars, validChars];
}

+ (NSString *)validDomainName {
  NSString* validChars = [self validURLChars];
  return [NSString stringWithFormat:@"(?:(?:%@[%@\\-]*)?%@\\.)", validChars, validChars, validChars];
}

+ (NSString *)validDomain {
  NSString* validSubdomain = [self validSubdomain];
  NSString* validDomainName = [self validDomainName];
  return [NSString stringWithFormat:
          @"(?:%@+%@(?:%@|%@|%@))"          // subdomains + domain + TLD
          @"|(?:%@(?:%@|%@))"               // domain + gTLD
          @"|(?:(?<=https?://)(?:"          // protocol +
            @"(?:%@%@)"                       // domain + ccTLD
            @"|(?:%@+\\.(?:%@|%@))))"         // unicode domain + TLD
          @"|(?:%@%@(?=/))"                 // domain + ccTLD + '/'
          , validSubdomain, validDomainName, URL_VALID_GTLD, URL_VALID_CCTLD, URL_PUNYCODE
          , validDomainName, URL_VALID_GTLD, URL_PUNYCODE
          , validDomainName, URL_VALID_CCTLD
          , URL_VALID_UNICODE_CHARS, URL_VALID_GTLD, URL_VALID_CCTLD
          , validDomainName, URL_VALID_CCTLD
          ];
}
/*
  private static final String URL_VALID_DOMAIN =
    "(?:" +                                                   // subdomains + domain + TLD
        URL_VALID_SUBDOMAIN + "+" + URL_VALID_DOMAIN_NAME +   // e.g. www.twitter.com, foo.co.jp, bar.co.uk
        "(?:" + URL_VALID_GTLD + "|" + URL_VALID_CCTLD + "|" + URL_PUNYCODE + ")" +
      ")" +
    "|(?:" +                                                  // domain + gTLD
      URL_VALID_DOMAIN_NAME +                                 // e.g. twitter.com
      "(?:" + URL_VALID_GTLD + "|" + URL_PUNYCODE + ")" +
    ")" +
    "|(?:" + "(?<=https?://)" +
      "(?:" +
        "(?:" + URL_VALID_DOMAIN_NAME + URL_VALID_CCTLD + ")" +  // protocol + domain + ccTLD
        "|(?:" +
          URL_VALID_UNICODE_CHARS + "+\\." +                     // protocol + unicode domain + TLD
          "(?:" + URL_VALID_GTLD + "|" + URL_VALID_CCTLD + ")" +
        ")" +
      ")" +
    ")" +
    "|(?:" +                                                  // domain + ccTLD + '/'
      URL_VALID_DOMAIN_NAME + URL_VALID_CCTLD + "(?=/)" +     // e.g. t.co/
    ")";
*/

+ (NSString *)validPath {
  NSString* validGeneralPathChars = [self validGeneralPathChars];
  return [NSString stringWithFormat:@"(?:(?:%@*(?:%@%@*)*%@)|(?:@%@+/))", validGeneralPathChars, [self balancedURLParens], validGeneralPathChars, [self validPathEndingChars], validGeneralPathChars];
}


#pragma mark - public methods

+ (NSString *)autoLinkHashtags {
  static NSString* _regex = nil;
  if( _regex == nil ) {
    _regex = [[NSString alloc] initWithFormat:@"(?i)(^|[^0-9A-Z&/]+)(#|\uFF03)([0-9A-Z_]*[A-Z_]+%@*)", TWHashtagCharacters];
  }
  return _regex;
}

+ (NSString *)autoLinkUsernamesOrLists {
  static NSString* _regex = nil;
  if( _regex == nil ) {
    _regex = [[NSString alloc] initWithFormat:@"(?i)([^a-z0-9_]|^|RT:?)(%@+)([a-z0-9_]{1,20})(/[a-z][a-z0-9_\\-]{0,24})?", [self atSigns]];
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
  static NSString* _pattern = nil;
  if( _pattern == nil ) {
    _pattern = [[NSString alloc] initWithFormat:@"(?i)((%@)((https?://)?(%@)(?::(%@))?(/%@*)?(\\?%@*%@)?))", URL_VALID_PRECEEDING_CHARS, [self validDomain], URL_VALID_PORT_NUMBER, [self validPath], URL_VALID_URL_QUERY_CHARS, URL_VALID_URL_QUERY_ENDING_CHARS];
  }
  return _pattern;
}
/*
  private static final String VALID_URL_PATTERN_STRING =
  "(" +                                                            //  $1 total match
    "(" + URL_VALID_PRECEEDING_CHARS + ")" +                       //  $2 Preceeding chracter
    "(" +                                                          //  $3 URL
      "(https?://)?" +                                             //  $4 Protocol (optional)
      "(" + URL_VALID_DOMAIN + ")" +                               //  $5 Domain(s)
      "(?::(" + URL_VALID_PORT_NUMBER +"))?" +                     //  $6 Port number (optional)
      "(/" +
        URL_VALID_PATH + "*" +
      ")?" +                                                       //  $7 URL Path and anchor
      "(\\?" + URL_VALID_URL_QUERY_CHARS + "*" +                   //  $8 Query String
              URL_VALID_URL_QUERY_ENDING_CHARS + ")?" +
    ")" +
  ")";
*/

@end
