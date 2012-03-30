//
//  AddNewView.h
//  HumorLine
//
//  Created by Yazhenskikh Stanislaw on 29.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddNewView : UIViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

- (IBAction)onPhotoButtonClick;
- (IBAction)onVideoButtonClick;
- (IBAction)onTextButtonClick;
- (IBAction)onTrololoButtonClick;


@end
