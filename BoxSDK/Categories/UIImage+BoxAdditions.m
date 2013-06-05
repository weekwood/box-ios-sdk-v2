//
//  UIImage+BoxAdditions.m
//  BoxSDK
//
//  Created on 6/3/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import "UIImage+BoxAdditions.h"
#import "BoxSDK.h"
#import <UIKit/UIKit.h>

@implementation UIImage (BoxAdditions)

+ (UIImage *) imageFromBoxSDKResourcesBundleWithName:(NSString *)string
{
    NSBundle *bundle = [BoxSDK resourcesBundle];
    NSString *str = [[bundle resourcePath] stringByAppendingPathComponent:[bundle pathForResource:string ofType:nil]];
    return [UIImage imageWithContentsOfFile:[str stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", string]]];
}

@end
