//
//  TWEntity.m
//  TwitterText
//
//  Created by Sixten Otto on 5/15/11.
//  Copyright 2011 Sixten Otto. All rights reserved.
//

#import "TWEntity.h"


@implementation TWEntity

@synthesize value = tw_value;
@synthesize rangeInText = tw_rangeInText;
@synthesize type = tw_type;

- (void)dealloc {
  [tw_value release];
  [super dealloc];
}

- (NSString *)description {
  return [NSString stringWithFormat:@"<%@: %p> { range = %@, value = '%@' }", [self class], self, NSStringFromRange(self.rangeInText), self.value];
}

- (BOOL)isEqual:(id)object {
  if( self == object ) return YES;
  if( !object || ![[object class] isEqual:[TWEntity class]] ) return NO;
  TWEntity* other = object;
  return [tw_value isEqualToString:other->tw_value]
    && NSEqualRanges(tw_rangeInText, other->tw_rangeInText)
    && tw_type == other->tw_type;
}

- (NSUInteger)hash {
  NSUInteger hash = 17;
  hash = hash * 23 + [tw_value hash];
  hash = hash * 23 + tw_rangeInText.location;
  hash = hash * 23 + tw_rangeInText.length;
  hash = hash * 23 + tw_type;
  return hash;
}

@end
