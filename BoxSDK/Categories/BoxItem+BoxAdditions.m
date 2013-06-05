//
//  BoxItem+BoxAdditions.m
//  BoxSDK
//
//  Created on 6/4/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import "BoxItem+BoxAdditions.h"
#import "UIImage+BoxAdditions.h"

@implementation BoxItem (BoxAdditions)

- (UIImage *)icon
{
    
    UIImage *icon = nil;

    
    if ([self isKindOfClass:[BoxFolder class]])
    {
        icon = [UIImage imageFromBoxSDKResourcesBundleWithName:@"folder"];
        return icon;
    }
    
    NSString *extension = [[self.name pathExtension] lowercaseString];
    
    if ([extension isEqualToString:@"docx"]) 
    {
        extension = @"doc";
    }
    if ([extension isEqualToString:@"pptx"]) 
    {
        extension = @"ppt";
    }
    if ([extension isEqualToString:@"xlsx"]) 
    {
        extension = @"xls";
    }
    if ([extension isEqualToString:@"html"]) 
    {
        extension = @"htm";
    }
    if ([extension isEqualToString:@"jpeg"])
    {
        extension = @"jpg";
    }
    
    icon = [UIImage  imageFromBoxSDKResourcesBundleWithName:extension];
    
    if (!icon)
    {
        icon = [UIImage  imageFromBoxSDKResourcesBundleWithName:@"generic"];
    }
    
    return icon;
}

@end
