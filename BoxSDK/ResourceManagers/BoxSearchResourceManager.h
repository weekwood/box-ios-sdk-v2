//
//  BoxSearchResourceManager.h
//  BoxSDK
//
//  Created on 8/5/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import "BoxAPIResourceManager.h"

extern NSString *const BoxAPISearchQueryParameter;

@interface BoxSearchResourceManager : BoxAPIResourceManager

/**
 * Perform a search across the currently authenticated user's account.
 */
- (BoxAPIJSONOperation *)searchWithQuery:(NSString *)query successBlock:(BoxCollectionBlock)successBlock failureBlock:(BoxAPIJSONFailureBlock)failureBlock;

@end
