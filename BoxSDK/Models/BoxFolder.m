//
//  BoxFolder.m
//  BoxSDK
//
//  Created on 3/14/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import "BoxFolder.h"

#import "BoxCollection.h"
#import "BoxLog.h"
#import "BoxSDKConstants.h"

@implementation BoxFolder

- (id)folderUploadEmail
{
    id folderUploadEmail = [self.rawResponseJSON objectForKey:BoxAPIObjectKeyFolderUploadEmail];
    if ([folderUploadEmail isEqual:[NSNull null]])
    {
        return [NSNull null];
    }
    else if (folderUploadEmail == nil)
    {
        return nil;
    }
    else if (![folderUploadEmail isKindOfClass:[NSDictionary class]])
    {
        BOXAssertFail(@"folder_upload_email should be a dictionary");
        return nil;
    }
    return (NSDictionary *)folderUploadEmail;
}

- (BoxCollection *)itemCollection
{
    id itemCollection = [self.rawResponseJSON objectForKey:BoxAPIObjectKeyItemCollection];
    if (itemCollection == nil)
    {
        return nil;
    }
    else if (![itemCollection isKindOfClass:[NSDictionary class]])
    {
        BOXAssertFail(@"item_collection should be a dictionary");
        return nil;
    }
    return [[BoxCollection alloc] initWithResponseJSON:(NSDictionary *)itemCollection mini:YES];
}

- (NSString *)syncState
{
    id syncState = [self.rawResponseJSON objectForKey:BoxAPIObjectKeySyncState];
    if (syncState == nil)
    {
        return nil;
    }
    else if (![syncState isKindOfClass:[NSString class]])
    {
        BOXAssertFail(@"sync_state should be a string");
        return nil;
    }
    return (NSString *)syncState;
}

@end
