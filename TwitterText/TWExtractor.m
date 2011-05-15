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
  NSArray* matches = nil;
  
  if( [text length] > 0 ) {
    matches = [text RKL_METHOD_PREPEND(arrayOfCaptureComponentsMatchedByRegex):pattern];
  }
  
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
  return [self extractValuesFromText:text withRegex:[TWRegex autoLinkHashtags] captureGroup:TWRegexGroupsAutoLinkHashtagTag];
}

- (NSArray *)extractHashtagsWithIndices:(NSString *)text {
  return nil;
}

- (NSArray *)extractMentionedScreennames:(NSString *)text {
  return [self extractValuesFromText:text withRegex:[TWRegex extractMentions] captureGroup:TWRegexGroupsExtractMentionUsername];
}

- (NSString *)extractReplyScreenname:(NSString *)text {
  NSArray* components = nil;
  
  if( [text length] > 0 ) {
    components = [text RKL_METHOD_PREPEND(captureComponentsMatchedByRegex):[TWRegex extractReply]];
  }
  
  if( [components count] > 0 ) {
    return [components objectAtIndex:TWRegexGroupsExtractReplyUsername];
  }
  
  return nil;
}

- (NSArray *)extractURLs:(NSString *)text {
  NSArray* matches = nil;
  
  if( [text length] > 0 ) {
    matches = [text RKL_METHOD_PREPEND(arrayOfCaptureComponentsMatchedByRegex):[TWRegex validURL]];
  }
  
  if( [matches count] > 0 ) {
    NSMutableArray* values = [NSMutableArray arrayWithCapacity:[matches count]];
    for( NSArray* match in matches ) {
      if( [[match objectAtIndex:TWRegexGroupsValidURLProtocol] length] > 0 ) {
        [values addObject:[match objectAtIndex:TWRegexGroupsValidURLURL]];
      }
    }
    return values;
  }
  
  return [NSArray array];
}

@end
