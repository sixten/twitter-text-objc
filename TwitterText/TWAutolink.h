//
//  TWAutolink.h
//  TwitterText
//
//  Created by Sixten Otto on 5/18/11.
//  Copyright 2011 Sixten Otto. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Default CSS class for auto-linked URLs */
extern NSString *const TWAutolinkDefaultURLClass;

/** Default CSS class for auto-linked list URLs */
extern NSString *const TWAutolinkDefaultListClass;

/** Default CSS class for auto-linked username URLs */
extern NSString *const TWAutolinkDefaultUsernameClass;

/** Default CSS class for auto-linked hashtag URLs */
extern NSString *const TWAutolinkDefaultHashtagClass;

/** Default href for username links (the username without the @ will be appended) */
extern NSString *const TWAutolinkDefaultUsernameURLBase;

/** Default href for list links (the username/list without the @ will be appended) */
extern NSString *const TWAutolinkDefaultListURLBase;

/** Default href for hashtag links (the hashtag without the # will be appended) */
extern NSString *const TWAutolinkDefaultHashtagURLBase;

/** HTML attribute to add when noFollow is true (default) */
extern NSString *const TWAutolinkNoFollowAttribute;


/**
 * A class for adding HTML links to hashtag, username and list references in Tweet text.
 */
@interface TWAutolink : NSObject
{
    
}

/**
 * The CSS class for auto-linked URLs
 */
@property (nonatomic, copy) NSString* urlClass;

/**
 * The CSS class for auto-linked list URLs
 */
@property (nonatomic, copy) NSString* listClass;

/**
 * The CSS class for auto-linked username URLs
 */
@property (nonatomic, copy) NSString* usernameClass;

/**
 * The CSS class for auto-linked hashtag URLs
 */
@property (nonatomic, copy) NSString* hashtagClass;

/**
 * The href value for username links (to which the username will be appended)
 */
@property (nonatomic, copy) NSString* usernameUrlBase;

/**
 * The href value for list links (to which the username/list will be appended)
 */
@property (nonatomic, copy) NSString* listUrlBase;

/**
 * The href value for hashtag links (to which the hashtag will be appended)
 */
@property (nonatomic, copy) NSString* hashtagUrlBase;

/**
 * Whether the current URL links will include rel="nofollow" (YES by default)
 */
@property (nonatomic, assign) BOOL noFollow;


/**
 * Auto-link hashtags, URLs, usernames and lists.
 *
 * @param text The text of the Tweet to auto-link
 * @return The text with auto-link HTML added
 */
- (NSString *)autoLink:(NSString *)text;

/**
 * Auto-link the @username and @username/list references in the provided text. Links to @username references will
 * have the usernameClass CSS classes added. Links to @username/list references will have the listClass CSS class
 * added.
 *
 * @param text The text of the Tweet to auto-link
 * @return The text with auto-link HTML added
 */
- (NSString *)autoLinkUsernamesAndLists:(NSString *)text;

/**
 * Auto-link #hashtag references in the provided Tweet text. The #hashtag links will have the hashtagClass CSS class
 * added.
 *
 * @param text The text of the Tweet to auto-link
 * @return The text with auto-link HTML added
 */
- (NSString *)autoLinkHashtags:(NSString *)text;

/**
 * Auto-link URLs in the Tweet text provided.
 *
 * @param text The text of the Tweet to auto-link
 * @return The text with auto-link HTML added
 */
- (NSString *)autoLinkURLs:(NSString *)text;

/**
 * Convert any HTML metacharacters in the given string to HTML
 * escape sequences (preferably named entities, when possible).
 *
 * @param text The text of the Tweet to escape
 * @return The text with escaped characters
 */
- (NSString *)stringByEscapingHTMLMetacharactersInString:(NSString *)text;

@end
