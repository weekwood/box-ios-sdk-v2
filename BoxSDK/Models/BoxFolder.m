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
    return extract_nullable_key_from_json_and_cast_to_type(BoxAPIObjectKeyFolderUploadEmail, NSDictionary);
}

- (BoxCollection *)itemCollection
{
    NSDictionary *itemCollectionJSON = extract_key_from_json_and_cast_to_type(BoxAPIObjectKeyItemCollection, NSDictionary);

    BoxCollection *itemCollection = nil;
    if (itemCollectionJSON != nil)
    {
        itemCollection = [[BoxCollection alloc] initWithResponseJSON:itemCollectionJSON mini:YES];
    }
    return itemCollection;
}

- (NSString *)syncState
{
    return extract_key_from_json_and_cast_to_type(BoxAPIObjectKeySyncState, NSString);
}

@end
