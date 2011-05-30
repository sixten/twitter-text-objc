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
  return [self valuesFromMatchedEntities:[self extractMentionedScreennamesWithIndices:text]];
}

- (NSArray *)extractMentionedScreennamesWithIndices:(NSString *)text {
  if( [text length] == 0 ) {
    return [NSArray array];
  }
  
  NSString* pattern = [TWRegex extractMentions];
  NSRange searchRange = NSMakeRange(0, [text length]);
  NSMutableArray* values = [NSMutableArray array];
  
  while( YES ) {
    NSRange matchRange = [text RKL_METHOD_PREPEND(rangeOfRegex):pattern options:RKLNoOptions inRange:searchRange capture:0 error:NULL];
    if( matchRange.location == NSNotFound ) {
      break;
    }
    
    NSRange nameRange = [text RKL_METHOD_PREPEND(rangeOfRegex):pattern options:RKLNoOptions inRange:matchRange capture:TWRegexGroupsExtractMentionUsername error:NULL];
    NSRange afterRange = NSMakeRange(NSMaxRange(matchRange), 1);
    
    if( afterRange.location >= [text length] || ![[text substringWithRange:afterRange] RKL_METHOD_PREPEND(isMatchedByRegex):[TWRegex screenNameMatchEnd]] ) {
      TWEntity* entity = [[TWEntity alloc] initWithValue:[text substringWithRange:nameRange] rangeInText:NSMakeRange(nameRange.location-1, nameRange.length+1) type:TWEntityTypeMention];
      [values addObject:entity];
      [entity release];
    }
    
    searchRange = NSMakeRange(NSMaxRange(matchRange)-1, [text length] - NSMaxRange(matchRange)+1);
  }
  return values;
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
  return [self valuesFromMatchedEntities:[self extractURLsWithIndices:text]];
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
