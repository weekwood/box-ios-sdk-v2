//
//  BoxFolderPickerViewController.m
//  FolderPickerSampleApp
//
//  Created on 5/1/13.
//  Copyright (c) 2013 Box Inc. All rights reserved.
//

#import "BoxFolderPickerTableViewController.h"
#import "BoxSDK.h"

@implementation BoxFolderPickerTableViewController

@synthesize folderPicker = _folderPicker;
@synthesize delegate = _delegate;

- (id)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //UI Setup
    self.tableView.alpha = 0.0;
    self.tableView.rowHeight = 54.0;
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[BoxFolderPickerHelper sharedHelper] cancelThumbnailOperations];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{    
    NSUInteger count = [self.delegate currentNumberOfItems];
    NSUInteger total = [self.delegate totalNumberOfItems];
    
    // +1 for the "load more" cell at the bottom.
    return (count < total) ? count + 1 : count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.row < [self.delegate currentNumberOfItems])
    {
        BoxItem *item = (BoxItem *)[self.delegate itemAtIndex:indexPath.row];

        BoxThumbnailDownloadBlock thumbnailBlock = ^(UIImage *image, NSIndexPath *indexPath)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                cell.imageView.image = image;
                [cell setNeedsLayout];
            });
        };
        
        if ([[BoxFolderPickerHelper sharedHelper] shouldDiplayThumbnailForItem:item] && [self.delegate areThumbnailsEnabled] && [self.delegate currentThumbnailPath])
        {
            // In this case, we download the thumbnails and cache them at the path provided by the user.
            [[BoxFolderPickerHelper sharedHelper] thumbnailForFile:(BoxFile *)item cachePath:[self.delegate currentThumbnailPath] cached:thumbnailBlock refreshed:thumbnailBlock indexPath:indexPath];
        }
        else if ([[BoxFolderPickerHelper sharedHelper] shouldDiplayThumbnailForItem:item] && [self.delegate areThumbnailsEnabled] && ![self.delegate currentThumbnailPath])
        {
            // In this case, we download the thumbnail but not cache them
            [[BoxFolderPickerHelper sharedHelper] thumbnailForFile:(BoxFile *)item cachePath:nil cached:thumbnailBlock refreshed:thumbnailBlock indexPath:indexPath];
        }
        else 
        {
            // No thumbnails
            cell.imageView.image = [[BoxFolderPickerHelper sharedHelper] iconForItem:item];
        }
        
        cell.textLabel.text = item.name;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - Last update : %@", [[BoxFolderPickerHelper sharedHelper] sizeForItem:item], [[BoxFolderPickerHelper sharedHelper] dateStringForItem:item]];
        
        if ([item isKindOfClass:[BoxFolder class]])
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else 
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    else 
    {
        cell.textLabel.text =  @"Load more files ...";
        cell.textLabel.textColor = [UIColor darkGrayColor];
        cell.imageView.image = nil;
        cell.detailTextLabel.text = nil;
    }
    
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [self.delegate currentNumberOfItems])
    {
        BoxItem *item = (BoxItem *)[self.delegate itemAtIndex:indexPath.row];
        
        if ([item isKindOfClass:[BoxFolder class]])
        {
            BoxFolderPickerViewController *childFolderPicker = [[BoxFolderPickerViewController alloc] initWithAutorizationURL:[self.delegate currentAuthorizationURL] 
                                                                                                                  redirectURI:[self.delegate currentRedirectURI] 
                                                                                                                 rootFolderID:item.modelID enableThumbnails:[self.delegate areThumbnailsEnabled] 
                                                                                                         cachedThumbnailsPath:[self.delegate currentThumbnailPath]];
            childFolderPicker.delegate = self.folderPicker.delegate;
            [self.navigationController pushViewController:childFolderPicker animated:YES];
        }
        else if ([item isKindOfClass:[BoxFile class]])
        {
            [[BoxFolderPickerHelper sharedHelper] purgeInMemoryCache];
            [self.folderPicker.delegate folderPickerDidSelectBoxFile:(BoxFile *)item];
        }
    }
    else 
    {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [cell setSelected:NO animated:YES];
        [self.delegate loadNextSetOfItems];
    }
}


- (void)refreshData
{
    [self.tableView reloadData];
    [UIView animateWithDuration:0.4 animations:^{
        self.tableView.alpha = 1.0;
    }];
}



@end
