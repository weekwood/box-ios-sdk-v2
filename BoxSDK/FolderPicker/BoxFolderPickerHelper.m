//
//  BoxFolderPickerHelper.m
//  FolderPickerSampleApp
//
//  Created on 5/1/13.
//  Copyright (c) 2013 Box Inc. All rights reserved.
//

#import "BoxFolderPickerHelper.h"
#import "BoxSDK.h"

#define BOX_KILOBYTE 1024
#define BOX_MEGABYTE (BOX_KILOBYTE * 1024)
#define BOX_GIGABYTE (BOX_MEGABYTE * 1024)

#define FAILED_OPERATION_MODEL @"failedOperationModel"
#define FAILED_OPERATION_CACHED_BLOCK @"failedOperationCachedBlock"
#define FAILED_OPERATION_REFRESHED_BLOCK @"failedOperationRefreshedBlock"
#define FAILED_OPERATION_CACHE_PATH @"failedOperationCachePath"

#define IS_RETINA ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale == 2.0))

@interface BoxFolderPickerHelper () 

@property (nonatomic, readwrite, strong) NSMutableDictionary *datesStrings;
@property (nonatomic, readwrite, strong) NSDateFormatter *updateDateFormatter;
@property (nonatomic, readwrite, strong) NSMutableDictionary *occuringOperations;

// Dictionnary only used when the user does not want to store thumbnails on the hard drive, in order no to request several times a thumbnail.
@property (nonatomic, readwrite, strong) NSMutableDictionary *inMemoryCache;
@property (nonatomic, readwrite, strong) NSMutableArray *failedOperationsArguments;

@end

@implementation BoxFolderPickerHelper

@synthesize datesStrings = _datesStrings;
@synthesize updateDateFormatter = _updateDateFormatter;
@synthesize occuringOperations = _occuringOperations;

@synthesize inMemoryCache = _inMemoryCache;
@synthesize failedOperationsArguments = _failedOperationsArguments;

+ (BoxFolderPickerHelper *)sharedHelper
{
    static dispatch_once_t pred;
    static BoxFolderPickerHelper *sharedHelper;
    
    dispatch_once(&pred, ^{
        sharedHelper = [[BoxFolderPickerHelper alloc] init];
        sharedHelper.datesStrings = [NSMutableDictionary dictionary];
        sharedHelper.occuringOperations = [NSMutableDictionary dictionary];
        sharedHelper.updateDateFormatter = [[NSDateFormatter alloc] init];
        sharedHelper.inMemoryCache = [NSMutableDictionary dictionary];
        sharedHelper.updateDateFormatter.dateFormat = @"yyyy-MM-dd HH:mm";
        sharedHelper.failedOperationsArguments = [NSMutableArray array];
    });
    
    return sharedHelper;
}

#pragma mark - Helper methods

- (UIImage *)iconForItem:(BoxItem *)item
{
    
    if ([item isKindOfClass:[BoxFolder class]])
    {
        return [UIImage imageNamed:@"folder"];
    }
    
    NSString *extension = [item.name pathExtension];
    
    if ([extension isEqualToString:@"docx"]) 
    {
        extension = @"doc";
    }
    if ([extension isEqualToString:@"pptx"]) 
    {
        extension = @"ppt";
    }
    if ([extension isEqualToString:@"xlsx"]) 
    {
        extension = @"xls";
    }
    if ([extension isEqualToString:@"html"]) 
    {
        extension = @"htm";
    }
    
    
    UIImage *image = [UIImage imageNamed:extension];
    
    if (!image)
    {
        image = [UIImage imageNamed:@"generic"];
    }
    
    return image;
}

- (NSString *)sizeForItem:(BoxItem *)item
{
    NSString * result_str = nil;
	long long fileSize = [item.size longLongValue];
    
	if (fileSize >= BOX_GIGABYTE)
	{
		double dSize = fileSize / (double)BOX_GIGABYTE;
		result_str = [NSString stringWithFormat:@"%1.1f GB", dSize];
	}
	else if (fileSize >= BOX_MEGABYTE)
	{
		double dSize = fileSize / (double)BOX_MEGABYTE;
		result_str = [NSString stringWithFormat:@"%1.1f MB", dSize];
	}
	else if (fileSize >= BOX_KILOBYTE)
	{
		double dSize = fileSize / (double)BOX_KILOBYTE;
		result_str = [NSString stringWithFormat:@"%1.1f KB", dSize];
	}
	else
	{
		result_str = @"Empty";
	}
    
    return result_str;
}

- (NSString *)dateStringForItem:(BoxItem *)item
{
    NSString *tmp = [self.datesStrings objectForKey:item.modelID];
    if (!tmp)
    {
        tmp = [self.updateDateFormatter stringFromDate:item.modifiedAt];
        [self.datesStrings setObject:tmp forKey:item.modelID];
    }
    
    return tmp;    
}

- (BOOL)shouldDiplayThumbnailForItem:(BoxItem *)item
{
    NSString *extension = [item.name pathExtension];
    
    return [extension isEqualToString:@"png"] || [extension isEqualToString:@"jpg"] || [extension isEqualToString:@"jpeg"] || [extension isEqualToString:@"JPG"]; 
}


#pragma mark - Thumbnail caching management

