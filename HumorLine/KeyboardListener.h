//
//  KeyboardNotifications.h
//  buhg
//
//  Created by Yazhenskikh Stanislaw on 20.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeyboardListener : NSObject

+ (void)setScrollView:(UIScrollView *)scrollView;
+ (void)unsetScrollView;
+ (void)setActiveView:(UIView *)view;
+ (void)unsetActiveView;

+ (void)registerForKeyboardNotifications;
+ (void)unregisterForKeyboardNotifications;
+ (void)keyboardWasShown:(NSNotification*)aNotification;
+ (void)keyboardWillBeHidden:(NSNotification*)aNotification;

@end
