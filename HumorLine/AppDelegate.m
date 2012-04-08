//
//  AppDelegate.m
//  HumorLine
//
//  Created by Yazhenskikh Stanislaw on 11.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "MainView.h"
#import "Post.h"
#import "Image.h"
#import "Constants.h"
#import "SCAppUtils.h"
#import "Config.h"
#import "Top30View.h"
#import "OnMapView.h"
#import "RKPost.h"
#import <RestKit/RestKit.h>

@interface AppDelegate()
@property (nonatomic) BOOL isFirstTimeLaunch;
//- (void)initDB;
@end

@implementation AppDelegate

@synthesize window = _window;
//@synthesize navigationController = _navigationController; 
//@synthesize mainView = _mainView;
//@synthesize managedObjectContext = _managedObjectContext;
//@synthesize managedObjectModel = _managedObjectModel;
//@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize isFirstTimeLaunch = _isFirstTimeLaunch;
@synthesize facebook = _facebook;

- (Facebook *)facebook {
    if (!_facebook) {
        _facebook = [[Facebook alloc] initWithAppId:FB_APP_ID andDelegate:self];
    }
    return _facebook;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // RestKit initialization
    RKObjectManager *objectManager = [RKObjectManager objectManagerWithBaseURL:CLIENT_BASE_URL];
    objectManager.client.requestQueue.showsNetworkActivityIndicatorWhenBusy = YES;    
    
    objectManager.objectStore = [RKManagedObjectStore objectStoreWithStoreFilename:@"RKHumorLine.sqlite"];
    
    RKManagedObjectMapping *postMapping = [RKManagedObjectMapping mappingForClass:[RKPost class]];
    postMapping.primaryKeyAttribute = @"postID";
    [postMapping mapKeyPath:@"id" toAttribute:@"postID"];
    [postMapping mapKeyPath:@"created_at" toAttribute:@"createdAt"];
    [postMapping mapKeyPath:@"image_url" toAttribute:@"imageURL"];
    [postMapping mapKeyPath:@"video_url" toAttribute:@"videoURL"];
    [postMapping mapKeyPath:@"post_type" toAttribute:@"type"];
    [postMapping mapKeyPath:@"lat" toAttribute:@"lat"];
    [postMapping mapKeyPath:@"lng" toAttribute:@"lng"];
    [postMapping mapKeyPath:@"title" toAttribute:@"title"];
    [postMapping mapKeyPath:@"text" toAttribute:@"text"];
    
    [RKObjectMapping addDefaultDateFormatterForString:@"E MMM d HH:mm:ss Z y" inTimeZone:nil];
    
    [objectManager.mappingProvider setMapping:postMapping forKeyPath:@"post"];        
    // -----------------------------------------------------
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    MainView *mainView = [[MainView alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:mainView];
    [SCAppUtils customizeNavigationController:navigationController];
    
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];  
    
    return YES;
}

// Pre iOS 4.2 support
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [self.facebook handleOpenURL:url]; 
}

// For iOS 4.2+ support
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [self.facebook handleOpenURL:url]; 
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

#pragma mark - FacebookSessionDelegate
- (void)fbDidLogin {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[self.facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[self.facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    
    //NSError *error;
//    if (self.managedObjectContext != nil) {
//        if ([self.managedObjectContext hasChanges] && ![self.managedObjectContext save:&error]) {
//			/*
//			 Replace this implementation with code to handle the error appropriately.
//			 
//			 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
//			 */
//			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//			abort();
//        } 
//    }
}

#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
//- (NSManagedObjectContext *)managedObjectContext {
//    if (_managedObjectContext != nil) {
//        return _managedObjectContext;
//    }	
//    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
//    if (coordinator != nil) {
//        _managedObjectContext = [[NSManagedObjectContext alloc] init];
//        [_managedObjectContext setPersistentStoreCoordinator: coordinator];
//    }
//    
//    //if (self.isFirstTimeLaunch) [self initDB];
//    
//    NSLog(@"IsFirstTimeLaunch : %d", self.isFirstTimeLaunch);
//    
//    return _managedObjectContext;
//}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
//- (NSManagedObjectModel *)managedObjectModel {
//    if (_managedObjectModel != nil) {
//        return _managedObjectModel;
//    }
//    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
//    return _managedObjectModel;
//}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
//- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {	
//    if (_persistentStoreCoordinator != nil) {
//        return _persistentStoreCoordinator;
//    }
//    
//	NSString *storePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"HumorLine.sqlite"];
//	/*
//	 Set up the store.
//	 For the sake of illustration, provide a pre-populated default store.
//	 */
//	NSFileManager *fileManager = [NSFileManager defaultManager];
//	// If the expected store doesn't exist, copy the default store.
//	if (![fileManager fileExistsAtPath:storePath]) {
//		NSString *defaultStorePath = [[NSBundle mainBundle] pathForResource:@"HumorLine" ofType:@"sqlite"];
//		if (defaultStorePath) {
//			[fileManager copyItemAtPath:defaultStorePath toPath:storePath error:NULL];
//		}
//        self.isFirstTimeLaunch = YES;
//	}
//	
//	NSURL *storeUrl = [NSURL fileURLWithPath:storePath];
//	
//	NSError *error;
//    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
//    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
//		/*
//		 Replace this implementation with code to handle the error appropriately.
//		 
//		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
//		 
//		 Typical reasons for an error here include:
//		 * The persistent store is not accessible
//		 * The schema for the persistent store is incompatible with current managed object model
//		 Check the error message to determine what the actual problem was.
//		 */
//		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//		abort();
//    }    
//    
//    return _persistentStoreCoordinator;
//}

//- (void)initDB {
//    NSLog(@"%@", NSStringFromSelector(_cmd));
//    NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:@"http://pics.livejournal.com/che_ratnik/pic/0004adqe"]];
//   
//    for (int i = 0; i < 7; i++) {            
//        Post *newPost = [NSEntityDescription insertNewObjectForEntityForName:@"Post" inManagedObjectContext:self.managedObjectContext];
//        newPost.date = [NSDate date];
//        newPost.type = kPostTypeImage;
//        newPost.likesCount = arc4random() % 100;    
//        Image *image = (Image *)[NSEntityDescription insertNewObjectForEntityForName:@"Image" inManagedObjectContext:self.managedObjectContext];
//        newPost.image = image;
//        newPost.image.image = [[UIImage alloc] initWithData:data];
//    }
//    Post *newPost = [NSEntityDescription insertNewObjectForEntityForName:@"Post" inManagedObjectContext:self.managedObjectContext];
//    newPost.type = kPostTypeText;
//    newPost.date = [NSDate date];
//    newPost.text = @"Хотел как лучше получилось как всегда";
//    
////    newPost = [NSEntityDescription insertNewObjectForEntityForName:@"Post" inManagedObjectContext:self.managedObjectContext];
////    newPost.type = kPostTypeVideo;
////    newPost.date = [NSDate date];
////    newPost.title = @"lol";
////    newPost.videoURL = @"http://www.samkeeneinteractivedesign.com/videos/littleVid3.mp4";
//    
//    NSError *error;
//    if (![self.managedObjectContext save:&error]) {
//        NSLog(@"Error saving: %@", error.localizedDescription);
//    }
//}

#pragma mark -
#pragma mark Application's documents directory

/**
 Returns the path to the application's documents directory.
 */
//- (NSString *)applicationDocumentsDirectory {
//	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//}

@end
