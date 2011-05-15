//
//  TWEntity.h
//  TwitterText
//
//  Created by Sixten Otto on 5/15/11.
//  Copyright 2011 Sixten Otto. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
  TWEntityTypeHashtag
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

@property (nonatomic, copy)   NSString*    value;
@property (nonatomic, assign) NSRange      rangeInText;
@property (nonatomic, assign) TWEntityType type;

@end