- (void)thumbnailForFile:(BoxFile *)file 
               cachePath:(NSString *)cachePath
                  cached:(BoxThumbnailDownloadBlock)cached 
               refreshed:(BoxThumbnailDownloadBlock)refreshed indexPath:(NSIndexPath *)indexPath
{
    __block UIImage *cachedThumbnail = [self cachedThumbnailForFile:file thumbnailsPath:cachePath];

    // We have been able to retrieve a cached version of the thumbnail, either on the disk cache or in the in memory cache. Display it.
    if (cachedThumbnail || [[self.inMemoryCache allKeys] containsObject:file.modelID])
    {
        if (cached && cachedThumbnail)
        {
            cached(cachedThumbnail, indexPath);
        }
        else 
        {
            cached([self.inMemoryCache objectForKey:file.modelID], indexPath);
        }
    }
    // The thumbnail needs to be retrieve via an API call.
    else 
    {        
        // Provide an image placeholder to not have a time without any image displayed on a cell.
        cached([self iconForItem:file], indexPath);
        
        BOOL thumbnailNeedsDeletion = NO;
        if (cachePath == nil)
        {
            thumbnailNeedsDeletion = YES;
            //The user has not set a path, we will temporarly store the thumbnails in the Documents folder and delete them right away.
            NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            cachePath = [documentPaths objectAtIndex:0];
        }
        
        NSString *path = [cachePath stringByAppendingPathComponent:file.modelID];
        path = [cachePath stringByAppendingString:@"@2x"];
        NSOutputStream *outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
        
        BoxDownloadSuccessBlock successBlock = ^(NSString *downloadedFileID, long long expectedContentLength)
        {
            [self.occuringOperations removeObjectForKey:downloadedFileID];
            NSError *error;
            NSData *data = [NSData dataWithContentsOfFile:path options:0 error:&error];
            
            //If an error occured, just keep the local thumb
            if (!error)
            {
                cachedThumbnail = [UIImage imageWithData:data];

                if (refreshed) {
                    refreshed(cachedThumbnail, indexPath);
                }
                
                if (thumbnailNeedsDeletion)
                {
                    // Storing the image in a memory cache that will be cleared once the user dismisses the folder picker.
                    [self.inMemoryCache setObject:cachedThumbnail forKey:file.modelID];
                    //Deleting the temporary thumbnail on the disk
                    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
                }
                return ;
            }
        };
        
        
        BoxDownloadFailureBlock infoFailure = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)
        {
            if ([self.occuringOperations.allKeys containsObject:file.modelID])
            {
                [self.occuringOperations removeObjectForKey:file.modelID];
            }
            NSLog(@"%@", error);
            
            // 202 HTTP reponse code handling
            if (response.statusCode == 202)
            {
                //Getting the value from the Retry-After header.
                NSTimeInterval retryAfterTimeInterval = [[request valueForHTTPHeaderField:@"Retry-After"] integerValue];
                
                // Wait for the specified delay to be elapsed
                dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, retryAfterTimeInterval * NSEC_PER_SEC);
                dispatch_after(time, dispatch_get_main_queue(), ^(void){
                    
                    //the Thumbnail was not ready at the time, we requeue a request to get the thumbnail that should now be generated.
                    [self thumbnailForFile:file cachePath:cachePath cached:cached refreshed:refreshed indexPath:indexPath];
                });
            }
            // Token is invalid or expired.
            else if (response.statusCode == 401)
            {
                // Storing all information needed to rebuild the operation after the token is refreshed
                NSMutableDictionary *dictionnary = [NSMutableDictionary dictionary];
                [dictionnary setObject:file forKey:FAILED_OPERATION_MODEL];
                [dictionnary setObject:cached forKey:FAILED_OPERATION_CACHED_BLOCK];
                [dictionnary setObject:refreshed forKey:FAILED_OPERATION_REFRESHED_BLOCK];
                [dictionnary setObject:cachePath forKey:FAILED_OPERATION_CACHE_PATH];
                
                [self.failedOperationsArguments addObject:dictionnary];
            }
        };
        
        
        BoxAPIDataOperation *operation  = [[BoxSDK sharedSDK].filesManager thumbnailForFileWithID:file.modelID outputStream:outputStream thumbnailSize:BoxThumbnailSize32 success:successBlock failure:infoFailure];
        [self.occuringOperations setObject:operation forKey:file.modelID];
    }
}

- (UIImage *)cachedThumbnailForFile:(BoxFile *)file thumbnailsPath:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *thumbnailPath = [path stringByAppendingPathComponent:file.modelID];
    
    NSData *data = [fileManager contentsAtPath:thumbnailPath];
    
    if (data){
        return [UIImage imageWithData:[fileManager contentsAtPath:thumbnailPath]]; 
    }
    return nil;
}

- (void)cancelThumbnailOperations
{
    NSArray *keys = [self.occuringOperations allKeys];
    for (NSString *str in keys) {
        BoxAPIDataOperation *operation = [self.occuringOperations objectForKey:str];
        [self.occuringOperations removeObjectForKey:str];
        [operation cancel];
    }
}

- (void)purgeInMemoryCache
{
    [self.inMemoryCache removeAllObjects];
}

- (void)retryOperationsAfterTokenRefresh
{
    // The token has been refreshed, we can retry the download operations with new credentials.
    
    for (NSDictionary *dict in self.failedOperationsArguments) {
        [self thumbnailForFile:[dict objectForKey:FAILED_OPERATION_MODEL] 
                     cachePath:[dict objectForKey:FAILED_OPERATION_CACHE_PATH] 
                        cached:[dict objectForKey:FAILED_OPERATION_CACHED_BLOCK] 
                     refreshed:[dict objectForKey:FAILED_OPERATION_REFRESHED_BLOCK] indexPath:nil];
    }
    
    [self.failedOperationsArguments removeAllObjects];
}

@end
