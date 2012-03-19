//
//  DetailView.h
//  SDWebImage
//
//  Created by Yazhenskikh Stanislaw on 12.03.12.
//  Copyright (c) 2012 Dailymotion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"

@interface DetailView : UIViewController <UITableViewDataSource>

@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *imageView;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *btnContent;

- (IBAction)onPlusButtonClick:(id)sender;
- (IBAction)onCommentButtonClick:(id)sender;
- (IBAction)onFacebookButtonClick:(id)sender;
- (IBAction)onVKButtonClick:(id)sender;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *lblRating;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *lblComments;
@property (unsafe_unretained, nonatomic) Post *post;
@property (unsafe_unretained, nonatomic) IBOutlet UIBarButtonItem *ratingItem;
@property (unsafe_unretained, nonatomic) IBOutlet UIBarButtonItem *commentsItem;
@end
