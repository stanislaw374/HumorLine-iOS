//
//  AddTextView.h
//  HumorLine
//
//  Created by Yazhenskikh Stanislaw on 20.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Post.h"

@interface AddTextView : UIViewController <CLLocationManagerDelegate, UITextViewDelegate, PostDelegate>
@property (unsafe_unretained, nonatomic) IBOutlet UITextView *txtText;
@property (unsafe_unretained, nonatomic) IBOutlet UISwitch *swAddLocation;
- (IBAction)onSwAddLocationValueChanged:(id)sender;
@end
