//
//  NSString+BoxAdditions.h
//  BoxSDK
//
//  Created on 6/3/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (BoxAdditions)

/**
 * Returns a readable string of the size of the item.
 */
+ (NSString *)humanReadableStringForByteSize:(NSNumber *)size;

@end
