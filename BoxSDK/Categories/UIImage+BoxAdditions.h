//
//  UIImage+BoxAdditions.h
//  BoxSDK
//
//  Created on 6/3/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (BoxAdditions)

/**
 * Retrieves assets embedded in the ressource bundle.
 */
+ (UIImage *)imageFromBoxSDKResourcesBundleWithName:(NSString *)string;

@end