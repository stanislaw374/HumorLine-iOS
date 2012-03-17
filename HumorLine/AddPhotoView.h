//
//  AddPhotoView.h
//  HumorLine
//
//  Created by Yazhenskikh Stanislaw on 12.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface AddPhotoView : UIViewController <UITextFieldDelegate, CLLocationManagerDelegate>
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *imageView;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *lblHeader;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *lblSubheader;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *txtHeader;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *txtSubheader;
@property (unsafe_unretained, nonatomic) IBOutlet UISwitch *swAddLocation;
@property (nonatomic, strong) UIImage *image;
@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *scrollView;
- (IBAction)onAddButtonClick:(id)sender;
- (IBAction)onCancelButtonClick:(id)sender;
- (IBAction)onBgClick:(id)sender;
- (IBAction)onSwAddLocationValueChanged:(id)sender;

@end

