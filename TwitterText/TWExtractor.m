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
  if( [text length] == 0 ) {
    return [NSArray array];
  }
  
  NSRange searchRange = NSMakeRange(0, [text length]);
  NSMutableArray* values = [NSMutableArray array];
  
  while( YES ) {
    NSRange matchRange = [text RKL_METHOD_PREPEND(rangeOfRegex):pattern options:RKLNoOptions inRange:searchRange capture:capture error:NULL];
    if( matchRange.location == NSNotFound ) {
      break;
    }
    
    TWEntity* entity = [[TWEntity alloc] initWithValue:[text substringWithRange:matchRange] rangeInText:matchRange type:type];
    [values addObject:entity];
    [entity release];
    
    searchRange = NSMakeRange(NSMaxRange(matchRange), [text length] - NSMaxRange(matchRange));
  }
  return values;
}


#pragma mark - public methods

- (NSArray *)extractHashtags:(NSString *)text {
  return [self extractValuesFromText:text withRegex:[TWRegex autoLinkHashtags] captureGroup:TWRegexGroupsAutoLinkHashtagTag];
}

- (NSArray *)extractHashtagsWithIndices:(NSString *)text {
  if( [text length] == 0 ) {
    return [NSArray array];
  }
  
  NSString* pattern = [TWRegex autoLinkHashtags];
  NSRange searchRange = NSMakeRange(0, [text length]);
  NSMutableArray* values = [NSMutableArray array];
  
  while( YES ) {
    NSRange matchRange = [text RKL_METHOD_PREPEND(rangeOfRegex):pattern options:RKLNoOptions inRange:searchRange capture:0 error:NULL];
    if( matchRange.location == NSNotFound ) {
      break;
    }
    
    NSRange hashRange = [text RKL_METHOD_PREPEND(rangeOfRegex):pattern options:RKLNoOptions inRange:matchRange capture:TWRegexGroupsAutoLinkHashtagHash error:NULL];
    NSRange tagRange = [text RKL_METHOD_PREPEND(rangeOfRegex):pattern options:RKLNoOptions inRange:matchRange capture:TWRegexGroupsAutoLinkHashtagTag error:NULL];
    
    TWEntity* entity = [[TWEntity alloc] initWithValue:[text substringWithRange:tagRange] rangeInText:NSMakeRange(hashRange.location, NSMaxRange(tagRange) - hashRange.location) type:TWEntityTypeHashtag];
    [values addObject:entity];
    [entity release];
    
    searchRange = NSMakeRange(NSMaxRange(matchRange), [text length] - NSMaxRange(matchRange));
  }
  return values;
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

- (NSArray *)extractURLsWithIndices:(NSString *)text {
  if( [text length] == 0 ) {
    return [NSArray array];
  }
  
  NSString* pattern = [TWRegex validURL];
  NSRange searchRange = NSMakeRange(0, [text length]);
  NSMutableArray* values = [NSMutableArray array];
  
  while( YES ) {
    NSRange matchRange = [text RKL_METHOD_PREPEND(rangeOfRegex):pattern options:RKLNoOptions inRange:searchRange capture:0 error:NULL];
    if( matchRange.location == NSNotFound ) {
      break;
    }
    
    NSRange protocolRange = [text RKL_METHOD_PREPEND(rangeOfRegex):pattern options:RKLNoOptions inRange:matchRange capture:TWRegexGroupsValidURLProtocol error:NULL];
    
    if( protocolRange.location != NSNotFound && protocolRange.length > 0 ) {
      NSRange URLRange = [text RKL_METHOD_PREPEND(rangeOfRegex):pattern options:RKLNoOptions inRange:matchRange capture:TWRegexGroupsValidURLURL error:NULL];
      
      TWEntity* entity = [[TWEntity alloc] initWithValue:[text substringWithRange:URLRange] rangeInText:URLRange type:TWEntityTypeURL];
      [values addObject:entity];
      [entity release];
    }
    
    searchRange = NSMakeRange(NSMaxRange(matchRange), [text length] - NSMaxRange(matchRange));
  }
  return values;
}

@end
