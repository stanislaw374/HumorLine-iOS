//
//  SCAppUtils.h
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 28.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define kSCNavBarImageTag 6183746
#define kSCNavBarColor [UIColor colorWithRed:60/255.0 green:70/255.0 blue:81/255.0 alpha:1]

@interface SCAppUtils : NSObject

+ (void)customizeNavigationController:(UINavigationController *)navController;

@end
