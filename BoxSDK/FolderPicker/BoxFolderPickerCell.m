//
//  BoxFolderPickerCell.m
//  BoxSDK
//
//  Created on 5/30/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import "UIImage+BoxAdditions.h"
#import "NSString+BoxAdditions.h"

#import "BoxFolderPickerCell.h"
#import "BoxItem.h"
#import "BoxFolder.h"
#import "BoxFolderPickerHelper.h"
#import "BoxSDK.h"

#import <QuartzCore/QuartzCore.h>

#define kCellHeight 58.0

#define kImageViewOffsetX 12.0
#define kImageViewSide 40.0

#define kImageToLabelOffsetX 12.0
#define kNameStringOriginY 11.0
#define kNameStringHeight 20.0

#define kPaddingNameDescription 20.0
#define kDisclosureIndicatorOriginY 23.0

#define kDisabledAlpha 0.3

// @TODO: change this #define to NSLineBreakByTruncatingMiddle once iOS 7 SDK is released.
#define BOX_LINE_BREAK_MODE (5) // UILineBreakModeMiddleTruncation and NSLineBreakByTruncatingMiddle

@interface BoxFolderPickerCell ()

@property (nonatomic, readwrite, strong) UIImageView *thumbnailImageView;

@end

@implementation BoxFolderPickerCell

@synthesize thumbnailImageView = _thumbnailImageView;
@synthesize item = _item;
@synthesize cachePath = _cachePath;
@synthesize showThumbnails;
@synthesize enabled = _enabled;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        CGRect r = CGRectMake(0, 0, kImageViewSide, kImageViewSide);
        r.origin.y = (kCellHeight / 2) - (kImageViewSide / 2) -1;
        r.origin.x = kImageViewOffsetX;
        _thumbnailImageView = [[UIImageView alloc] initWithFrame:r];
        
        _thumbnailImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_thumbnailImageView];
    }
    return self;
}

- (void)setItem:(BoxItem *)item
{
    if (item == nil || self.item == item) {
        return ;
    }
    
    _item = item;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGRect r = self.thumbnailImageView.frame;
    
    NSString *cachedThumbnailPath = [self.cachePath stringByAppendingPathComponent:self.item.modelID];
    
    [[BoxFolderPickerHelper sharedHelper] itemNeedsAPICall:self.item cachePath:cachedThumbnailPath completion:^(BOOL needsAPICall, UIImage *cachedImage) {
        
        self.thumbnailImageView.image = cachedImage;
        
        // Checking if we need to download the thumbnail for the current item 
        if ([[BoxFolderPickerHelper sharedHelper] shouldDiplayThumbnailForItem:self.item] && needsAPICall && showThumbnails) {
            __block BoxFolderPickerCell *cell = self;
            __block BoxItem *currentItem = self.item;
            
            [[BoxFolderPickerHelper sharedHelper] thumbnailForItem:self.item cachePath:self.cachePath refreshed:^(UIImage *image) {
                if (image && cell.item == currentItem) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [cell.thumbnailImageView setImage:image];
                        
                        CATransition *transition = [CATransition animation];
                        transition.duration = 0.3f;
                        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                        transition.type = kCATransitionFade;
                        
                        [cell.thumbnailImageView.layer addAnimation:transition forKey:nil];
                    });
                }
            }];
        }
    }];
    
    // Drawing name label
    if (self.item.name) {
        // Positionnning the name label by offset from the image
        r.origin.x += kImageViewSide + kImageToLabelOffsetX;
        r.origin.y += 4.0;
        r.size.height = kNameStringHeight;
        r.size.width = rect.size.width - kImageToLabelOffsetX - kImageViewSide - kImageViewOffsetX - 24.0;
        
        [[UIColor colorWithRed:86.0f/255.0f green:86.0f/255.0f blue:86.0f/255.0f alpha:self.enabled ? 1.0 : kDisabledAlpha] set];
        [self.item.name drawInRect:r withFont:[UIFont boldSystemFontOfSize:16.0] lineBreakMode:BOX_LINE_BREAK_MODE];
    }
    
    r.origin.y += kPaddingNameDescription;
    
    NSString * desc = [NSString stringWithFormat:@"%@ - Last update : %@", [NSString humanReadableStringForByteSize:self.item.size], [[BoxFolderPickerHelper sharedHelper] dateStringForItem:self.item]];
    
    if(desc){
        [[UIColor colorWithRed:174.0f/255.0f green:174.0f/255.0f blue:174.0f/255.0f alpha:self.enabled ? 1.0 : kDisabledAlpha] set];
        [desc drawInRect:r withFont:[UIFont boldSystemFontOfSize:12.0] lineBreakMode:BOX_LINE_BREAK_MODE];
    }
    
    // If the item is a folder, draw the disclosure indicator
    if ([self.item isKindOfClass:[BoxFolder class]]) {
        r.origin.x = rect.size.width - 15;
        r.origin.y = kDisclosureIndicatorOriginY;
        
        [[UIImage  imageFromBoxSDKResourcesBundleWithName:@"icon-disclosure"] drawAtPoint:r.origin];
    }
    
    self.thumbnailImageView.alpha = self.enabled ? 1.0 : kDisabledAlpha;
}

@end
