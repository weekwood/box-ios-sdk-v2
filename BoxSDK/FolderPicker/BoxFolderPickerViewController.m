//
//  BoxFolderPickerViewController.m
//  FolderPickerSampleApp
//
//  Created on 5/1/13.
//  Copyright (c) 2013 Box Inc. All rights reserved.
//
#define boxNavBarColor	[UIColor colorWithRed:0.239f green:0.576f blue:0.792f alpha:1.0]

#import "BoxFolderPickerViewController.h"
#import "BoxSDK.h"

@interface BoxFolderPickerViewController ()

@property (nonatomic, readwrite, strong) BoxFolderPickerTableViewController *tableViewPicker;

@property (nonatomic, readwrite, strong) UINavigationController *authorizationViewController;
@property (nonatomic, readwrite, strong) NSURL *authorizationURL;
@property (nonatomic, readwrite, strong) NSString *redirectURI;

@property (nonatomic, readwrite, strong) NSString *folderID;
@property (nonatomic, readwrite, strong) BoxFolder *folder;

@property (nonatomic, readwrite, assign) NSUInteger totalCount;
@property (nonatomic, readwrite, assign) NSUInteger currentPage;
@property (nonatomic, readwrite, strong) NSMutableArray *items;

@property (nonatomic, readwrite, strong) UIBarButtonItem *checkItem;

@property (nonatomic, readwrite, strong) NSString *thumbnailPath;
@property (nonatomic, readwrite, assign) BOOL thumbnailsEnabled;

@property (nonatomic, readwrite, strong) NSMutableArray *interuptedAPIOperations;

- (void)populateFolderPicker;

@end

@implementation BoxFolderPickerViewController

@synthesize delegate = _delegate;
@synthesize numberOfItemsPerPage = _numberOfItemsPerPage;

@synthesize tableViewPicker = _tableViewPicker;
@synthesize authorizationViewController = _authorizationViewController;
@synthesize authorizationURL = _authorizationURL;
@synthesize redirectURI = _redirectURI;
@synthesize folderID = _folderID;
@synthesize folder = _folder;
@synthesize totalCount = _totalCount;
@synthesize currentPage = _currentPage;
@synthesize items = _items;
@synthesize checkItem = _checkItem;
@synthesize thumbnailPath = _thumbnailPath;
@synthesize thumbnailsEnabled = _thumbnailsEnabled;
@synthesize interuptedAPIOperations = _interuptedAPIOperations;


- (id)initWithAutorizationURL:(NSURL *)url 
                  redirectURI:(NSString *)redirectURI
                 rootFolderID:(NSString *)rootFolderID 
             enableThumbnails:(BOOL)thumbnailsEnabled 
         cachedThumbnailsPath:(NSString *)cachedThumbnailsPath
{
    self = [super init];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(boxSessionBecamAuthentificated:)
                                                     name:BoxOAuth2SessionDidBecomeAuthenticatedNotification
                                                   object:[BoxSDK sharedSDK].OAuth2Session];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(boxSessionsDidRefreshToken:)
                                                     name:BoxOAuth2SessionDidRefreshTokensNotification
                                                   object:[BoxSDK sharedSDK].OAuth2Session];
        
        _folderID = rootFolderID;
        _currentPage = 1;
        _totalCount = 0;
        _items = [NSMutableArray array];
        _numberOfItemsPerPage = 100;
        
        _thumbnailPath = cachedThumbnailsPath;
        _thumbnailsEnabled = thumbnailsEnabled;
        
        _redirectURI = redirectURI;
        _authorizationURL = url;
    }
    return self;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (BoxFolderPickerTableViewController *)tableViewPicker
{
    if (!_tableViewPicker)
    {
        _tableViewPicker = [[BoxFolderPickerTableViewController alloc] init];
        _tableViewPicker.folderPicker = self;
        _tableViewPicker.delegate = self;
    }
    
    return _tableViewPicker;
}

- (UIBarButtonItem *)checkItem
{
    if (_checkItem == nil)
    {
        _checkItem = [[UIBarButtonItem alloc] initWithTitle:@"Pick" style:UIBarButtonItemStyleBordered target:self action:@selector(checkAction)];
    }
    
    return _checkItem;
}

- (UINavigationController *)authorizationViewController
{
    if (!_authorizationViewController)
    {        
        BoxAuthorizationViewController *authVC = [[BoxAuthorizationViewController alloc] initWithAuthorizationURL:self.authorizationURL redirectURI:self.redirectURI];
        authVC.delegate = self;
        _authorizationViewController = [[UINavigationController alloc] initWithRootViewController:authVC];
        _authorizationViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _authorizationViewController.modalPresentationStyle = UIModalPresentationFormSheet;
        _authorizationViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        _authorizationViewController.navigationBar.tintColor = boxNavBarColor;
    }
    
    return _authorizationViewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Creating the cache folder is needed
    if (self.thumbnailPath)
    {        
        NSError *error = nil;
        if (![[NSFileManager defaultManager] fileExistsAtPath:self.thumbnailPath])
        {
            [[NSFileManager defaultManager] createDirectoryAtPath:self.thumbnailPath withIntermediateDirectories:YES attributes:nil error:&error];
            if (error)
            {
                NSLog(@"Cannot create Folder picker's cache folder : %@", error);
            }
        }
    }
    
    //UI Setup
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil];
    
    [self addChildViewController:self.tableViewPicker];
    self.tableViewPicker.view.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height);
    [self.view addSubview:self.tableViewPicker.view];
    [self.tableViewPicker didMoveToParentViewController:self];
    
    // Only try to make network call if the user has already valid credentials. 
    if ([[BoxSDK sharedSDK].OAuth2Session isAuthorized]) 
    {
        [self populateFolderPicker];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(closeAction)];
    self.navigationItem.rightBarButtonItems = @[closeItem, self.checkItem];
    self.navigationController.navigationBar.tintColor = boxNavBarColor;    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (![[BoxSDK sharedSDK].OAuth2Session isAuthorized]) 
    {
        self.checkItem.enabled = NO;
        [self presentViewController:self.authorizationViewController animated:YES completion:nil];
    }
    else 
    {
        self.checkItem.enabled = YES;
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Data management

- (void)populateFolderPicker
{
    self.checkItem.enabled = YES;
    
    //Getting the folder's informations
    BoxFolderBlock infoSuccess = ^(BoxFolder *folder)
    {        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.title = folder.name;            
            self.folder = folder;
            self.navigationController.navigationBar.tintColor = boxNavBarColor;
            self.navigationItem.prompt = nil;            
        });
    };
    
    BoxAPIJSONFailureBlock infoFailure = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSDictionary *JSONDictionary)
    {   
        dispatch_async(dispatch_get_main_queue(), ^{
            self.navigationController.navigationBar.tintColor = [UIColor redColor];
            self.navigationItem.prompt = [NSString stringWithFormat:@"An error occured while retrieving data"];
        });
    };
    
    [[BoxSDK sharedSDK].foldersManager folderInfoWithID:self.folderID requestBuilder:nil success:infoSuccess failure:infoFailure];
    
    [self refreshData];
}

