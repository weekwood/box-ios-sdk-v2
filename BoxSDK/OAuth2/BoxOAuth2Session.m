//
//  BoxOAuth2Session.m
//  BoxSDK
//
//  Created on 2/21/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import "BoxOAuth2Session.h"
#import "BoxLog.h"
#import "BoxSDKConstants.h"

NSString *const BoxOAuth2SessionDidBecomeAuthenticatedNotification = @"BoxOAuth2SessionDidBecomeAuthenticated";
NSString *const BoxOAuth2SessionDidReceiveAuthenricationErrorNotification = @"BoxOAuth2SessionDidReceiveAuthenticationError";
NSString *const BoxOAuth2SessionDidRefreshTokensNotification = @"BoxOAuth2SessionDidRefreshTokens";
NSString *const BoxOAuth2SessionDidReceiveRefreshErrorNotification = @"BoxOAuth2SessionDidReceiveRefreshError";

NSString *const BoxOAuth2AuthenticationErrorKey = @"BoxOAuth2AuthenticationError";

@implementation BoxOAuth2Session

@synthesize APIBaseURLString = _APIBaseURLString;
@synthesize clientID = _clientID;
@synthesize clientSecret = _clientSecret;
@synthesize accessToken = _accessToken;
@synthesize refreshToken = _refreshToken;
@synthesize accessTokenExpiration = _accessTokenExpiration;
@synthesize queueManager = _queueManager;

#pragma mark - Initialization
- (id)initWithClientID:(NSString *)ID secret:(NSString *)secret APIBaseURL:(NSString *)baseURL queueManager:(BoxAPIQueueManager *)queueManager
{
    self = [super init];
    if (self != nil)
    {
        _clientID = ID;
        _clientSecret = secret;
        _APIBaseURLString = baseURL;
        _queueManager = queueManager;
    }
    return self;
}

#pragma mark - Authorization
- (void)performAuthorizationCodeGrantWithReceivedURL:(NSURL *)url
{
    BOXAbstract();
}

- (NSURL *)grantTokensURL
{
    BOXAbstract();
    return nil;
}

- (NSURL *)authorizeURL
{
    BOXAbstract();
    return nil;
}

- (NSString *)redirectURIString
{
    BOXAbstract();
    return nil;
}

#pragma mark - Token Refresh
- (void)performRefreshTokenGrant
{
    BOXAbstract();
}

#pragma mark - Session info
- (BOOL)isAuthorized
{
    BOXAbstract();
    return NO;
}

#pragma mark - Request Authorization
- (void)addAuthorizationParametersToRequest:(NSMutableURLRequest *)request
{
    NSString *bearerToken = [NSString stringWithFormat:@"Bearer %@", self.accessToken];
    [request addValue:bearerToken forHTTPHeaderField:BoxAPIHTTPHeaderAuthorization];
}

@end
