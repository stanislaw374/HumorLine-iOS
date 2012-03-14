//
//  TrololoView.h
//  HumorLine
//
//  Created by Yazhenskikh Stanislaw on 13.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TrololoView : UIViewController <UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (nonatomic) int imagesCount;

@property (unsafe_unretained, nonatomic) IBOutlet UIButton *faceButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *photoButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *imageView;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *nextButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIBarButtonItem *nextItem;

- (IBAction)onRageButtonClick:(id)sender;
- (IBAction)onPhotoButtonClick:(id)sender;
- (IBAction)onTextButtonClick:(id)sender;
- (IBAction)onBackButtonClick:(id)sender;
- (IBAction)onNextButtonClick:(id)sender;
- (IBAction)onPreviewButtonClick:(id)sender;

@end
