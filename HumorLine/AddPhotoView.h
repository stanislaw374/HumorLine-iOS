//
//  AddPhotoView.h
//  HumorLine
//
//  Created by Yazhenskikh Stanislaw on 12.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Post.h"

@interface AddPhotoView : UIViewController <UITextFieldDelegate, CLLocationManagerDelegate, UIAlertViewDelegate, PostDelegate>
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *imageView;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *lblHeader;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *lblSubheader;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *txtHeader;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *txtSubheader;
@property (unsafe_unretained, nonatomic) IBOutlet UISwitch *swAddLocation;
@property (nonatomic, unsafe_unretained) UIImage *image;
@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *scrollView;
- (IBAction)onBgClick:(id)sender;
- (IBAction)onSwAddLocationValueChanged:(id)sender;

@end

