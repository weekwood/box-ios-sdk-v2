//
//  BoxSDK.m
//  BoxSDK
//
//  Created on 2/19/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import "BoxSDK.h"
#import "BoxSDKConstants.h"
#import "BoxOAuth2Session.h"
#import "BoxSerialOAuth2Session.h"
#import "BoxSerialAPIQueueManager.h"

@implementation BoxSDK

@synthesize APIBaseURL = _APIBaseURL;
@synthesize OAuth2Session = _OAuth2Session;
@synthesize queueManager = _queueManager;
@synthesize foldersManager = _foldersManager;
@synthesize filesManager = _filesManager;

#pragma mark - Globally accessible API singleton instance
+ (BoxSDK *)sharedSDK
{
    static dispatch_once_t pred;
    static BoxSDK *sharedBoxSDK;

    dispatch_once(&pred, ^{
        sharedBoxSDK = [[BoxSDK alloc] init];

        [sharedBoxSDK setAPIBaseURL:BoxAPIBaseURL];

        // the circular reference between the queue manager and the OAuth2 session is necessary
        // because the OAuth2 session enqueues API operations to fetch access tokens and the queue
        // manager uses the OAuth2 session as a lock object when enqueuing operations.
        sharedBoxSDK.queueManager = [[BoxParallelAPIQueueManager alloc] init];
        sharedBoxSDK.OAuth2Session = [[BoxParallelOAuth2Session alloc] initWithClientID:nil
                                                                                 secret:nil
                                                                             APIBaseURL:BoxAPIBaseURL
                                                                           queueManager:sharedBoxSDK.queueManager];

        sharedBoxSDK.queueManager.OAuth2Session = sharedBoxSDK.OAuth2Session;

        sharedBoxSDK.filesManager = [[BoxFilesResourceManager alloc] initWithAPIBaseURL:BoxAPIBaseURL OAuth2Session:sharedBoxSDK.OAuth2Session queueManager:sharedBoxSDK.queueManager];
        sharedBoxSDK.filesManager.uploadBaseURL = BoxAPIUploadBaseURL;
        sharedBoxSDK.filesManager.uploadAPIVersion = BoxAPIUploadAPIVersion;

        sharedBoxSDK.foldersManager = [[BoxFoldersResourceManager alloc] initWithAPIBaseURL:BoxAPIBaseURL OAuth2Session:sharedBoxSDK.OAuth2Session queueManager:sharedBoxSDK.queueManager];
    });

    return sharedBoxSDK;
}

- (void)setAPIBaseURL:(NSString *)APIBaseURL
{
    _APIBaseURL = APIBaseURL;
    self.OAuth2Session.APIBaseURLString = APIBaseURL;

    // managers
    self.filesManager.APIBaseURL = APIBaseURL;
    self.foldersManager.APIBaseURL = APIBaseURL;
}

@end
