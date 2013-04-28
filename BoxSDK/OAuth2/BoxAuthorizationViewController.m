//
//  BoxAuthorizationViewController.m
//  BoxSDK
//
//  Created on 2/20/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import "BoxAuthorizationViewController.h"
#import "BoxOAuth2Session.h"

@implementation BoxAuthorizationViewController

@synthesize OAuth2Session = _OAuth2Session;

- (id)initWithOAuth2Session:(BoxOAuth2Session *)OAuth2Session
{
    self = [super init];
    if (self != nil)
    {
        _OAuth2Session = OAuth2Session;
    }

    return self;
}

- (void)loadView
{
    self.view = [[UIWebView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:self.OAuth2Session.authorizeURL];

    UIWebView *webView = (UIWebView *)self.view;
    [webView loadRequest:request];
}

@end
