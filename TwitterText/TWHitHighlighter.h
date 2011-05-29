//
//  TWHitHighlighter.h
//  TwitterText
//
//  Created by Sixten Otto on 5/18/11.
//  Copyright 2011 Sixten Otto. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 * A class for adding HTML highlighting in Tweet text (such as would be returned from a Search)
 */
@interface TWHitHighlighter : NSObject
{
    
}

/** The current HTML tag used for hit highlighting; defaults to "em" */
@property (nonatomic, copy) NSString* tag;

/**
 * Surround the <code>hits</code> in the provided <code>text</code>
 * with an HTML tag. This is used with ranges from the search API
 * to support the highlighting of query terms.
 * 
 * The text may be auto-linked after the ranges are calculated: this
 * method will ignore any &lt;a> tags in the text when calculating
 * the offsets for the highlight tags.
 *
 * @param hits An array of ranges within the text to highlight
 * @param text The text of the Tweet to highlight
 * @return The text with highlight HTML added
 */
- (NSString *)highlightHits:(NSArray *)hits inText:(NSString *)text;

@end
