# CORE DATA STACK
---
With `FHDManagedStack` class, you can manage Core Data objects.  

## METHODS

###`+ sharedStack`

Returns the first created stack or a cached stored stack.

###`+ managedStackInMemoryWithModel:` 

Creates an instance of `FHDManagedStack` with data in memory and returns it.

 - _managedObjectModel:_  The associated managed object model. If `nil` all models in the current bundle will be used.

###`+ managedStackInCacheFile:withModel:` 

Creates an instance of `FHDManagedStack` with data in specific file at application documents directory and returns it.

 - _filename:_  The database filename. If `nil` application bundle name will be used.
 - _managedObjectModel:_  The associated managed object model. If `nil` all models in the current bundle will be used.

###`+ managedStackInDocumentsFile:withModel:` 

Creates an instance of `FHDManagedStack` with data in specific file at application documents directory and returns it.

 - _filename:_  The database filename. If `nil` application bundle name will be used.
 - _managedObjectModel:_  The associated managed object model. If `nil` all models in the current bundle will be used.   

###`- initWithDatabasePath:managedObjectModel:` 

Initializes the recieved object and returns it.

 - _path:_  The path for database file. If `nil` application bundle name in documents directory will be used.
 - _managedObjectModel:_  The associated managed object model. If `nil` all models in the current bundle will be used.

###`- saveContextWithCompletion:error:` 

Saves managed object context.

 - _completionBlock:_  The block that will be executed after the context is saved.
 - _errorBlock:_  The block that will be executed when the context produced an error.  
   

## PROPERTIES

###`NSPersistentStoreCoordinator *persistentStoreCoordinator;`

The associated persistent store coordinator.

###`NSManagedObjectModel *managedObjectModel;`

The associated managed object model.

###`NSManagedObjectContext *managedObjectContext;`

The associated managed object context.

## EXAMPLES

###Creating memory stored stack and saving new managed object

```objc
FHDManagedStack *stack = [FHDManagedStack managedStackInMemoryWithModel:nil];

NSEntityDescription *entity = [NSEntityDescription entityForName:@"" inManagedObjectContext:stack.managedObjectContext];
NSManagedObject *object = [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:stack.managedObjectContext];

[stack saveContextWithCompletion:^{
	NSLog(@"saved!");
}error:^(NSError *err) {
	NSLog(@"unresolved error: %@", [err localizedDescription]);
}]; 
```
---
MIT license.