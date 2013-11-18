//
//  ROKAppDelegate.m
//  rokkasa
//
//  Created by Alexander Auer on 17.11.13.
//  Copyright (c) 2013 Alexander Auer. All rights reserved.
//

#import "ROKAppDelegate.h"
#import "TestFlight.h"

@interface NSManagedObjectContext ()
+ (void)MR_setRootSavingContext:(NSManagedObjectContext *)context;
+ (void)MR_setDefaultContext:(NSManagedObjectContext *)moc;
@end


@implementation ROKAppDelegate

dispatch_queue_t myQueue;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self setupApplication];
    myQueue = dispatch_queue_create("com.rokkstart.gdc", nil);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *apiKey = [defaults objectForKey:@"apiKey"];
    NSString *userId = [[defaults objectForKey:@"userId"] stringValue];
   
    if (apiKey == nil) {
        self.window.rootViewController = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"loginViewController"];
    } else {
        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:BASE_URL]];
        NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET" path:[NSString stringWithFormat:@"%@/idcheck", BASE_URL] parameters:nil];
        [request addValue:apiKey forHTTPHeaderField:@"api-key"];
        [request addValue:userId forHTTPHeaderField:@"user-id"];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            dispatch_async(myQueue, ^{
                [[RKObjectManager sharedManager] getObjectsAtPath:@"user" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                    NSArray *user = [User MR_findByAttribute:@"objectId" withValue:[[defaults objectForKey:@"userId"] stringValue]];
                    self.currentUser = [user firstObject];
                    [defaults setObject:self.currentUser.getUserId forKey:@"coreUserId"];                    
                } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                    NSLog(@"Error: %@",error);
                }];
                
                NSString *projectId = [defaults objectForKey:@"projectId"];
                
                // Setting current project if given
                [[RKObjectManager sharedManager] getObjectsAtPath:@"projects" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                    NSLog(@"PID %@", projectId);
                    if (projectId != nil) {
                        NSArray *project = [Project MR_findByAttribute:@"objectId" withValue:projectId];
                        self.currentProject = [project firstObject];
                    }
                } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                    NSLog(@"Error: %@",error);
                }];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.window.rootViewController = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"menuViewController"];
                });
            });
        }
                                         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             [defaults removeObjectForKey:@"apiKey"];
                                             self.window.rootViewController = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"loginViewController"];
                                         }];
        
        
         
         [operation start];
        
    }
    
    
    return YES;
}

- (void)setupApplication {
    NSString *testflightToken = TESTFLIGHT_KEY;
    [TestFlight takeOff:testflightToken];
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
    NSString *storePath = [RKApplicationDataDirectory() stringByAppendingPathComponent:@"rokkasa.sqlite"];
    NSError *error = nil;
    [managedObjectStore addSQLitePersistentStoreAtPath:storePath fromSeedDatabaseAtPath:nil withConfiguration:nil options:nil error:&error];
    [managedObjectStore createManagedObjectContexts];
    
    // Configure MagicalRecord to use RestKit's Core Data stack
    [NSPersistentStoreCoordinator MR_setDefaultStoreCoordinator:managedObjectStore.persistentStoreCoordinator];
    [NSManagedObjectContext MR_setRootSavingContext:managedObjectStore.persistentStoreManagedObjectContext];
    [NSManagedObjectContext MR_setDefaultContext:managedObjectStore.mainQueueManagedObjectContext];
    
    
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:BASE_URL]];
    [[objectManager HTTPClient] setDefaultHeader:@"api-key" value:@"d94dddaa02e63ee2923d6ee81ad3c598"];
    objectManager.managedObjectStore = managedObjectStore;
    
    _managedObjectContext = objectManager.managedObjectStore.persistentStoreManagedObjectContext;
    managedObjectStore = objectManager.managedObjectStore;
    
    RKObjectMapping *errorMapping = [RKObjectMapping mappingForClass:[RKErrorMessage class]];
    [errorMapping addPropertyMapping:
     [RKAttributeMapping attributeMappingFromKeyPath:nil toKeyPath:@"errorMessage"]];
    RKResponseDescriptor *errorDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:errorMapping
                                                                                         method:RKRequestMethodGET
                                                                                    pathPattern:nil
                                                                                        keyPath:@"error" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassClientError)];
    [objectManager addResponseDescriptorsFromArray:@[errorDescriptor]];
    
    
    RKEntityMapping *userMapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass([User class]) inManagedObjectStore:objectManager.managedObjectStore];
    RKEntityMapping *projectMapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass([Project class]) inManagedObjectStore:objectManager.managedObjectStore];
    
    
    userMapping.identificationAttributes = @[ @"objectId" ];
    
    [userMapping addAttributeMappingsFromDictionary:@{
                                                      @"firstname" : @"firstname",
                                                      @"lastname" : @"lastname",
                                                      @"email" : @"email",
                                                      @"phone" : @"phone",
                                                      @"mobile" : @"mobile",
                                                      @"id" : @"objectId",
                                                      @"updated_at" : @"updatedAt",
                                                      @"created_at" : @"createdAt"
                                                      }];
    
    
    
    [objectManager addResponseDescriptorsFromArray:@[[RKResponseDescriptor responseDescriptorWithMapping:userMapping
                                                                                                  method:RKRequestMethodGET
                                                                                             pathPattern:@"user"
                                                                                                 keyPath:@""
                                                                                             statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]]];
    
    
    projectMapping.identificationAttributes = @[ @"objectId" ];
    
    [projectMapping addAttributeMappingsFromDictionary:@{
                                                         @"name" : @"projectName",
                                                         @"id" : @"objectId",
                                                         @"updated_at" : @"updatedAt",
                                                         @"created_at" : @"createdAt",
                                                         }];
    
    [projectMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"users" toKeyPath:@"relUserProject" withMapping:userMapping]];
    [userMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"projects" toKeyPath:@"relUserProject" withMapping:projectMapping]];
    
    
    [objectManager addResponseDescriptorsFromArray:@[[RKResponseDescriptor responseDescriptorWithMapping:projectMapping
                                                                                                  method:RKRequestMethodGET
                                                                                             pathPattern:@"projects"
                                                                                                 keyPath:@""
                                                                                             statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]]];
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
