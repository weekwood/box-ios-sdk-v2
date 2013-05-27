//
//  BoxFolderPickerHelper.h
//  FolderPickerSampleApp
//
//  Created on 5/1/13.
//  Copyright (c) 2013 Box Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class BoxItem;
@class BoxFile;

typedef void (^BoxThumbnailDownloadBlock)(UIImage *image, NSIndexPath *indexPath);

@interface BoxFolderPickerHelper : NSObject

+ (BoxFolderPickerHelper *)sharedHelper;

/**
 * Returns the icon corresponding to the item's file type.
 */
- (UIImage *)iconForItem:(BoxItem *)item;

/**
 * Returns a readable string of the size of the item.
 */
- (NSString *)sizeForItem:(BoxItem *)item;

/**
 * Returns a readable string of the last update date of the item.
 */
- (NSString *)dateStringForItem:(BoxItem *)item;

/**
 * Downloads the thumbnail of the specified path.
  * @param file. The thumbnail's corresponding file.
  * @param cachePath. The path where to look for and cache the thumbnail.
  * @param cached. Callback returning the cached image if it exists, otherwise the file's icon.
  * @param refreshed. Callback returning the refreshed cached image, retrieved via the API.
 */
- (void)thumbnailForFile:(BoxFile *)file 
                    cachePath:(NSString *)cachePath
                       cached:(BoxThumbnailDownloadBlock)cached 
               refreshed:(BoxThumbnailDownloadBlock)refreshed indexPath:(NSIndexPath *)indexPath;

/**
 * Returns whether the file needs to get a thumbnail, according its file type.
 */
- (BOOL)shouldDiplayThumbnailForItem:(BoxItem *)item;

/**
 * Cancels all occuring thumbnail download operations.
 */
- (void)cancelThumbnailOperations;

/**
 * Purges the dictionnary containing the in-memory thumbnail images. No op if the user uses cached files on disk.
 */
- (void)purgeInMemoryCache;

/**
 * Requeues all operations that failed after token expiration.
 */
- (void)retryOperationsAfterTokenRefresh;

@end