- (void)refreshData
{
    BoxAPIJSONFailureBlock infoFailure = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSDictionary *JSONDictionary)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.navigationController.navigationBar.tintColor = [UIColor redColor];
            self.navigationItem.prompt = [NSString stringWithFormat:@"An error occured while retrieving data"];
        });
    };
    
    //Getting the folder's childrens
    BoxCollectionBlock listSuccess = ^(BoxCollection *collection)
    {
        self.totalCount = [[collection totalCount] integerValue];
        //Adding the page retrieved
        for (int i = 0; i < [collection numberOfEntries]; i++) 
        {
            [self.items addObject:[collection modelAtIndex:i]];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.navigationController.navigationBar.tintColor = boxNavBarColor;
            self.navigationItem.prompt = nil;
            
            [self.tableViewPicker refreshData];
        });
    };
    
    NSMutableDictionary *fieldsDictionnary = [NSMutableDictionary dictionary];
    [fieldsDictionnary setObject:@"size,name,modified_at" forKey:@"fields"];
    [fieldsDictionnary setObject:[NSNumber numberWithInt:self.currentPage * self.numberOfItemsPerPage] forKey:@"limit"];
    [fieldsDictionnary setObject:[NSNumber numberWithInt: (self.currentPage - 1) * self.numberOfItemsPerPage ] forKey:@"offset"];
    BoxFoldersRequestBuilder *request = [[BoxFoldersRequestBuilder alloc] initWithQueryStringParameters:fieldsDictionnary];
    
    [[BoxSDK sharedSDK].foldersManager folderItemsWithID:self.folderID requestBuilder:request success:listSuccess failure:infoFailure];
}

#pragma mark - Callbacks

- (void)closeAction
{
    // Purge the in memory cache and cancel all pending download operations before dismiss notify the delegate.
    [[BoxFolderPickerHelper sharedHelper] purgeInMemoryCache];
    [[BoxFolderPickerHelper sharedHelper] cancelThumbnailOperations];
    
    [self.delegate folderPickerWillClose];
}

- (void)checkAction
{
    // Purge the in memory cache and cancel all pending download operations before dismiss notify the delegate.
    [[BoxFolderPickerHelper sharedHelper] purgeInMemoryCache];
    [[BoxFolderPickerHelper sharedHelper] cancelThumbnailOperations];
    
    [self.delegate folderPickerDidSelectBoxFolder:self.folder];
}

#pragma mark - Folder Picker delegate methods

- (NSUInteger)currentNumberOfItems
{
    return [self.items count];
}

- (NSUInteger)totalNumberOfItems
{
    return self.totalCount;
}

- (BoxItem *)itemAtIndex:(NSUInteger)index
{
    return [self.items objectAtIndex:index];
}

- (void)loadNextSetOfItems
{
    self.currentPage ++;
    [self refreshData];
}

- (NSString *)currentThumbnailPath
{
    return self.thumbnailPath;
}

- (BOOL)areThumbnailsEnabled
{
    return self.thumbnailsEnabled;
}

- (NSURL *)currentAuthorizationURL
{
    return _authorizationURL;
}

- (NSString *)currentRedirectURI
{
    return self.redirectURI;
}

#pragma mark - Cache

- (void)purgeCache
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.thumbnailPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:self.thumbnailPath error:nil];
    }
}

#pragma mark - OAuth 2 session management

- (void)boxSessionBecamAuthentificated:(NSNotification *)notification
{
    [self dismissViewControllerAnimated:YES completion:^{
        [self populateFolderPicker];
    }];
}

- (void)boxSessionsDidRefreshToken:(NSNotification *)notification
{
    [[BoxFolderPickerHelper sharedHelper] retryOperationsAfterTokenRefresh];
}

#pragma mark - BoxAuthorizationViewControllerDelegate methods

- (void)authorizationViewControllerDidCancel:(BoxAuthorizationViewController *)authorizationViewController
{
    if (![[BoxSDK sharedSDK].OAuth2Session isAuthorized]) 
    {
        [self.delegate folderPickerWillClose];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)authorizationViewControllerDidFinishLoading:(BoxAuthorizationViewController *)authorizationViewController
{
    
}

- (void)authorizationViewControllerDidStartLoading:(BoxAuthorizationViewController *)authorizationViewController
{
    
}


@end
