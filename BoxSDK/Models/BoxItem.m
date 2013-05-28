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
    id sequenceID = [self.rawResponseJSON objectForKey:BoxAPIObjectKeySequenceID];
    if (sequenceID == nil)
    {
        return nil;
    }
    else if (![sequenceID isKindOfClass:[NSString class]])
    {
        BOXAssertFail(@"sequence_id should be a string");
        return nil;
    }
    return (NSString *)sequenceID;
}

- (NSString *)ETag
{
    id ETag = [self.rawResponseJSON objectForKey:BoxAPIObjectKeyETag];
    if (ETag == nil)
    {
        return nil;
    }
    else if (![ETag isKindOfClass:[NSString class]])
    {
        BOXAssertFail(@"etag should be a string");
        return nil;
    }
    return (NSString *)ETag;
}

- (NSString *)name
{
    id name = [self.rawResponseJSON objectForKey:BoxAPIObjectKeyName];
    if (name == nil)
    {
        return nil;
    }
    else if (![name isKindOfClass:[NSString class]])
    {
        BOXAssertFail(@"name should be a string");
        return nil;
    }
    return (NSString *)name;
}

- (NSDate *)createdAt
{
    id createdAt = [self.rawResponseJSON objectForKey:BoxAPIObjectKeyCreatedAt];
    if (createdAt == nil)
    {
        return nil;
    }
    else if (![createdAt isKindOfClass:[NSString class]])
    {
        BOXAssertFail(@"created_at should be a string");
        return nil;
    }

    return [self dateWithISO8601String:(NSString *)createdAt];
}

- (NSDate *)modifiedAt
{
    id modifiedAt = [self.rawResponseJSON objectForKey:BoxAPIObjectKeyModifiedAt];
    if (modifiedAt == nil)
    {
        return nil;
    }
    else if (![modifiedAt isKindOfClass:[NSString class]])
    {
        BOXAssertFail(@"modified_at should be a string");
        return nil;
    }

    return [self dateWithISO8601String:(NSString *)modifiedAt];
}

- (NSDate *)contentCreatedAt
{
    id contentCreatedAt = [self.rawResponseJSON objectForKey:BoxAPIObjectKeyContentCreatedAt];
    if (contentCreatedAt == nil)
    {
        return nil;
    }
    else if (![contentCreatedAt isKindOfClass:[NSString class]])
    {
        BOXAssertFail(@"content_created_at should be a string");
        return nil;
    }

    return [self dateWithISO8601String:(NSString *)contentCreatedAt];
}

- (NSDate *)contentModifiedAt
{
    id contentModifiedAt = [self.rawResponseJSON objectForKey:BoxAPIObjectKeyContentModifiedAt];
    if (contentModifiedAt == nil)
    {
        return nil;
    }
    else if (![contentModifiedAt isKindOfClass:[NSString class]])
    {
        BOXAssertFail(@"content_modified_at should be a string");
        return nil;
    }

    return [self dateWithISO8601String:(NSString *)contentModifiedAt];
}

- (NSDate *)trashedAt
{
    id trashedAt = [self.rawResponseJSON objectForKey:BoxAPIObjectKeyTrashedAt];
    if (trashedAt == nil)
    {
        return nil;
    }
    else if (![trashedAt isKindOfClass:[NSString class]])
    {
        BOXAssertFail(@"trashed_at should be a string");
        return nil;
    }

    return [self dateWithISO8601String:(NSString *)trashedAt];
}

- (NSDate *)purgedAt
{
    id purgedAt = [self.rawResponseJSON objectForKey:BoxAPIObjectKeyPurgedAt];
    if (purgedAt == nil)
    {
        return nil;
    }
    else if (![purgedAt isKindOfClass:[NSString class]])
    {
        BOXAssertFail(@"purged_at should be a string");
        return nil;
    }

    return [self dateWithISO8601String:(NSString *)purgedAt];
}

