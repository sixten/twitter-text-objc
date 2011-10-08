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

- (NSArray *)valuesFromMatchedEntities:(NSArray *)matches {
  NSMutableArray* results = [NSMutableArray arrayWithCapacity:[matches count]];
  for( TWEntity* entity in matches ) {
    [results addObject:entity.value];
  }
  return results;
}


#pragma mark - public methods

- (NSArray *)extractHashtags:(NSString *)text {
  return [self valuesFromMatchedEntities:[self extractHashtagsWithIndices:text]];
}

- (NSArray *)extractHashtagsWithIndices:(NSString *)text {
  if( [text length] == 0 ) {
    return [NSArray array];
  }
  
  NSString* pattern = [TWRegex autoLinkHashtags];
  __block NSMutableArray* values = [NSMutableArray array];
  
  [text rkl_enumerateStringsMatchedByRegex:pattern options:RKLNoOptions inRange:NSMakeRange(0, [text length]) error:NULL enumerationOptions:RKLRegexEnumerationFastCapturedStringsXXX usingBlock:^(NSInteger captureCount, NSString *const *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
    // the capture groups don't quite line up with the range we want to report
    NSRange valueRange = capturedRanges[TWRegexGroupsAutoLinkHashtagHash];
    valueRange.length = NSMaxRange(capturedRanges[TWRegexGroupsAutoLinkHashtagTag]) - valueRange.location;
    
    // the entity's value is a copy property; we need to be careful while using RKLRegexEnumerationFastCapturedStringsXXX
    TWEntity* entity = [[TWEntity alloc] initWithValue:capturedStrings[TWRegexGroupsAutoLinkHashtagTag] rangeInText:valueRange type:TWEntityTypeHashtag];
    [values addObject:entity];
    [entity release];
  }];

  return values;
}


- (NSArray *)extractMentionedScreennames:(NSString *)text {
  return [self valuesFromMatchedEntities:[self extractMentionedScreennamesWithIndices:text]];
}

- (NSArray *)extractMentionedScreennamesWithIndices:(NSString *)text {
  if( [text length] == 0 ) {
    return [NSArray array];
  }

  NSString* pattern = [TWRegex extractMentions];
  __block NSMutableArray* values = [NSMutableArray array];
  
  [text rkl_enumerateStringsMatchedByRegex:pattern options:RKLNoOptions inRange:NSMakeRange(0, [text length]) error:NULL enumerationOptions:RKLRegexEnumerationFastCapturedStringsXXX usingBlock:^(NSInteger captureCount, NSString *const *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
    NSRange afterRange = NSMakeRange(NSMaxRange(capturedRanges[TWRegexGroupsAutoLinkHashtagEntireMatch]), 1);;
    
    if( afterRange.location >= [text length] || ![[text substringWithRange:afterRange] rkl_isMatchedByRegex:[TWRegex screenNameMatchEnd]] ) {
      // the capture groups don't quite line up with the range we want to report
      NSRange nameRange = capturedRanges[TWRegexGroupsExtractMentionUsername];
      --nameRange.location;
      ++nameRange.length;
      
      // the entity's value is a copy property; we need to be careful while using RKLRegexEnumerationFastCapturedStringsXXX
      TWEntity* entity = [[TWEntity alloc] initWithValue:capturedStrings[TWRegexGroupsExtractMentionUsername] rangeInText:nameRange type:TWEntityTypeMention];
      [values addObject:entity];
      [entity release];
    }
  }];

  return values;
}


- (NSString *)extractReplyScreenname:(NSString *)text {
  NSArray* components = nil;
  
  if( [text length] > 0 ) {
    components = [text rkl_captureComponentsMatchedByRegex:[TWRegex extractReply]];
  }
  
  if( [components count] > 0 ) {
    return [components objectAtIndex:TWRegexGroupsExtractReplyUsername];
  }
  
  return nil;
}


- (NSArray *)extractURLs:(NSString *)text {
  return [self valuesFromMatchedEntities:[self extractURLsWithIndices:text]];
}

- (NSArray *)extractURLsWithIndices:(NSString *)text {
  if( [text length] == 0 ) {
    return [NSArray array];
  }
  
  NSString* pattern = [TWRegex validURL];
  __block NSMutableArray* values = [NSMutableArray array];
  
  [text rkl_enumerateStringsMatchedByRegex:pattern options:RKLNoOptions inRange:NSMakeRange(0, [text length]) error:NULL enumerationOptions:RKLRegexEnumerationFastCapturedStringsXXX usingBlock:^(NSInteger captureCount, NSString *const *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
    // the entity's value is a copy property; we need to be careful while using RKLRegexEnumerationFastCapturedStringsXXX
    TWEntity* entity = [[TWEntity alloc] initWithValue:capturedStrings[TWRegexGroupsValidURLURL] rangeInText:capturedRanges[TWRegexGroupsValidURLURL] type:TWEntityTypeURL];
    [values addObject:entity];
    [entity release];
  }];
  
  return values;
}

@end
