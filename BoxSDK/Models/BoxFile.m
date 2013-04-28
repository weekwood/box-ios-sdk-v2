//
//  BoxFile.m
//  BoxSDK
//
//  Created on 3/14/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import "BoxFile.h"

#import "BoxLog.h"
#import "BoxSDKConstants.h"

@implementation BoxFile

- (NSString *)SHA1
{
    id SHA1 = [self.rawResponseJSON objectForKey:BoxAPIObjectKeySHA1];
    if (SHA1 == nil)
    {
        return nil;
    }
    else if (![SHA1 isKindOfClass:[NSString class]])
    {
        BOXAssertFail(@"sha1 should be a string");
        return nil;
    }
    return (NSString *)SHA1;
}

@end
