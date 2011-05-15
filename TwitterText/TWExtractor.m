//
//  TWExtractor.m
//  TwitterText
//
//  Created by Sixten Otto on 5/14/11.
//  Copyright 2011 Results Direct. All rights reserved.
//

#import "TWExtractor.h"

#import "TWRegex.h"
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
- (NSArray *)extractValuesFromText:(NSString *)text withRegex:(NSString *)pattern captureGroup:(NSUInteger)capture
{
  if( text == nil ) return nil;
  
  NSArray* matches = [text RKL_METHOD_PREPEND(arrayOfCaptureComponentsMatchedByRegex):pattern];
  
  if( [matches count] > 0 ) {
    NSMutableArray* values = [NSMutableArray arrayWithCapacity:[matches count]];
    for( NSArray* match in matches ) {
      [values addObject:[match objectAtIndex:capture]];
    }
    return values;
  }
  
  return [NSArray array];
}

- (NSArray *)extractEntitiesFromText:(NSString *)text withRegex:(NSString *)pattern captureGroup:(NSUInteger)capture valueType:(TWEntityType)type
{
  return nil;
}


#pragma mark - public methods

- (NSArray *)extractHashtags:(NSString *)text {
  return [self extractValuesFromText:text withRegex:[TWRegex autoLinkHashtags] captureGroup:TWRegexGroupsAutoLinkHashtagsTag];
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
