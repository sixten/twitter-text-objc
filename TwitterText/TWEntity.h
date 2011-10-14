//
//  TWEntity.h
//  TwitterText
//
//  Created by Sixten Otto on 5/15/11.
//  Copyright 2011 Sixten Otto. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
  TWEntityTypeHashtag,
  TWEntityTypeURL,
  TWEntityTypeMention,
} TWEntityType;


/**
 * Encapsulates a single extracted value
 */
@interface TWEntity : NSObject
{
  NSString*    tw_value;
  NSRange      tw_rangeInText;
  TWEntityType tw_type;
}

@property (nonatomic, copy,   readonly) NSString*    value;
@property (nonatomic, assign, readonly) NSRange      rangeInText;
@property (nonatomic, assign, readonly) TWEntityType type;

+ (TWEntity *)entityWithValue:(NSString *)value rangeInText:(NSRange)range type:(TWEntityType)type;

@end


/**
 * Encapsulates a single user mention. The extractor won't populate the
 * additional properties, but a mention returned by the Twitter API will have
 * that information.
 */
@interface TWMentionEntity : TWEntity
{
  NSString* tw_name;
  NSNumber* tw_userID;
}

@property (nonatomic, copy)   NSString* screenName;
@property (nonatomic, copy)   NSString* name;
@property (nonatomic, retain) NSNumber* userID;

@end


/**
 * Encapsulates a single URL. The extractor won't populate the additional
 * properties, but a URL returned by the Twitter API will have that information.
 */
@interface TWURLEntity : TWEntity
{
  NSString* tw_expandedURL;
  NSString* tw_displayURL;
}

@property (nonatomic, copy) NSString* URL;
@property (nonatomic, copy) NSString* expandedURL;
@property (nonatomic, copy) NSString* displayURL;

@end
