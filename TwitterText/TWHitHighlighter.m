//
//  TWHitHighlighter.m
//  TwitterText
//
//  Created by Sixten Otto on 5/18/11.
//  Copyright 2011 Sixten Otto. All rights reserved.
//

#import "TWHitHighlighter.h"

NSComparisonResult rangeSort(id r1, id r2, void *context)
{
  NSRange v1 = [r1 rangeValue];
  NSRange v2 = [r2 rangeValue];
  if (v1.location < v2.location)
    return NSOrderedAscending;
  else if (v1.location > v2.location)
    return NSOrderedDescending;
  else if (v1.length < v2.length)
    return NSOrderedAscending;
  else if (v1.length > v2.length)
    return NSOrderedDescending;
  else
    return NSOrderedSame;
}

@interface TWHitHighlighter ()

@property (nonatomic, retain) NSString* startTag;
@property (nonatomic, retain) NSString* endTag;

@end


@implementation TWHitHighlighter

@synthesize tag = tw_tag;
@synthesize startTag = tw_startTag;
@synthesize endTag = tw_endTag;

- (id)init {
  self = [super init];
  if (self) {
    self.tag = @"em";
  }
  return self;
}

- (void)dealloc {
  [tw_tag release];
  [tw_startTag release];
  [tw_endTag release];
  [super dealloc];
}

- (void)setTag:(NSString *)tag {
  [tw_tag autorelease];
  tw_tag = [tag copy];
  self.startTag = [NSString stringWithFormat:@"<%@>", tw_tag];
  self.endTag   = [NSString stringWithFormat:@"</%@>", tw_tag];
}

- (NSString *)highlightHits:(NSArray *)hits inText:(NSString *)text {
  NSArray* sortedRanges = [hits sortedArrayUsingFunction:&rangeSort context:NULL];
  NSMutableString* highlighted = [text mutableCopy];
  
  for( NSValue* val in [sortedRanges reverseObjectEnumerator] ) {
    NSRange hit = [val rangeValue];
    NSUInteger end = MIN(NSMaxRange(hit), [highlighted length]);
    if( hit.location > [highlighted length] ) continue;
    
    [highlighted insertString:self.endTag   atIndex:end];
    [highlighted insertString:self.startTag atIndex:hit.location];
  }
  
  NSString* result = [[highlighted copy] autorelease];
  [highlighted release];
  
  return result;
}

@end
