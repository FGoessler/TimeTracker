//
//  TTCoreDataManager+Debug.m
//  timetracker
//
//  Created by Florian Goessler on 10.07.13.
//  Copyright (c) 2013 Florian Goessler. All rights reserved.
//

#import "TTCoreDataManager+Debug.h"

@implementation TTCoreDataManager (Debug)

- (void)copyContainerToSandbox {
    @autoreleasepool {
        NSFileCoordinator *fc = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
        NSError *error = nil;
        NSFileManager *fm = [[NSFileManager alloc] init];
        NSString *path = [self.ubiquityURL path];
        NSString *sandboxPath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:[self.ubiquityURL lastPathComponent]];
        
        if ([fm createDirectoryAtPath:sandboxPath withIntermediateDirectories:YES attributes:nil error:&error]) {
            NSLog(@"Created container directory in sandbox: %@", sandboxPath);
        } else {
            if ([[error domain] isEqualToString:NSCocoaErrorDomain]) {
                if ([error code] == NSFileWriteFileExistsError) {
                    //delete the existing directory
                    error = nil;
                    if ([fm removeItemAtPath:sandboxPath error:&error]) {
                        NSLog(@"Removed old sandbox container copy");
                    } else {
                        NSLog(@"Error trying to remove old sandbox container copy: %@", error);
                    }
                }
            } else {
                NSLog(@"Error attempting to create sandbox container copy: %@", error);
                return;
            }
        }
        
        
        NSArray *subPaths = [fm subpathsAtPath:path];
        for (NSString *subPath in subPaths) {
            NSString *fullPath = [NSString stringWithFormat:@"%@/%@", path, subPath];
            NSString *fullSandboxPath = [NSString stringWithFormat:@"%@/%@", sandboxPath, subPath];
            BOOL isDirectory = NO;
            if ([fm fileExistsAtPath:fullPath isDirectory:&isDirectory]) {
                if (isDirectory) {
                    //create the directory
                    BOOL createSuccess = [fm createDirectoryAtPath:fullSandboxPath
                                       withIntermediateDirectories:YES
                                                        attributes:nil
                                                             error:&error];
                    if (createSuccess) {
                        //yay
                    } else {
                        NSLog(@"Error creating directory in sandbox: %@", error);
                    }
                } else {
                    //simply copy the file over
                    BOOL copySuccess = [fm copyItemAtPath:fullPath
                                                   toPath:fullSandboxPath
                                                    error:&error];
                    if (copySuccess) {
                        //yay
                    } else {
                        NSLog(@"Error copying item at path: %@\nTo path: %@\nError: %@", fullPath, fullSandboxPath, error);
                    }
                }
            } else {
                NSLog(@"Got subpath but there is no file at the full path: %@", fullPath);
            }
        }
        
        fc = nil;
    }
}

- (void)nukeAndPave {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [self asyncNukeAndPave];
    });
}

- (void)asyncNukeAndPave {
    //disconnect from the various stores
    [self dropStores];
    
    NSFileCoordinator *fc = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
    NSError *error = nil;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *path = [self.ubiquityURL path];
    NSArray *subPaths = [fm subpathsAtPath:path];
    for (NSString *subPath in subPaths) {
        NSString *fullPath = [NSString stringWithFormat:@"%@/%@", path, subPath];
        [fc coordinateWritingItemAtURL:[NSURL fileURLWithPath:fullPath]
                               options:NSFileCoordinatorWritingForDeleting
                                 error:&error
                            byAccessor:^(NSURL *newURL) {
								NSError *blockError = nil;
								if ([fm removeItemAtURL:newURL error:&blockError]) {
									NSLog(@"Deleted file: %@", newURL);
								} else {
									NSLog(@"Error deleting file: %@\nError: %@", newURL, blockError);
								}
								
							}];
    }
	
    fc = nil;
}

@end
