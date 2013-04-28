//
//  BoxFoldersResourceManager.m
//  BoxSDK
//
//  Created on 3/12/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import "BoxFoldersResourceManager.h"
#import "BoxFoldersRequestBuilder.h"
#import "BoxOAuth2Session.h"
#import "BoxSDKConstants.h"

NSString *const BoxAPIFolderIDRoot = @"0";
NSString *const BoxAPIFolderIDTrash = @"trash";

@implementation BoxFoldersResourceManager

- (BoxAPIJSONOperation *)folderInfoWithID:(NSString *)folderID requestBuilder:(BoxFoldersRequestBuilder *)builder success:(BoxFolderBlock)successBlock failure:(BoxAPIJSONFailureBlock)failureBlock
{
    NSURL *URL = [self URLWithResource:@"folders" ID:folderID subresource:nil subID:nil];
    BoxAPIJSONOperation *operation = [[BoxAPIJSONOperation alloc] initWithURL:URL HTTPMethod:BoxAPIHTTPMethodGET body:nil queryParams:builder.queryStringParameters OAuth2Session:self.OAuth2Session];

    operation.success = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSDictionary *JSONDictionary)
    {
        if (successBlock != nil)
        {
            successBlock([[BoxFolder alloc] initWithResponseJSON:JSONDictionary mini:NO]);
        }
    };
    if (failureBlock != nil)
    {
        operation.failure = failureBlock;
    }

    [self.queueManager enqueueOperation:operation];

    return operation;
}

- (BoxAPIJSONOperation *)createFolderWithRequestBuilder:(BoxFoldersRequestBuilder *)builder success:(BoxFolderBlock)successBlock failure:(BoxAPIJSONFailureBlock)failureBlock
{
    NSURL *URL = [self URLWithResource:@"folders" ID:nil subresource:nil subID:nil];
    BoxAPIJSONOperation *operation = [[BoxAPIJSONOperation alloc] initWithURL:URL HTTPMethod:BoxAPIHTTPMethodPOST body:builder.bodyParameters queryParams:builder.queryStringParameters OAuth2Session:self.OAuth2Session];

    operation.success = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSDictionary *JSONDictionary)
    {
        if (successBlock != nil)
        {
            successBlock([[BoxFolder alloc] initWithResponseJSON:JSONDictionary mini:NO]);
        }
    };
    if (failureBlock != nil)
    {
        operation.failure = failureBlock;
    }

    [self.queueManager enqueueOperation:operation];

    return operation;
}

- (BoxAPIJSONOperation *)folderItemsWithID:(NSString *)folderID requestBuilder:(BoxFoldersRequestBuilder *)builder success:(BoxCollectionBlock)successBlock failure:(BoxAPIJSONFailureBlock)failureBlock
{
    NSURL *URL = [self URLWithResource:@"folders" ID:folderID subresource:@"items" subID:nil];
    BoxAPIJSONOperation *operation = [[BoxAPIJSONOperation alloc] initWithURL:URL HTTPMethod:BoxAPIHTTPMethodGET body:nil queryParams:builder.queryStringParameters OAuth2Session:self.OAuth2Session];

    operation.success = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSDictionary *JSONDictionary)
    {
        if (successBlock != nil)
        {
            successBlock([[BoxCollection alloc] initWithResponseJSON:JSONDictionary mini:YES]);
        }
    };
    if (failureBlock != nil)
    {
        operation.failure = failureBlock;
    }

    [self.queueManager enqueueOperation:operation];

    return operation;
}

- (BoxAPIJSONOperation *)editFolderWithID:(NSString *)folderID requestBuilder:(BoxFoldersRequestBuilder *)builder success:(BoxFolderBlock)successBlock failure:(BoxAPIJSONFailureBlock)failureBlock
{
    NSURL *URL = [self URLWithResource:@"folders" ID:folderID subresource:nil subID:nil];
    BoxAPIJSONOperation *operation = [[BoxAPIJSONOperation alloc] initWithURL:URL HTTPMethod:BoxAPIHTTPMethodPUT body:builder.bodyParameters queryParams:builder.queryStringParameters OAuth2Session:self.OAuth2Session];

    operation.success = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSDictionary *JSONDictionary)
    {
        if (successBlock != nil)
        {
            successBlock([[BoxFolder alloc] initWithResponseJSON:JSONDictionary mini:NO]);
        }
    };
    if (failureBlock != nil)
    {
        operation.failure = failureBlock;
    }

    [self.queueManager enqueueOperation:operation];

    return operation;
}

