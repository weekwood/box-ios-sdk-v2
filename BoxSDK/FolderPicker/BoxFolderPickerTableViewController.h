//
//  BoxFolderPickerViewController.h
//  FolderPickerSampleApp
//
//  Created on 5/1/13.
//  Copyright (c) 2013 Box Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class BoxFolderPickerViewController;
@class BoxItem;

@protocol BoxFolderPickerTableViewControllerDelegate <NSObject>

/**
 * Returns the number of items that needs to be displayed
 */
- (NSUInteger)currentNumberOfItems;

/**
 * Returns the number of items in the current folder (can be more that currentNumberOfItems because of the pagination).
 */
- (NSUInteger)totalNumberOfItems;

/**
 * Returns the item that needs to be displayed at the specified row
 */
- (BoxItem *)itemAtIndex:(NSUInteger)index;

/**
 * Starts downloading the next page of items
 */
- (void)loadNextSetOfItems;

/**
 * Returns the path where thumbnails need to be stored. Can be nil.
 */
- (NSString *)currentThumbnailPath;

/**
 * Returns whether the user wants to display thumbnails or not.
 */
- (BOOL)areThumbnailsEnabled;

/**
 * Returnes the OAuth2 Authorization URL
 */
- (NSURL *)currentAuthorizationURL;

/**
 * Returnes the OAuth2 Redirection URI
 */
- (NSString *)currentRedirectURI;

@end

@interface BoxFolderPickerTableViewController : UITableViewController

@property (nonatomic, readwrite, weak) BoxFolderPickerViewController *folderPicker;
@property (nonatomic, readwrite, weak) id<BoxFolderPickerTableViewControllerDelegate> delegate;

- (void)refreshData;

@end
