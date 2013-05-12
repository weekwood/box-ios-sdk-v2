//
//  BoxAPIOperation.m
//  BoxSDK
//
//  Created on 2/27/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import "BoxAPIOperation.h"

#import "BoxSDKErrors.h"
#import "BoxLog.h"
#import "NSString+BoxURLHelper.h"

@interface BoxAPIOperation()

#pragma mark - Thread keepalive
// these properties and methods will keep the thread running this NSOperation alive until
// the NSURLConnection has completed
@property (nonatomic, readwrite, strong) NSPort *port;

- (void)startRunLoop;
- (void)endRunLoop;

@end

@implementation BoxAPIOperation

@synthesize OAuth2Session = _OAuth2Session;
@synthesize OAuth2AccessToken = _OAuth2AccessToken;

// request properties
@synthesize baseRequestURL = _baseRequestURL;
@synthesize body = _body;
@synthesize queryStringParameters = _queryStringParameters;
@synthesize APIRequest = _APIRequest;
@synthesize connection = _connection;

// request response properties
@synthesize responseData = _responseData;
@synthesize HTTPResponse = _HTTPResponse;

// error handling
@synthesize error = _error;

@synthesize port = _port;

- (NSString *)description
{
    return [[super description] stringByAppendingFormat:@" %@ %@", self.HTTPMethod, self.baseRequestURL];
}

- (id)init
{
    self = [self initWithURL:nil HTTPMethod:nil body:nil queryParams:nil OAuth2Session:nil];
    BOXLog(@"Initialize operations with initWithURL:HTTPMethod:body:queryParams:OAuth2Session:. %@ cannot make an API call", self);
    return self;
}

- (id)initWithURL:(NSURL *)URL HTTPMethod:(BoxAPIHTTPMethod *)HTTPMethod body:(NSDictionary *)body queryParams:(NSDictionary *)queryParams OAuth2Session:(BoxOAuth2Session *)OAuth2Session
{
    self = [super init];
    if (self != nil)
    {
        _baseRequestURL = URL;
        _body = body;
        _queryStringParameters = queryParams;
        _OAuth2Session = OAuth2Session;

        _APIRequest = nil;
        _connection = nil; // delay setting up the connection as long as possible so the OAuth2 credentials remain fresh

        NSMutableURLRequest *APIRequest = [NSMutableURLRequest requestWithURL:[self requestURLWithURL:_baseRequestURL queryStringParameters:_queryStringParameters]];
        APIRequest.HTTPMethod = HTTPMethod;

        NSData *encodedBody = [self encodeBody:_body];
        APIRequest.HTTPBody = encodedBody;

        _APIRequest = APIRequest;

        _responseData = [NSMutableData data];
    }
    
    return self;
}

#pragma mark - Accessors
- (BoxAPIHTTPMethod *)HTTPMethod
{
    return self.APIRequest.HTTPMethod;
}

#pragma mark - Build NSURLRequest
- (NSData *)encodeBody:(NSDictionary *)bodyDictionary
{
    BOXAbstract();
    return nil;
}

- (NSURL *)requestURLWithURL:(NSURL *)baseURL queryStringParameters:(NSDictionary *)queryDictionary
{
    if ([queryDictionary count] == 0)
    {
        return baseURL;
    }

    NSMutableArray *queryParts = [NSMutableArray array];
    for (id key in queryDictionary)
    {
        id value = [queryDictionary objectForKey:key];
        NSString *keyString = [NSString stringWithString:[key description] URLEncoded:YES];
        NSString *valueString = [NSString stringWithString:[value description] URLEncoded:YES];

        [queryParts addObject:[NSString stringWithFormat:@"%@=%@", keyString, valueString]];
    }
    NSString *queryString = [queryParts componentsJoinedByString:@"&"];
    NSString *existingURLString = [baseURL absoluteString];

    NSRange startOfQueryString = [existingURLString rangeOfString:@"?"];
    NSString *joinString = nil;

    if (startOfQueryString.location == NSNotFound)
    {
        joinString = @"?";
    }
    else
    {
        joinString = @"&";
    }

    NSString *urlString = [[existingURLString stringByAppendingString:joinString] stringByAppendingString:queryString];

    return [NSURL URLWithString:urlString];
}

#pragma mark - Prepare to make API call
- (void)prepareAPIRequest
{
    BOXAbstract();
}

- (void)startURLConnection
{
    [self startRunLoop];
    [self.connection start];
}

#pragma mark - Process API call results
- (void)processResponseData:(NSData *)data
{
    BOXAbstract();
}

#pragma mark - callbacks
- (void)performCompletionCallback
{
    BOXAbstract();
}

