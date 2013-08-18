//
//  BoxItem.m
//  BoxSDK
//
//  Created on 3/22/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import "BoxItem.h"

#import "BoxCollection.h"
#import "BoxFolder.h"
#import "BoxUser.h"

#import "BoxLog.h"
#import "BoxSDKConstants.h"

@implementation BoxItem

- (NSString *)sequenceID
{
    return extract_key_from_json_and_cast_to_type(BoxAPIObjectKeySequenceID, NSString);
}

- (NSString *)ETag
{
    return extract_key_from_json_and_cast_to_type(BoxAPIObjectKeyETag, NSString);
}

- (NSString *)name
{
    return extract_key_from_json_and_cast_to_type(BoxAPIObjectKeyName, NSString);
}

- (NSDate *)createdAt
{
    NSString *timestamp = extract_key_from_json_and_cast_to_type(BoxAPIObjectKeyCreatedAt, NSString);
    return [self dateWithISO8601String:timestamp];
}

- (NSDate *)modifiedAt
{
    NSString *timestamp = extract_key_from_json_and_cast_to_type(BoxAPIObjectKeyModifiedAt, NSString);
    return [self dateWithISO8601String:timestamp];
}

- (NSDate *)contentCreatedAt
{
    NSString *timestamp = extract_key_from_json_and_cast_to_type(BoxAPIObjectKeyContentCreatedAt, NSString);
    return [self dateWithISO8601String:timestamp];
}

- (NSDate *)contentModifiedAt
{
    NSString *timestamp = extract_key_from_json_and_cast_to_type(BoxAPIObjectKeyContentModifiedAt, NSString);
    return [self dateWithISO8601String:timestamp];
}

- (NSDate *)trashedAt
{
    NSString *timestamp = extract_key_from_json_and_cast_to_type(BoxAPIObjectKeyTrashedAt, NSString);
    return [self dateWithISO8601String:timestamp];
}

- (NSDate *)purgedAt
{
    NSString *timestamp = extract_key_from_json_and_cast_to_type(BoxAPIObjectKeyPurgedAt, NSString);
    return [self dateWithISO8601String:timestamp];
}

- (NSString *)description
{
    return extract_key_from_json_and_cast_to_type(BoxAPIObjectKeyDescription, NSString);
}

- (NSNumber *)size
{
    NSNumber *size = extract_key_from_json_and_cast_to_type(BoxAPIObjectKeySize, NSNumber);
    if (size != nil)
    {
        size = [NSNumber numberWithDouble:[size doubleValue]];
    }
    return size;
}

- (BoxCollection *)pathCollection
{
    NSDictionary *pathCollectionJSON = extract_key_from_json_and_cast_to_type(BoxAPIObjectKeyPathCollection, NSDictionary);

    BoxCollection *pathCollection = nil;
    if (pathCollectionJSON != nil)
    {
        pathCollection = [[BoxCollection alloc] initWithResponseJSON:pathCollectionJSON mini:YES];
    }
    return pathCollection;
}

- (BoxUser *)createdBy
{
    NSDictionary *userJSON = extract_key_from_json_and_cast_to_type(BoxAPIObjectKeyCreatedBy, NSDictionary);

    BoxUser *user = nil;
    if (userJSON != nil)
    {
        user = [[BoxUser alloc] initWithResponseJSON:userJSON mini:YES];
    }
    return user;
}

- (BoxUser *)modifiedBy
{
    NSDictionary *userJSON = extract_key_from_json_and_cast_to_type(BoxAPIObjectKeyModifiedBy, NSDictionary);

    BoxUser *user = nil;
    if (userJSON != nil)
    {
        user = [[BoxUser alloc] initWithResponseJSON:userJSON mini:YES];
    }
    return user;
}

- (BoxUser *)ownedBy
{
    NSDictionary *userJSON = extract_key_from_json_and_cast_to_type(BoxAPIObjectKeyOwnedBy, NSDictionary);

    BoxUser *user = nil;
    if (userJSON != nil)
    {
        user = [[BoxUser alloc] initWithResponseJSON:userJSON mini:YES];
    }
    return user;
}

- (id)sharedLink
{
    return extract_nullable_key_from_json_and_cast_to_type(BoxAPIObjectKeySharedLink, NSDictionary);
}

- (BoxFolder *)parent
{
    NSDictionary *parentJSON = extract_key_from_json_and_cast_to_type(BoxAPIObjectKeyParent, NSDictionary);

    BoxFolder *parent = nil;
    if (parentJSON != nil)
    {
        parent = [[BoxFolder alloc] initWithResponseJSON:parentJSON mini:YES];
    }
    return parent;
}

- (NSString *)itemStatus
{
    return extract_key_from_json_and_cast_to_type(BoxAPIObjectKeyItemStatus, NSString);
}


@end
