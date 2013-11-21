//
//  BoxSearchResourceManager.m
//  BoxSDK
//
//  Created on 8/5/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import "BoxSearchResourceManager.h"

#import "BoxCollection.h"
#import "BoxAPIRequestBuilder.h"

NSString *const BoxAPISearchQueryParameter = @"query";

#define BOX_API_SEARCH_RESOURCE  (@"search")

@implementation BoxSearchResourceManager

- (BoxAPIJSONOperation *)searchWithQuery:(NSString *)query successBlock:(BoxCollectionBlock)successBlock failureBlock:(BoxAPIJSONFailureBlock)failureBlock
{
    NSDictionary *queryString = @{BoxAPISearchQueryParameter : query};
    BoxAPIRequestBuilder *builder = [[BoxAPIRequestBuilder alloc] initWithQueryStringParameters:queryString];

    NSURL *URL = [self URLWithResource:BOX_API_SEARCH_RESOURCE ID:nil subresource:nil subID:nil];
    BoxAPIJSONOperation *operation = [self JSONOperationWithURL:URL
                                                     HTTPMethod:BoxAPIHTTPMethodGET
                                          queryStringParameters:builder.queryStringParameters
                                                 bodyDictionary:nil
                                         collectionSuccessBlock:successBlock
                                                   failureBlock:failureBlock];

    [self.queueManager enqueueOperation:operation];

    return operation;
}

@end
