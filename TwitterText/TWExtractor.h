//
//  TWExtractor.h
//  TwitterText
//
//  Created by Sixten Otto on 5/14/11.
//  Copyright 2011 Results Direct. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 * A class to extract usernames, lists, hashtags and URLs from Tweet text.
 */
@interface TWExtractor : NSObject
{
    
}

/**
 * Extract #hashtag references from Tweet text.
 *
 * @param text The text of the tweet from which to extract hashtags
 * @return An array of hashtags referenced (without the leading # sign)
 */
- (NSArray *)extractHashtags:(NSString *)text;

/**
 * Extract #hashtag references from Tweet text.
 *
 * @param text The text of the tweet from which to extract hashtags
 * @return An array of TWEntity objects describing the hashtags referenced (without the leading # sign)
 */
- (NSArray *)extractHashtagsWithIndices:(NSString *)text;

/**
 * Extract @username references from Tweet text. A mention is an occurance of @username anywhere in a Tweet.
 *
 * @param text The text of the tweet from which to extract usernames
 * @return An array of usernames referenced (without the leading @ sign)
 */
- (NSArray *)extractMentionedScreennames:(NSString *)text;

/**
 * Extract a @username reference from the beginning of Tweet text. A reply is an occurance of @username at the
 * beginning of a Tweet, preceded by 0 or more spaces.
 *
 * @param text The text of the tweet from which to extract the replied to username
 * @return The username referenced, if any (without the leading @ sign). Returns nil if this is not a reply.
 */
- (NSString *)extractReplyScreenname:(NSString *)text;

/**
 * Extract URL references from Tweet text.
 *
 * @param text The text of the tweet from which to extract URLs
 * @return An array of URLs referenced.
 */
- (NSArray *)extractURLs:(NSString *)text;

@end
