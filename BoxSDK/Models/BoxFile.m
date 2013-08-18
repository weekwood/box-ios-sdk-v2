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
    return extract_key_from_json_and_cast_to_type(BoxAPIObjectKeySHA1, NSString);
}

@end
