//
//  TWEntity.m
//  TwitterText
//
//  Created by Sixten Otto on 5/15/11.
//  Copyright 2011 Sixten Otto. All rights reserved.
//

#import "TWEntity.h"


@interface TWEntity ()

@property (nonatomic, copy)   NSString*    value;
@property (nonatomic, assign) NSRange      rangeInText;
@property (nonatomic, assign) TWEntityType type;

- (id)initWithValue:(NSString *)value rangeInText:(NSRange)range type:(TWEntityType)type;

@end


@implementation TWEntity

@synthesize value = tw_value;
@synthesize rangeInText = tw_rangeInText;
@synthesize type = tw_type;


+ (TWEntity *)entityWithValue:(NSString *)value rangeInText:(NSRange)range type:(TWEntityType)type {
  Class class = [TWEntity class];
  if( type == TWEntityTypeMention ) {
    class = [TWMentionEntity class];
  }
  else if( type == TWEntityTypeURL ) {
    class = [TWURLEntity class];
  }
  
  return [[[class alloc] initWithValue:value rangeInText:range type:type] autorelease];
}

- (id)initWithValue:(NSString *)value rangeInText:(NSRange)range type:(TWEntityType)type {
  self = [super init];
  if( self != nil ) {
    self.value = value;
    self.rangeInText = range;
    self.type = type;
  }
  return self;
}

- (void)dealloc {
  [tw_value release];
  [super dealloc];
}

- (NSString *)description {
  return [NSString stringWithFormat:@"<%@: %p> { range = %@, value = '%@' }", [self class], self, NSStringFromRange(self.rangeInText), self.value];
}

- (BOOL)isEqual:(id)object {
  if( self == object ) return YES;
  if( !object || ![[object class] isEqual:[self class]] ) return NO;
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


@implementation TWMentionEntity

@synthesize name = tw_name;
@synthesize userID = tw_userID;

- (void)dealloc {
  [tw_name release];
  [tw_userID release];
  [super dealloc];
}

- (NSString *)screenName {
  return self.value;
}

- (void)setScreenName:(NSString *)screenName {
  self.value = screenName;
}

@end


@implementation TWURLEntity

@synthesize expandedURL = tw_expandedURL;
@synthesize displayURL = tw_displayURL;

- (void)dealloc {
  [tw_expandedURL release];
  [tw_displayURL release];
  [super dealloc];
}

- (NSString *)URL {
  return self.value;
}

- (void)setURL:(NSString *)URL {
  self.value = URL;
}

@end
