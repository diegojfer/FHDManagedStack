// FHDManagedStack.h
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

#import <CoreData/CoreData.h>

@interface FHDManagedStack : NSObject

typedef void (^FHDBasicBlock)();
typedef void (^FHDErrorBlock)(NSError *err);

/**
 The associated persistent store coordinator.
 */
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

/**
 The associated managed object model.
 */
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;

/**
 The associated managed object context.
 */
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;

/**
 Returns the first created stack or a cached stored stack.
 */
+ (instancetype)sharedStack;

/**
 Creates an instance of `FHDManagedStack` with data in memory and returns it.
 
 @param managedObjectModel  The associated managed object model. If `nil` all models in the current bundle will be used.
 */
+ (instancetype)managedStackInMemoryWithModel:(NSManagedObjectModel *)managedObjectModel;

/**
 Creates an instance of `FHDManagedStack` with data in specific file at cache documents directory and returns it.
 
 @param filename            The database filename. If `nil` application bundle name will be used.
 @param managedObjectModel  The associated managed object model. If `nil` all models in the current bundle will be used.
 */
+ (instancetype)managedStackInCacheFile:(NSString *)filename withModel:(NSManagedObjectModel *)managedObjectModel;

/**
 Creates an instance of `FHDManagedStack` with data in specific file at application documents directory and returns it.
 
 @param filename            The database filename. If `nil` application bundle name will be used.
 @param managedObjectModel  The associated managed object model. If `nil` all models in the current bundle will be used.
 */
+ (instancetype)managedStackInDocumentsFile:(NSString *)filename withModel:(NSManagedObjectModel *)managedObjectModel;

/**
 Initializes the recieved object and returns it.
 
 @param path                The path for database file. If `nil` application bundle name in documents directory will be used.
 @param managedObjectModel  The associated managed object model. If `nil` all models in the current bundle will be used.
 */
- (id)initWithDatabasePath:(NSString *)path managedObjectModel:(NSManagedObjectModel *)managedObjectModel;

/**
 Saves managed object context.
 
 @param completionBlock     The block that will be executed after the context is saved.
 @param errorBlock          The block that will be executed when the context produced an error.
 */
- (void)saveContextWithCompletion:(FHDBasicBlock)completionBlock error:(FHDErrorBlock)errorBlock;

@end
