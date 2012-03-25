//
//  Top30View.m
//  HumorLine
//
//  Created by Yazhenskikh Stanislaw on 20.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Top30View.h"
#import "AppDelegate.h"
#import "CustomBadge.h"
#import "VideoView.h"
#import <AVFoundation/AVFoundation.h>
#import "Post.h"
#import "Image.h"
#import "PostsView.h"

enum { kCELL_CONTENT_VIEW1 = 1, kCELL_CONTENT_VIEW2 = 2, kCELL_FRAME1 = 3, kCELL_FRAME2 = 4, kCELL_BADGE, kCELL_IMAGE_VIEW, kCELL_VIDEO_VIEW, kCELL_TEXT_VIEW };

@interface Top30View()
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) EGORefreshTableHeaderView *refreshTableHeaderView;
@property (nonatomic) BOOL isLoading;

- (void)reloadDataSource;
- (void)doneReloadingDataSource;

- (void)prepareCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)prepareContentView:(UIView *)contentView;
- (void)clearCell:(UITableViewCell *)cell adIndexPath:(NSIndexPath *)indexPath;
- (void)clearContentView:(UIView *)contentView;
- (void)configureCell:(UITableViewCell *)cell adIndexPath:(NSIndexPath *)indexPath;
- (void)configureContentView:(UIView *)contentView withOffset:(int)offset;

- (void)onButtonClick:(UIButton *)sender withEvent:(UIEvent *)event;
@end

@implementation Top30View
@synthesize tableView = _tableView;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize refreshTableHeaderView = _refreshTableHeaderView;
@synthesize isLoading = _isLoading;

- (NSFetchedResultsController *)fetchedResultsController {
    if (!_fetchedResultsController) {
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Post"];
        NSSortDescriptor *desc = [[NSSortDescriptor alloc] initWithKey:@"likesCount" ascending:NO];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObject:desc]];
        [fetchRequest setFetchLimit:30];
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:appDelegate.managedObjectContext sectionNameKeyPath:nil cacheName:@"Top30"];
    }
    return _fetchedResultsController;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
   
    self.refreshTableHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, 0 - self.tableView.frame.size.height, self.tableView.frame.size.width, self.tableView.frame.size.height) arrowImageName:@"whiteArrow.png" textColor:[UIColor whiteColor]];
    self.refreshTableHeaderView.delegate = self;
    [self.tableView addSubview:self.refreshTableHeaderView];
    
    [self reloadDataSource];
    [self doneReloadingDataSource];    
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0;
    if (!indexPath.row) {
        height = 300;
    }
    else {
        height = 160;
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        height *= 2;
    }
    
    return height;
}

- (void)onButtonClick:(UIButton *)sender withEvent:(UIEvent *)event {
    UITouch *touch = [event allTouches].anyObject;
    CGPoint touchLocation = [touch locationInView:self.tableView];
    int row = [self.tableView indexPathForRowAtPoint:touchLocation].row;
    int offset = 0;
    if (row > 0) {
        offset = (row - 1) * 2 + 1;
    }
    PostsView *postsView = [[PostsView alloc] init];
    postsView.fetchedResultsController = self.fetchedResultsController;
    postsView.currentPage = offset + sender.tag - 1;
    [self.navigationController pushViewController:postsView animated:YES];
}

#pragma mark - UITableViewDataSource

- (void)reloadDataSource {
    self.isLoading = YES;
    
    NSError *error;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Error loading : %@", error.localizedDescription);
    }
}

- (void)doneReloadingDataSource {
    [self.refreshTableHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    [self.tableView reloadData];
 
    self.isLoading = NO;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int result = self.fetchedResultsController.fetchedObjects.count / 2 + 1;
    return result;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier;
    
    if (indexPath.row == 0) {
        cellIdentifier = @"MainCell1";
    }
    else {
        cellIdentifier = @"MainCell4";
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
        cell = [nibs objectAtIndex:0];
        [self prepareCell:cell atIndexPath:indexPath];
    }
    
    [self clearCell:cell adIndexPath:indexPath];
    [self configureCell:cell adIndexPath:indexPath];
    return cell;
}

- (void)prepareContentView:(UIView *)contentView {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:contentView.bounds];
    imageView.autoresizingMask = contentView.autoresizingMask;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.hidden = YES;
    imageView.tag = kCELL_IMAGE_VIEW;
    [contentView addSubview:imageView];
    
    VideoView *videoView = [[VideoView alloc] initWithFrame:contentView.bounds];
    videoView.autoresizingMask = contentView.autoresizingMask;
    videoView.contentMode = UIViewContentModeScaleAspectFit;
    videoView.hidden = YES;
    videoView.tag = kCELL_VIDEO_VIEW;
    [contentView addSubview:videoView];
    
    UILabel *textView = [[UILabel alloc] initWithFrame:contentView.bounds];
    textView.backgroundColor = [UIColor blackColor];
    textView.textColor = [UIColor whiteColor];
    textView.autoresizingMask = contentView.autoresizingMask;
    textView.tag = kCELL_TEXT_VIEW;
    textView.lineBreakMode = UILineBreakModeWordWrap;
    textView.numberOfLines = 0;
    textView.hidden = YES;
    [contentView addSubview:textView];
    
    CustomBadge *badge = [CustomBadge customBadgeWithString:@""];
    int x = 0;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        x = contentView.frame.size.width - 25;
    }
    else {
        x = contentView.frame.size.width * (768 / 320.0) - 25;
    }
    badge.frame = CGRectMake(x, 0, 25, 25);
    badge.tag = kCELL_BADGE;
    [contentView addSubview:badge];
    [badge setNeedsDisplay];
}

