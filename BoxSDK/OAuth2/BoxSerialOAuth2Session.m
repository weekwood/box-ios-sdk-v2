//
//  BoxSerialOAuth2Session.m
//  BoxSDK
//
//  Created on 2/20/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import "BoxSerialOAuth2Session.h"
#import "BoxAPIOAuth2ToJSONOperation.h"
#import "BoxAuthorizationViewController.h"
#import "BoxLog.h"
#import "BoxSDKConstants.h"
#import "NSString+BoxURLHelper.h"
#import "NSURL+BoxURLHelper.h"

@implementation BoxSerialOAuth2Session

#pragma mark - Authorization
- (void)performAuthorizationCodeGrantWithReceivedURL:(NSURL *) url
{
    NSDictionary *urlQueryParams = [url queryDictionary];
    NSString *authorizationCode = [urlQueryParams valueForKey:BoxOAuth2URLParameterAuthorizationCodeKey];
    NSString *authorizationError = [urlQueryParams valueForKey:BoxOAuth2URLParameterErrorCodeKey];

    if (authorizationError != nil)
    {
        NSDictionary *errorInfo = [NSDictionary dictionaryWithObject:authorizationError
                                                              forKey:BoxOAuth2AuthenticationErrorKey];
        [[NSNotificationCenter defaultCenter] postNotificationName:BoxOAuth2SessionDidReceiveAuthenricationErrorNotification
                                                            object:self
                                                          userInfo:errorInfo];
        return;
    }


    NSDictionary *POSTParams = @{
        BoxOAuth2TokenRequestGrantTypeKey : BoxOAuth2TokenRequestGrantTypeAuthorizationCode,
        BoxOAuth2TokenRequestAuthorizationCodeKey : authorizationCode,
        BoxOAuth2TokenRequestClientIDKey : self.clientID,
        BoxOAuth2TokenRequestClientSecretKey : self.clientSecret,
        BoxOAuth2TokenRequestRedirectURIKey : self.redirectURIString,
    };

    BoxAPIOAuth2ToJSONOperation *operation = [[BoxAPIOAuth2ToJSONOperation alloc] initWithURL:[self grantTokensURL]
                                                                       HTTPMethod:BoxAPIHTTPMethodPOST
                                                                             body:POSTParams
                                                                      queryParams:nil
                                                                    OAuth2Session:self];

    operation.success = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSDictionary *JSONDictionary)
    {
        self.accessToken = [JSONDictionary valueForKey:BoxOAuth2TokenJSONAccessTokenKey];
        self.refreshToken = [JSONDictionary valueForKey:BoxOAuth2TokenJSONRefreshTokenKey];

        NSTimeInterval accessTokenExpiresIn = [[JSONDictionary valueForKey:BoxOAuth2TokenJSONExpiresInKey] integerValue];
        BOXAssert(accessTokenExpiresIn >= 0, @"accessTokenExpiresIn value is negative");
        self.accessTokenExpiration = [NSDate dateWithTimeIntervalSinceNow:accessTokenExpiresIn];

        // send success notification
        [[NSNotificationCenter defaultCenter] postNotificationName:BoxOAuth2SessionDidBecomeAuthenticatedNotification object:self];
    };

    operation.failure = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSDictionary *JSONDictionary)
    {
        NSDictionary *errorInfo = [NSDictionary dictionaryWithObject:error
                                                              forKey:BoxOAuth2AuthenticationErrorKey];
        [[NSNotificationCenter defaultCenter] postNotificationName:BoxOAuth2SessionDidReceiveAuthenricationErrorNotification
                                                            object:self
                                                          userInfo:errorInfo];
    };

    [self.queueManager enqueueOperation:operation];
}

- (NSURL *)authorizeURL
{
    NSString *encodedRedirectURI = [NSString stringWithString:self.redirectURIString URLEncoded:YES];
    NSString *authorizeURLString = [NSString stringWithFormat:
                                    @"%@/oauth2/authorize?response_type=code&client_id=%@&state=ok&redirect_uri=%@",
                                    self.APIBaseURLString, self.clientID, encodedRedirectURI];
    return [NSURL URLWithString:authorizeURLString];
}

- (NSURL *)grantTokensURL
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@/oauth2/token", self.APIBaseURLString]];
}

- (NSString *)redirectURIString
{
    return [NSString stringWithFormat:@"boxsdk-%@://boxsdkoauth2redirect", self.clientID];
}

#pragma mark - Token Refresh
- (void)performRefreshTokenGrant
{
    NSDictionary *POSTParams = @{
        BoxOAuth2TokenRequestGrantTypeKey : BoxOAuth2TokenRequestGrantTypeRefreshToken,
        BoxOAuth2TokenRequestRefreshTokenKey : self.refreshToken,
        BoxOAuth2TokenRequestClientIDKey : self.clientID,
        BoxOAuth2TokenRequestClientSecretKey : self.clientSecret,
    };

    BoxAPIOAuth2ToJSONOperation *operation = [[BoxAPIOAuth2ToJSONOperation alloc] initWithURL:self.grantTokensURL
                                                                                   HTTPMethod:BoxAPIHTTPMethodPOST
                                                                                         body:POSTParams
                                                                                  queryParams:nil
                                                                                OAuth2Session:self];

    operation.success = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSDictionary *JSONDictionary)
    {
        self.accessToken = [JSONDictionary valueForKey:BoxOAuth2TokenJSONAccessTokenKey];
        self.refreshToken = [JSONDictionary valueForKey:BoxOAuth2TokenJSONRefreshTokenKey];

        NSTimeInterval accessTokenExpiresIn = [[JSONDictionary valueForKey:BoxOAuth2TokenJSONExpiresInKey] integerValue];
        BOXAssert(accessTokenExpiresIn >= 0, @"accessTokenExpiresIn value is negative");
        self.accessTokenExpiration = [NSDate dateWithTimeIntervalSinceNow:accessTokenExpiresIn];

        // send success notification
        [[NSNotificationCenter defaultCenter] postNotificationName:BoxOAuth2SessionDidRefreshTokensNotification object:self];
    };

    operation.failure = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSDictionary *JSONDictionary)
    {
        NSDictionary *errorInfo = [NSDictionary dictionaryWithObject:error
                                                              forKey:BoxOAuth2AuthenticationErrorKey];
        [[NSNotificationCenter defaultCenter] postNotificationName:BoxOAuth2SessionDidReceiveRefreshErrorNotification
                                                            object:self
                                                          userInfo:errorInfo];
    };
    
    [self.queueManager enqueueOperation:operation];
}

#pragma mark - Session info
- (BOOL)isAuthorized
{
    NSDate *now = [NSDate date];
    return [self.accessTokenExpiration timeIntervalSinceDate:now] > 0;
}

@end
