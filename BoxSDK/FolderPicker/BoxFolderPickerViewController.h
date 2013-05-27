//
//  BoxFolderPickerViewController.h
//  FolderPickerSampleApp
//
//  Created on 5/1/13.
//  Copyright (c) 2013 Box Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "BoxFolderPickerTableViewController.h"
#import "BoxAuthorizationViewController.h"


@class BoxFolder;
@class BoxFile;

@protocol BoxFolderPickerDelegate <NSObject>

/**
 * The user has selected a file.
 * @param file. The file picked by the user. 
 */
- (void)folderPickerDidSelectBoxFile:(BoxFile *)file;

/**
 * The user has selected a folder.
 * @param folder. The folder picked by the user. 
 */
- (void)folderPickerDidSelectBoxFolder:(BoxFolder *)folder;

/**
 * The user wants do dismiss the folderPicker
 */
- (void)folderPickerWillClose;

@end

@interface BoxFolderPickerViewController : UIViewController <BoxFolderPickerTableViewControllerDelegate, BoxAuthorizationViewControllerDelegate>

@property (nonatomic, readwrite, weak) id<BoxFolderPickerDelegate> delegate;


/**
 * Allows you to customize the number of items that will be downloaded in a row.
 * Default value in 100.
 */
@property (nonatomic, readwrite, assign) NSUInteger numberOfItemsPerPage;

/**
 * Initializes a folderPicker according to the caching options provided as parameters
 *
 * @param authorizationURL The authorization URL to load
 * @param redirectURI The OAuth2 redirect URI string, used to detect the OAuth2
 * @param folderID. The root folder where to start browsing.
 * @param thumbnailsEnabled. Enables/disables thumbnail management. If set to NO, only file icons will be displayed
 * @param cachedThumbnailsPath. The absolute path where the user wants to store the cached thumbnails. 
 *                              If set to nil, the folder picker will not cached the thumbnails, only download them on the fly.
 If not set to nil, the folder picker will cache the thumbnails at this path
 Not used if thumbnailsEnabled set to NO.
 * @return A BoxFolderPickerViewController.
 */
- (id)initWithAutorizationURL:(NSURL *)url 
                  redirectURI:(NSString *)redirectURI
                 rootFolderID:(NSString *)rootFolderID 
             enableThumbnails:(BOOL)thumbnailsEnabled 
         cachedThumbnailsPath:(NSString *)cachedThumbnailsPath;

/**
 * Purges the cache folder precised in the cachedThumbnailsPath parameter of the initWithFolderID: enableThumbnails: cachedThumbnailsPath: method.
 */
- (void)purgeCache;

@end