- (NSString *)description
{
    id description = [self.rawResponseJSON objectForKey:BoxAPIObjectKeyDescription];
    if (description == nil)
    {
        return nil;
    }
    else if (![description isKindOfClass:[NSString class]])
    {
        BOXAssertFail(@"description should be a string");
        return nil;
    }
    return (NSString *)description;
}

- (NSNumber *)size
{
    id size = [self.rawResponseJSON valueForKey:BoxAPIObjectKeySize];
    if (size == nil)
    {
        return nil;
    }
    else if (![size isKindOfClass:[NSNumber class]])
    {
        BOXAssertFail(@"size should be a number");
        return nil;
    }
    return [NSNumber numberWithDouble:[size doubleValue]];
}

- (BoxCollection *)pathCollection
{
    id pathCollection = [self.rawResponseJSON objectForKey:BoxAPIObjectKeyPathCollection];
    if (pathCollection == nil)
    {
        return nil;
    }
    else if (![pathCollection isKindOfClass:[NSDictionary class]])
    {
        BOXAssertFail(@"path_collection should be a dictionary");
        return nil;
    }
    return [[BoxCollection alloc] initWithResponseJSON:(NSDictionary *)pathCollection mini:YES];
}

- (BoxUser *)createdBy
{
    id createdBy = [self.rawResponseJSON objectForKey:BoxAPIObjectKeyCreatedBy];
    if (createdBy == nil)
    {
        return nil;
    }
    else if (![createdBy isKindOfClass:[NSDictionary class]])
    {
        BOXAssertFail(@"created_by should be a dictionary");
        return nil;
    }
    return [[BoxUser alloc] initWithResponseJSON:(NSDictionary *)createdBy mini:YES];
}

- (BoxUser *)modifiedBy
{
    id modifiedBy = [self.rawResponseJSON objectForKey:BoxAPIObjectKeyModifiedBy];
    if (modifiedBy == nil)
    {
        return nil;
    }
    else if (![modifiedBy isKindOfClass:[NSDictionary class]])
    {
        BOXAssertFail(@"modified_by should be a dictionary");
        return nil;
    }
    return [[BoxUser alloc] initWithResponseJSON:(NSDictionary *)modifiedBy mini:YES];
}

- (BoxUser *)ownedBy
{
    id ownedBy = [self.rawResponseJSON objectForKey:BoxAPIObjectKeyOwnedBy];
    if (ownedBy == nil)
    {
        return nil;
    }
    else if (![ownedBy isKindOfClass:[NSDictionary class]])
    {
        BOXAssertFail(@"owned_by should be a dictionary");
        return nil;
    }
    return [[BoxUser alloc] initWithResponseJSON:(NSDictionary *)ownedBy mini:YES];
}

- (id)sharedLink
{
    id sharedLink = [self.rawResponseJSON objectForKey:BoxAPIObjectKeySharedLink];
    if ([sharedLink isEqual:[NSNull null]])
    {
        return [NSNull null];
    }
    else if (sharedLink == nil)
    {
        return nil;
    }
    else if (![sharedLink isKindOfClass:[NSDictionary class]])
    {
        BOXAssertFail(@"shared_link should be a dictionary");
        return nil;
    }
    return (NSDictionary *)sharedLink;
}

- (BoxFolder *)parent
{
    id parent = [self.rawResponseJSON objectForKey:BoxAPIObjectKeyParent];
    if (parent == nil)
    {
        return nil;
    }
    else if (![parent isKindOfClass:[NSDictionary class]])
    {
        BOXAssertFail(@"parent should be a dictionary");
        return nil;
    }
    return [[BoxFolder alloc] initWithResponseJSON:parent mini:YES];
}

- (NSString *)itemStatus
{
    id itemStatus = [self.rawResponseJSON objectForKey:BoxAPIObjectKeyItemStatus];
    if (itemStatus == nil)
    {
        return nil;
    }
    else if (![itemStatus isKindOfClass:[NSString class]])
    {
        BOXAssertFail(@"item_status should be a string");
        return nil;
    }
    return (NSString *)itemStatus;
}


@end
