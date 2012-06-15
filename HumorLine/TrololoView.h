//
//  TrololoView.h
//  HumorLine
//
//  Created by Yazhenskikh Stanislaw on 13.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FacePickerView.h"
#import "Post.h"

@interface TrololoView : UIViewController <UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate, UIGestureRecognizerDelegate, FacePickerViewDelegate, UIAlertViewDelegate, PostDelegate>
@property (nonatomic) int imagesCount;

@property (unsafe_unretained, nonatomic) IBOutlet UIButton *faceButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *photoButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *textButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *imageView;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *nextButton;

- (IBAction)onRageButtonClick:(id)sender;
- (IBAction)onPhotoButtonClick:(id)sender;
- (IBAction)onTextButtonClick:(id)sender;
- (IBAction)onBackButtonClick:(id)sender;
- (IBAction)onNextButtonClick:(id)sender;
- (IBAction)onEditingSwitchValueChange:(id)sender;

@end
