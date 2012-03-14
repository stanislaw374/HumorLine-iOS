//
//  MainMenu.h
//  HumorLine
//
//  Created by Yazhenskikh Stanislaw on 12.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AddPhotoView.h"

//typedef enum { Photo = 1, Video, Text, Trololo } HZ;

@interface MainMenu : NSObject <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

- (id)initWithViewController:(UIViewController *)viewController;
- (void)addAddButton;
- (void)addLoginButton;

@end