- (void)prepareCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    UIView *contentView = (UIView *)[cell viewWithTag:kCELL_CONTENT_VIEW1];
    if (contentView) {
        [self prepareContentView:contentView];
    }
    contentView = (UIView *)[cell viewWithTag:kCELL_CONTENT_VIEW2];
    if (contentView) {
        [self prepareContentView:contentView];
    }
}

- (void)clearContentView:(UIView *)contentView {
    UIImageView *imageView = (UIImageView *)[contentView viewWithTag:kCELL_IMAGE_VIEW];
    imageView.image = nil;
    imageView.hidden = YES;
    VideoView *videoView = (VideoView *)[contentView viewWithTag:kCELL_VIDEO_VIEW];
    videoView.hidden = YES;
    videoView.player = nil;
    UILabel *textView = (UILabel *)[contentView viewWithTag:kCELL_TEXT_VIEW];
    textView.text = @"";
    textView.hidden = YES;
    CustomBadge *badge = (CustomBadge *)[contentView viewWithTag:kCELL_BADGE];
    badge.badgeText = @"0";
    [badge setNeedsDisplay];
    contentView.hidden = YES;
}

- (void)clearCell:(UITableViewCell *)cell adIndexPath:(NSIndexPath *)indexPath {
    UIView *contentView = (UIView *)[cell viewWithTag:kCELL_CONTENT_VIEW1];
    if (contentView) {
        [self clearContentView:contentView];
    }
    contentView = (UIView *)[cell viewWithTag:kCELL_CONTENT_VIEW2];
    if (contentView) {
        [self clearContentView:contentView];
        UIImageView *frame = (UIImageView *)[cell viewWithTag:kCELL_FRAME2];
        frame.hidden = YES;
    }
}

- (void)configureContentView:(UIView *)contentView withOffset:(int)offset {
    UIButton *button = (UIButton *)contentView;
    [button addTarget:self action:@selector(onButtonClick:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    contentView.hidden = NO;
    
    Post *post = (Post *)[self.fetchedResultsController.fetchedObjects objectAtIndex:offset];
        
    switch (post.type) {
        case kPostTypePhoto:
        {
            UIImageView *imageView = (UIImageView *)[contentView viewWithTag:kCELL_IMAGE_VIEW];
            imageView.image = post.image.image;
            imageView.hidden = NO;
            break;
        }
        case kPostTypeVideo:
        {
            VideoView *videoView = (VideoView *)[contentView viewWithTag:kCELL_VIDEO_VIEW];
            AVPlayer *player = [AVPlayer playerWithURL:[NSURL URLWithString:post.videoURL]];
            videoView.player = player;
            videoView.hidden = NO;
            [videoView setUserInteractionEnabled:NO];
            break;
        }
        case kPostTypeText:
        {
            UILabel *textView = (UILabel *)[contentView viewWithTag:kCELL_TEXT_VIEW];
            textView.text = post.text;
            textView.hidden = NO;
            break;
        }
    }
    
    CustomBadge *badge = (CustomBadge *)[contentView viewWithTag:kCELL_BADGE];
    badge.badgeText = [NSString stringWithFormat:@"%d", post.likesCount];
    [badge setNeedsDisplay];
}

- (void)configureCell:(UITableViewCell *)cell adIndexPath:(NSIndexPath *)indexPath {
    int offset = 0;
    if (indexPath.row) {
        offset = (indexPath.row - 1) * 2 + 1;
    }
    
    UIView *contentView = (UIView *)[cell viewWithTag:kCELL_CONTENT_VIEW1];    
    if (contentView) {        
        [self configureContentView:contentView withOffset:offset];
    }
    contentView = (UIView *)[cell viewWithTag:kCELL_CONTENT_VIEW2];
    if (contentView && offset + 1 < self.fetchedResultsController.fetchedObjects.count) {
        [self configureContentView:contentView withOffset:offset + 1];
        UIImageView *frame = (UIImageView *)[cell viewWithTag:kCELL_FRAME2];
        frame.hidden = NO;
    }   
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.refreshTableHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self.refreshTableHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark - EGORefreshTableHeaderDelegate
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view {
    [self reloadDataSource];
    [self performSelector:@selector(doneReloadingDataSource) withObject:nil afterDelay:3];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view {
    return self.isLoading;
}

- (NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view {
    return [NSDate date];
}

@end
