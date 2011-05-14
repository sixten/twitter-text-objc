//
//  TWExtractor.h
//  TwitterText
//
//  Created by Sixten Otto on 5/14/11.
//  Copyright 2011 Results Direct. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TWExtractor : NSObject
{
    
}

- (NSArray *)extractHashtags:(NSString *)text;

- (NSArray *)extractHashtagsWithIndices:(NSString *)text;

- (NSArray *)extractMentionedScreennames:(NSString *)text;

- (NSString *)extractReplyScreenname:(NSString *)text;

- (NSArray *)extractURLs:(NSString *)text;

@end
