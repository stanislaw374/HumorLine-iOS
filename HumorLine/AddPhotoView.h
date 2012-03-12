//
//  AddPhotoView.h
//  HumorLine
//
//  Created by Yazhenskikh Stanislaw on 12.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddPhotoViewDelegate <NSObject>
- (void)addPhotoViewDidFinish;
@end

@interface AddPhotoView : UIViewController
@property (nonatomic, unsafe_unretained) id<AddPhotoViewDelegate> delegate;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *imageView;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *lblHeader;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *lblSubheader;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *txtHeader;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *txtSubheader;
@property (unsafe_unretained, nonatomic) IBOutlet UISwitch *swAddLocation;
- (IBAction)onAddButtonClick:(id)sender;
- (IBAction)onCancelButtonClick:(id)sender;

@end

