//
//  DetailView.h
//  SDWebImage
//
//  Created by Yazhenskikh Stanislaw on 12.03.12.
//  Copyright (c) 2012 Dailymotion. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailView : UIViewController <UITableViewDataSource>

@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *imageView;
- (IBAction)onPlusButtonClick:(id)sender;
- (IBAction)onCommentButtonClick:(id)sender;
- (IBAction)onFacebookButtonClick:(id)sender;
- (IBAction)onVKButtonClick:(id)sender;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *lblRating;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *lblComments;
@end
