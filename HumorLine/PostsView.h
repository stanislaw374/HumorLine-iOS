//
//  DetailView.h
//  SDWebImage
//
//  Created by Yazhenskikh Stanislaw on 12.03.12.
//  Copyright (c) 2012 Dailymotion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"

@interface PostsView : UIViewController <UITableViewDataSource, UIScrollViewDelegate>
@property (nonatomic, unsafe_unretained) NSFetchedResultsController *fetchedResultsController;
//@property (unsafe_unretained, nonatomic) Post *post;
@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *scrollView;
//@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *imageView;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *btnContent;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *lblRating;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *lblComments;
@property (unsafe_unretained, nonatomic) IBOutlet UIBarButtonItem *ratingItem;
@property (unsafe_unretained, nonatomic) IBOutlet UIBarButtonItem *commentsItem;
@property (nonatomic) int currentPage;
@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)onPlusButtonClick:(id)sender;
- (IBAction)onCommentButtonClick:(id)sender;
- (IBAction)onFacebookButtonClick:(id)sender;
- (IBAction)onVKButtonClick:(id)sender;
@end
