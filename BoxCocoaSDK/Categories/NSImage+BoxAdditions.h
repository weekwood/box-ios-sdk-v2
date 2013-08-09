//
//  NSImage+BoxAdditions.h
//  BoxSDK
//
//  Created on 7/29/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/**
 * The BoxAdditions category on NSImage provides a method for loading
 * images from the BoxSDK resources bundle.
 */
@interface NSImage (BoxAdditions)

/**
 * Retrieves assets embedded in the ressource bundle.
 *
 * @param string Image name.
 */

+ (NSImage *)imageFromBoxSDKResourcesBundleWithName:(NSString *)string;

@end
