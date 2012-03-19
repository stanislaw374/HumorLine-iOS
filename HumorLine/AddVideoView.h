//
//  AddVideoView.h
//  HumorLine
//
//  Created by Yazhenskikh Stanislaw on 16.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface AddVideoView : UIViewController <CLLocationManagerDelegate, UITextFieldDelegate>
@property (nonatomic, strong) NSURL *videoURL;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *videoView;
//@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *scrollView;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *lblTitle;
@property (unsafe_unretained, nonatomic) IBOutlet UISwitch *swAddLocation;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *txtTitle;
- (IBAction)onAddButtonClick:(id)sender;
- (IBAction)onCancelButtonClick:(id)sender;
- (IBAction)onLocationSwitchValueChange:(id)sender;
- (IBAction)onTextFieldDidEndOnExit:(id)sender;
@end
