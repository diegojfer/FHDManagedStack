// FHDManagedStack.m
//
// Copyright (c) 2014 Diego Jose Fernandez Hernandez
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "FHDManagedStack.h"

@interface FHDManagedStack ()

@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, copy) NSString *databasePath;

@end

@implementation FHDManagedStack

static NSString *FHDApplicationCachePath(){
    static NSString *cachePath;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cachePath = [(NSURL *)[[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject] path];
    });
    
    return cachePath;
}
static NSString *FHDApplicationDocumentsPath(){
    static NSString *documentsPath;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        documentsPath = [(NSURL *)[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] path];
    });
    
    return documentsPath;
}

#pragma mark - Singleton

static dispatch_once_t onceSingleton;
static FHDManagedStack *singleton = nil;
+ (instancetype)sharedStack{
    dispatch_once(&onceSingleton, ^{
        singleton = [self managedStackInCacheFile:nil withModel:nil];
    });
    
    return singleton;
}

#pragma mark - Lifecycle

+ (instancetype)managedStackInMemoryWithModel:(NSManagedObjectModel *)managedObjectModel{
    return [[self alloc] initWithDatabasePath:nil managedObjectModel:managedObjectModel];
}
+ (instancetype)managedStackInCacheFile:(NSString *)filename withModel:(NSManagedObjectModel *)managedObjectModel{
    if (filename == nil || [filename isEqualToString:@""]) filename = [NSString stringWithFormat:@"%@.sqlite3", [[NSBundle mainBundle] bundleIdentifier]];
    
    return [[self alloc] initWithDatabasePath:[FHDApplicationCachePath() stringByAppendingPathComponent:filename] managedObjectModel:managedObjectModel];
}
+ (instancetype)managedStackInDocumentsFile:(NSString *)filename withModel:(NSManagedObjectModel *)managedObjectModel{
    if (filename == nil || [filename isEqualToString:@""]) filename = [NSString stringWithFormat:@"%@.sqlite3", [[NSBundle mainBundle] bundleIdentifier]];
    
    return [[self alloc] initWithDatabasePath:[FHDApplicationDocumentsPath() stringByAppendingPathComponent:filename] managedObjectModel:managedObjectModel];
}

- (id)initWithDatabasePath:(NSString *)path managedObjectModel:(NSManagedObjectModel *)managedObjectModel{
    if (self = [super init]){
        _managedObjectModel = managedObjectModel;
        _databasePath = path;
        
        dispatch_once(&onceSingleton, ^{
            singleton = self;
        });
    }
    
    return self;
}

#pragma mark - Context Methods

- (void)saveContextWithCompletion:(FHDBasicBlock)completionBlock error:(FHDErrorBlock)errorBlock{
    NSError *err = nil;
    
    if ( self.managedObjectContext != nil && [self.managedObjectContext hasChanges] ){
        if ( [self.managedObjectContext save:&err] ){
            if ( completionBlock != nil ) completionBlock();
        }else{
            if ( errorBlock != nil ) errorBlock(err);
        }
    }else{
        if ( completionBlock != nil ) completionBlock();
    }
}

#pragma mark - Properties lazy instantiation

- (NSManagedObjectModel *)managedObjectModel{
    if ( _managedObjectModel == nil )
        _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    return _managedObjectModel;
}
- (NSManagedObjectContext *)managedObjectContext{
    if (_managedObjectContext == nil){
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    }
    
    return _managedObjectContext;
}
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator{
    if (_persistentStoreCoordinator == nil){
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
        
        // file store paths
        NSString *storeFolder = [self.databasePath stringByDeletingLastPathComponent];
        NSString *storeFilename = [self.databasePath lastPathComponent];

        // store params
        NSString    *storeType = self.databasePath ? NSSQLiteStoreType : NSInMemoryStoreType;
        NSURL       *storeURL  = self.databasePath ? [NSURL fileURLWithPath:[storeFolder stringByAppendingPathComponent:storeFilename]] : nil;
        NSDictionary *storeOptions = @{
                                       NSMigratePersistentStoresAutomaticallyOption: @YES,
                                       NSInferMappingModelAutomaticallyOption: @YES
                                       };

        // create folders structure
        if (storeType == NSSQLiteStoreType && [[NSFileManager defaultManager] fileExistsAtPath:storeFolder] == NO){
            NSError *err = nil;
            if([[NSFileManager defaultManager] createDirectoryAtPath:storeFolder withIntermediateDirectories:YES attributes:nil error:&err] == NO){
                // capture and catch error!
                NSLog(@"error adding persistent store!");
                _persistentStoreCoordinator = nil;
                abort();
            }
        }

        // add persistent store
        NSError *err = nil;
        NSPersistentStore *store = [_persistentStoreCoordinator addPersistentStoreWithType:storeType
                                                                             configuration:nil
                                                                                       URL:storeURL
                                                                                   options:storeOptions
                                                                                     error:&err];
        if (store == nil) {
            // capture and catch error!
            NSLog(@"error adding persistent store!");
            _persistentStoreCoordinator = nil;
            abort();
        }
    }
    
    return _persistentStoreCoordinator;
}

@end