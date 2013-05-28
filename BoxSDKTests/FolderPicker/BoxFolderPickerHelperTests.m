//
//  BoxFolderPickerHelperTests.m
//  BoxSDK
//
//  Created on 5/27/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import "BoxFolderPickerHelperTests.h"
#import "BoxFolderPickerHelper.h"
#import "BoxFile.h"
#import "BoxSDK.h"
#import "BoxAPIDataOperation.h"
#import "BoxFilesResourceManager.h"
#import <OCMock/OCMock.h>
#import "BoxSDKConstants.h"

@interface BoxFolderPickerHelper ()

- (UIImage *)cachedThumbnailForFile:(BoxFile *)file thumbnailsPath:(NSString *)path;

@end

@implementation BoxFolderPickerHelperTests

- (void)testThumbnailForFileShouldCallCachedBlockWhenAlreadyCached
{
    BoxFolderPickerHelper *helper = [BoxFolderPickerHelper sharedHelper];
    id folderPickerHelperMock = [OCMockObject partialMockForObject:helper];
    
    [[[folderPickerHelperMock stub] andCall:@selector(mockReturningObjectWithTwoArgumentMethod:secondArgument:) onObject:self] cachedThumbnailForFile:OCMOCK_ANY thumbnailsPath:OCMOCK_ANY];
    
    __block BOOL called = NO;
    
    BoxFile *file = [[BoxFile alloc] init];
        
    [helper thumbnailForFile:file cachePath:nil cached:^(UIImage *image, NSIndexPath *indexPath) {
        called = YES;
    } refreshed:nil indexPath:nil];
    
    STAssertTrue(called, @"Called callback should be called");
    
}



- (id)mockReturningObjectWithTwoArgumentMethod:(id)firstArgument secondArgument:(id)secondArgument
{
    return [[NSObject alloc] init];
}

@end