#pragma mark - Thread keepalive
// @TODO: convince rlopopolo and tcarpel that this is the best way to do this
- (void)startRunLoop
{
    self.port = [NSPort port];
    NSRunLoop *currentRunLoop = [NSRunLoop currentRunLoop];
    // add an empty port to the current run loop to keep it from exiting
    [currentRunLoop addPort:self.port forMode:NSDefaultRunLoopMode];
    [self.connection scheduleInRunLoop:currentRunLoop forMode:NSDefaultRunLoopMode];
    [currentRunLoop run];
}

- (void)endRunLoop
{
    NSRunLoop *currentRunLoop = [NSRunLoop currentRunLoop];
    // remove empty port and stop current run loop
    [currentRunLoop removePort:self.port forMode:NSDefaultRunLoopMode];
    CFRunLoopStop(CFRunLoopGetCurrent());
}

#pragma mark - NSOperation main
- (void)main
{
    @synchronized(self.OAuth2Session)
    {
        [self prepareAPIRequest];
        self.OAuth2AccessToken = self.OAuth2Session.accessToken;
    }

    if (self.error == nil)
    {
        self.connection = [[NSURLConnection alloc] initWithRequest:self.APIRequest delegate:self];
        BOXLog(@"Starting %@", self);
        [self startURLConnection];
    }
    else
    {
        // if an error has already occured, do not attempt to start the API call.
        // short circuit instead.
        [self performCompletionCallback];
    }
}

- (void)cancel
{
    if (![self isFinished] && ![self isCancelled])
    {
        [super cancel];
        [self.connection cancel];

        // Simulate connection:didFailWithError:
        NSDictionary *errorInfo = nil;
        if (self.baseRequestURL)
        {
            errorInfo = [NSDictionary dictionaryWithObject:self.baseRequestURL forKey:NSURLErrorFailingURLErrorKey];
        }
        self.error = [[NSError alloc] initWithDomain:NSURLErrorDomain code:NSURLErrorCancelled userInfo:errorInfo];
        [self connection:self.connection didFailWithError:self.error];
    }
}

#pragma mark - NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.HTTPResponse = (NSHTTPURLResponse *)response;

    if (self.HTTPResponse.statusCode == 202 || self.HTTPResponse.statusCode < 200 || self.HTTPResponse.statusCode >= 300)
    {
        BoxSDKAPIError errorCode = BoxSDKAPIErrorUnknownStatusCode;
        switch (self.HTTPResponse.statusCode)
        {
            case BoxSDKAPIErrorAccepted:
                errorCode = BoxSDKAPIErrorAccepted;
                break;
            case BoxSDKAPIErrorBadRequest:
                errorCode = BoxSDKAPIErrorBadRequest;
                break;
            case BoxSDKAPIErrorUnauthorized:
                errorCode = BoxSDKAPIErrorUnauthorized;
                break;
            case BoxSDKAPIErrorForbidden:
                errorCode = BoxSDKAPIErrorForbidden;
                break;
            case BoxSDKAPIErrorNotFound:
                errorCode = BoxSDKAPIErrorNotFound;
                break;
            case BoxSDKAPIErrorMethodNotAllowed:
                errorCode = BoxSDKAPIErrorMethodNotAllowed;
                break;
            case BoxSDKAPIErrorConflict:
                errorCode = BoxSDKAPIErrorConflict;
                break;
            case BoxSDKAPIErrorPreconditionFailed:
                errorCode = BoxSDKAPIErrorPreconditionFailed;
                break;
            case BoxSDKAPIErrorRequestEntityTooLarge:
                errorCode = BoxSDKAPIErrorRequestEntityTooLarge;
                break;
            case BoxSDKAPIErrorPreconditionRequired:
                errorCode = BoxSDKAPIErrorPreconditionRequired;
                break;
            case BoxSDKAPIErrorTooManyRequests:
                errorCode = BoxSDKAPIErrorTooManyRequests;
                break;
            case BoxSDKAPIErrorInternalServerError:
                errorCode = BoxSDKAPIErrorInternalServerError;
                break;
            case BoxSDKAPIErrorInsufficientStorage:
                errorCode = BoxSDKAPIErrorInsufficientStorage;
                break;
            default:
                errorCode = BoxSDKAPIErrorUnknownStatusCode;
        }

        self.error = [[NSError alloc] initWithDomain:BoxSDKErrorDomain code:errorCode userInfo:nil];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (self.error == nil)
    {
        self.error = error;
    }
    [self endRunLoop];
    [self performCompletionCallback];
    self.connection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self endRunLoop];
    [self processResponseData:self.responseData];
    [self performCompletionCallback];

    self.connection = nil;
}

@end
