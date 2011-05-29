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
  if( [hits count] == 0 ) return [[text copy] autorelease];
  
  NSArray* sortedRanges = [hits sortedArrayUsingFunction:&rangeSort context:NULL];
  NSMutableString* highlighted = [text mutableCopy];
  NSMutableArray* anchors = [[NSMutableArray alloc] init];
  
  NSUInteger index = 0;   // where in the (virtual) text we are
  NSUInteger aChars = 0;  // how many characters of anchors passed so far
  NSUInteger hiChars = 0; // how many characters of highlights inserted so far
  
  // first, map out all of the anchor tag ranges between the start of the string and the end of the last hit
  NSRange lastRange = [[sortedRanges lastObject] rangeValue];
  while( index < NSMaxRange(lastRange) ) {
    NSRange searchRange = NSMakeRange(index + aChars, [text length] - index - aChars);
    NSRange anchorRange = [text rangeOfString:@"</?a[^>]*>" options:(NSRegularExpressionSearch|NSCaseInsensitiveSearch) range:searchRange];
    if( anchorRange.location == NSNotFound ) {
      break;
    }
    
    [anchors addObject:[NSValue valueWithRange:anchorRange]];
    index = anchorRange.location - aChars;
    aChars += anchorRange.length;
  }
  //NSLog(@"extracted from »%@« these anchors: %@", text, anchors);
  
  // now loop over the hit ranges, using the map to skip over anchor tags in the text
  NSUInteger currentAnchor = 0;
  index = 0;
  aChars = 0;
  
  for( NSValue* val in sortedRanges ) {
    NSRange hit = [val rangeValue];
    NSUInteger gap = 0;
    NSUInteger passed = 0;
    
    // watch for bad hits
    if( hit.location + aChars > [text length] )
      [[NSException exceptionWithName:NSRangeException
                               reason:@"Specified highlight range outside the bounds of the text"
                             userInfo:[NSDictionary dictionaryWithObjectsAndKeys:val, @"hit", text, @"text", nil]]
        raise];
    
    // count over any anchors between the end of the last hit, and the start of the current one
    gap = 0;
    passed = 0;
    while( currentAnchor < [anchors count] ) {
      NSRange anchorRange = [[anchors objectAtIndex:currentAnchor] rangeValue];
      if( anchorRange.location > hit.location + aChars + gap ) break;
      gap += anchorRange.length;
      currentAnchor++;
      passed++;
    }
    
    // add the gap string and the start tag to the new string
    index = hit.location;
    aChars += gap;
    [highlighted insertString:self.startTag atIndex:index+aChars+hiChars];
    hiChars += [self.startTag length];
    
    // watch for over-run
    if( hit.location + hit.length + aChars + hiChars > [highlighted length] ) {
      [highlighted appendString:self.endTag];
      break;
    }
    
    // count over any anchors between the start and end of the hit
    gap = 0;
    passed = 0;
    while( currentAnchor < [anchors count] ) {
      NSRange anchorRange = [[anchors objectAtIndex:currentAnchor] rangeValue];
      NSUInteger threshold = hit.location + hit.length + aChars + gap;
      if( anchorRange.location > threshold || anchorRange.location == threshold && passed % 2 == 0 ) break;
      gap += anchorRange.length;
      currentAnchor++;
      passed++;
    }
    
    // add the hit string and the end tag to the new string
    index = NSMaxRange(hit);
    aChars += gap;
    [highlighted insertString:self.endTag atIndex:index+aChars+hiChars];
    hiChars += [self.endTag length];
  }
  
  NSString* result = [[highlighted copy] autorelease];
  [highlighted release];
  [anchors release];
  
  return result;
}

@end
