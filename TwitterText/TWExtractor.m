//
//  TWExtractor.m
//  TwitterText
//
//  Created by Sixten Otto on 5/14/11.
//  Copyright 2011 Results Direct. All rights reserved.
//

#import "TWExtractor.h"

#import "TWEntity.h"

#import "RegexKitLite.h"


@implementation TWExtractor

/**
 * Helper method for extracting multiple matches from Tweet text.
 *
 * @param pattern to match and use for extraction
 * @param text of the Tweet to extract from
 * @param groupNumber the capturing group of the pattern that should be added to the list.
 * @return list of extracted values, or an empty list if there were none.
 */
- (NSArray *)extractValuesFromText:(NSString *)text forRegex:(NSString *)pattern
{
  return nil;
}

- (NSArray *)extractEntitiesFromText:(NSString *)text forRegex:(NSString *)pattern valueType:(TWEntityType)type
{
  return nil;
}


#pragma mark - public methods

- (NSArray *)extractHashtags:(NSString *)text {
  return nil;
}

- (NSArray *)extractHashtagsWithIndices:(NSString *)text {
  return nil;
}

- (NSArray *)extractMentionedScreennames:(NSString *)text {
  return nil;
}

- (NSString *)extractReplyScreenname:(NSString *)text {
  return nil;
}

- (NSArray *)extractURLs:(NSString *)text {
  return nil;
}

@end
