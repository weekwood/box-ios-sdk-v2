//
//  BoxAuthorizationViewController.h
//  BoxSDK
//
//  Created on 2/20/13.
//  Copyright (c) 2013 Box. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BoxOAuth2Session;

/**
 * BoxAuthorizationViewController is a UIViewController that displays a UIWebview
 * that loads the OAuth2 authorize URL. An app may present this view controller to
 * log a user in to Box.
 *
 * @warning This is the only part of the Box SDK that is specific to iOS. If you wish to
 * include the Box SDK in an OS X project, remove this source file.
 */
@interface BoxAuthorizationViewController : UIViewController

/** @name OAuth2 */

/**
 * The BoxOAuth2Session to use for generating the authorization URL
 */
@property (nonatomic, readwrite, weak) BoxOAuth2Session *OAuth2Session;

/** @name Initializers */

/**
 * Designated initializer.
 * @param OAuth2Session The OAuth2 session to use for generating the authorization URL
 */
- (id)initWithOAuth2Session:(BoxOAuth2Session *)OAuth2Session;

@end