- (BoxAPIJSONOperation *)deleteFolderWithID:(NSString *)folderID requestBuilder:(BoxFoldersRequestBuilder *)builder success:(BoxSuccessfulDeleteBlock)successBlock failure:(BoxAPIJSONFailureBlock)failureBlock
{
    NSURL *URL = [self URLWithResource:@"folders" ID:folderID subresource:nil subID:nil];
    BoxAPIJSONOperation *operation = [[BoxAPIJSONOperation alloc] initWithURL:URL HTTPMethod:BoxAPIHTTPMethodDELETE body:nil queryParams:builder.queryStringParameters OAuth2Session:self.OAuth2Session];

    operation.success = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSDictionary *JSONDictionary)
    {
        if (successBlock != nil)
        {
            successBlock(folderID);
        }
    };
    if (failureBlock != nil)
    {
        operation.failure = failureBlock;
    }

    [self.queueManager enqueueOperation:operation];

    return operation;
}

- (BoxAPIJSONOperation *)copyFolderWithID:(NSString *)folderID requestBuilder:(BoxFoldersRequestBuilder *)builder success:(BoxFolderBlock)successBlock failure:(BoxAPIJSONFailureBlock)failureBlock
{
    NSURL *URL = [self URLWithResource:@"folders" ID:folderID subresource:@"copy" subID:nil];
    BoxAPIJSONOperation *operation = [[BoxAPIJSONOperation alloc] initWithURL:URL HTTPMethod:BoxAPIHTTPMethodPOST body:builder.bodyParameters queryParams:builder.queryStringParameters OAuth2Session:self.OAuth2Session];

    operation.success = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSDictionary *JSONDictionary)
    {
        if (successBlock != nil)
        {
            successBlock([[BoxFolder alloc] initWithResponseJSON:JSONDictionary mini:NO]);
        }
    };
    if (failureBlock != nil)
    {
        operation.failure = failureBlock;
    }

    [self.queueManager enqueueOperation:operation];

    return operation;
}

- (BoxAPIJSONOperation *)folderInfoFromTrashWithID:(NSString *)folderID requestBuilder:(BoxFoldersRequestBuilder *)builder success:(BoxFolderBlock)successBlock failure:(BoxAPIJSONFailureBlock)failureBlock
{
    NSURL *URL = [self URLWithResource:@"folders" ID:folderID subresource:@"trash" subID:nil];
    BoxAPIJSONOperation *operation = [[BoxAPIJSONOperation alloc] initWithURL:URL HTTPMethod:BoxAPIHTTPMethodGET body:nil queryParams:builder.queryStringParameters OAuth2Session:self.OAuth2Session];

    operation.success = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSDictionary *JSONDictionary)
    {
        if (successBlock != nil)
        {
            successBlock([[BoxFolder alloc] initWithResponseJSON:JSONDictionary mini:NO]);
        }
    };
    if (failureBlock != nil)
    {
        operation.failure = failureBlock;
    }

    [self.queueManager enqueueOperation:operation];

    return operation;
}

- (BoxAPIJSONOperation *)restoreFolderFromTrashWithID:(NSString *)folderID requestBuilder:(BoxFoldersRequestBuilder *)builder success:(BoxFolderBlock)successBlock failure:(BoxAPIJSONFailureBlock)failureBlock
{
    NSURL *URL = [self URLWithResource:@"folders" ID:folderID subresource:nil subID:nil];
    BoxAPIJSONOperation *operation = [[BoxAPIJSONOperation alloc] initWithURL:URL HTTPMethod:BoxAPIHTTPMethodPOST body:builder.bodyParameters queryParams:builder.queryStringParameters OAuth2Session:self.OAuth2Session];

    operation.success = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSDictionary *JSONDictionary)
    {
        if (successBlock != nil)
        {
            successBlock([[BoxFolder alloc] initWithResponseJSON:JSONDictionary mini:NO]);
        }
    };
    if (failureBlock != nil)
    {
        operation.failure = failureBlock;
    }

    [self.queueManager enqueueOperation:operation];

    return operation;
}


- (BoxAPIJSONOperation *)deleteFolderFromTrashWithID:(NSString *)folderID requestBuilder:(BoxFoldersRequestBuilder *)builder success:(BoxSuccessfulDeleteBlock)successBlock failure:(BoxAPIJSONFailureBlock)failureBlock
{
    NSURL *URL = [self URLWithResource:@"folders" ID:folderID subresource:@"trash" subID:nil];
    BoxAPIJSONOperation *operation = [[BoxAPIJSONOperation alloc] initWithURL:URL HTTPMethod:BoxAPIHTTPMethodDELETE body:nil queryParams:builder.queryStringParameters OAuth2Session:self.OAuth2Session];

    operation.success = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSDictionary *JSONDictionary)
    {
        if (successBlock != nil)
        {
            successBlock(folderID);
        }
    };
    if (failureBlock != nil)
    {
        operation.failure = failureBlock;
    }

    [self.queueManager enqueueOperation:operation];

    return operation;
}

@end
