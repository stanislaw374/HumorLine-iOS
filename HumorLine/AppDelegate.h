//
//  AppDelegate.h
//  HumorLine
//
//  Created by Yazhenskikh Stanislaw on 11.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Facebook.h"

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, FBSessionDelegate>

@property (strong, nonatomic) UIWindow *window;

//@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
//@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
//@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, strong) Facebook *facebook;

//- (NSString *)applicationDocumentsDirectory;

@end
