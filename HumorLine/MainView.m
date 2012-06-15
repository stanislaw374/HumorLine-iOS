//
//  MainView.m
//  HumorLine
//
//  Created by Yazhenskikh Stanislaw on 11.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MainView.h"
#import "MBProgressHUD.h"
#import "PostsView.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "Post.h"
#import "CustomBadge.h"
#import "OnMapView.h"
#import "Top30View.h"
#import "AddNewView.h"
#import "Config.h"
#import "SCAppUtils.h"
#import "EGORefreshTableHeaderView.h"
#import "Post.h"

#define kCELL1 @"MainCell1"
#define kCELL2 @"MainCell4"

enum { kCELL_CONTENT_VIEW1 = 1, kCELL_CONTENT_VIEW2 = 2, kCELL_FRAME1 = 3, kCELL_FRAME2 = 4, kCELL_BADGE, kCELL_IMAGE_VIEW, kCELL_VIDEO_VIEW, kCELL_TEXT_VIEW };

@interface MainView() <UITableViewDataSource, UITableViewDelegate, EGORefreshTableHeaderDelegate, PostDelegate>
@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) int page;
@property (nonatomic, strong) EGORefreshTableHeaderView *refreshTableHeaderView;
@property (nonatomic) BOOL isLoading;
@property (nonatomic) BOOL doneLoading;
@property (nonatomic, strong) NSMutableArray *posts;

- (void)onButtonClick:(id)sender withEvent:(UIEvent *)event;

- (void)prepareCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)prepareContentView:(UIView *)contentView;
- (void)clearCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)clearContentView:(UIView *)contentView;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)configureContentView:(UIView *)contentView withOffset:(int)offset;
- (void)reloadTableViewDataSource;
- (void)doneReloadingTableViewDataSource;
- (void)loadData;
@end

@implementation MainView
@synthesize tableView = _tableView;
@synthesize refreshTableHeaderView = _refreshTableHeaderView;
@synthesize isLoading = _isLoading;
@synthesize posts = _posts;
@synthesize page = _page;
@synthesize doneLoading = _doneLoading;

#pragma mark - Lazy Instantiation

- (NSMutableArray *)posts {
    if (!_posts) {
        _posts = [[NSMutableArray alloc] init];
    }
    return _posts;
}

#pragma mark - DataSource Loading
- (void)reloadTableViewDataSource {
    [self.posts removeAllObjects];
    self.page = 1;    
    self.doneLoading = NO;
    [self loadData];
}

- (void)doneReloadingTableViewDataSource {
    [self.refreshTableHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    [self.tableView reloadData];
    self.isLoading = NO;
}

- (void)loadData {
    if (!self.doneLoading) {    
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.isLoading = YES;    
        [Post get:self.page++ withDelegate:self];
    }
}

#pragma mark - PostDelegate
- (void)postsDidFailWithError:(NSError *)error {    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    self.doneLoading = YES;
    [self.refreshTableHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    self.isLoading = NO;    
}

- (void)postsDidLoad:(NSArray *)posts {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    if (posts.count > 0) {
        [self.posts addObjectsFromArray:posts];
        [self doneReloadingTableViewDataSource];
    }
    else {
        self.doneLoading = YES;
        [self.refreshTableHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
        self.isLoading = NO;
    }
}

#pragma mark -

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
    
    self.refreshTableHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, 0 - self.tableView.frame.size.height, self.tableView.bounds.size.width, self.tableView.bounds.size.height) arrowImageName:@"whiteArrow.png" textColor:[UIColor whiteColor]];
    self.refreshTableHeaderView.delegate = self;
    [self.tableView addSubview:self.refreshTableHeaderView];
    
    [self reloadTableViewDataSource];
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

#pragma mark - UITableViewDataSource
- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {    
    if (self.posts.count == 1) return 1;
    int result = self.posts.count / 2;
    if (result > 0) result++;
    return result;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    NSString *cellIdentifier;
    if (indexPath.row == 0) {
        cellIdentifier = kCELL1;        
    }
    else cellIdentifier = kCELL2;
    
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
        cell = [nibs objectAtIndex:0];
        [self prepareCell:cell atIndexPath:indexPath];
    }
        
    [self clearCell:cell atIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    
    if (!self.isLoading && indexPath.row == self.posts.count / 2) {
        [self loadData];
    }

    return cell;
}

- (void)prepareContentView:(UIView *)contentView {
    UIButton *button = (UIButton *)contentView;
    [button addTarget:self action:@selector(onButtonClick:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:contentView.bounds];
    imageView.autoresizingMask = contentView.autoresizingMask;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.hidden = YES;
    imageView.tag = kCELL_IMAGE_VIEW;
    [contentView addSubview:imageView];
    
    UILabel *textView = [[UILabel alloc] initWithFrame:contentView.bounds];
    textView.backgroundColor = [UIColor blackColor];
    textView.textColor = [UIColor whiteColor];
    textView.autoresizingMask = contentView.autoresizingMask;
    textView.tag = kCELL_TEXT_VIEW;
    textView.lineBreakMode = UILineBreakModeWordWrap;
    textView.numberOfLines = 0;
    textView.hidden = YES;
    textView.textAlignment = UITextAlignmentCenter;
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
    UILabel *textView = (UILabel *)[contentView viewWithTag:kCELL_TEXT_VIEW];
    textView.text = @"";
    textView.hidden = YES;
    CustomBadge *badge = (CustomBadge *)[contentView viewWithTag:kCELL_BADGE];
    badge.badgeText = @"0";
    [badge setNeedsDisplay];
    contentView.hidden = YES;
}

- (void)clearCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
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
    contentView.hidden = NO;
    
    Post *post = (Post *)[self.posts objectAtIndex:offset];
    
    if ([post.type isEqualToString:@"image"] || [post.type isEqualToString:@"video"]) {
        UIImageView *imageView = (UIImageView *)[contentView viewWithTag:kCELL_IMAGE_VIEW];
        imageView.hidden = NO;
        
        if ([post hasPreviewImage]) {
            imageView.image = post.previewImage;
        }
        else {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:contentView animated:YES];                
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{               
                UIImage *image = post.previewImage;  
                dispatch_async(dispatch_get_main_queue(), ^{
                    imageView.image = image;
                    [hud hide:YES];            
                });
            });
        }
    }
    else if ([post.type isEqualToString:@"text"]) {
        UILabel *textView = (UILabel *)[contentView viewWithTag:kCELL_TEXT_VIEW];
        textView.text = post.text;
        textView.hidden = NO;
    }
    
    CustomBadge *badge = (CustomBadge *)[contentView viewWithTag:kCELL_BADGE];
    badge.badgeText = [NSString stringWithFormat:@"%d", post.likes];
    [badge setNeedsDisplay];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    int offset = 0;
    if (indexPath.row) {
        offset = (indexPath.row - 1) * 2 + 1;
    }
    
    UIView *contentView = (UIView *)[cell viewWithTag:kCELL_CONTENT_VIEW1];    
    if (contentView) {        
        [self configureContentView:contentView withOffset:offset];
    }
    contentView = (UIView *)[cell viewWithTag:kCELL_CONTENT_VIEW2];
    if (contentView && offset + 1 < self.posts.count) {
        [self configureContentView:contentView withOffset:offset + 1];
        UIImageView *frame = (UIImageView *)[cell viewWithTag:kCELL_FRAME2];
        frame.hidden = NO;
    }   
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat result;
    switch (indexPath.row) {
        case 0: result = 310; break;
        default: result = 155;
    }
    return result;
}

#pragma mark - UITableView Events
- (void)onButtonClick:(id)sender withEvent:(UIEvent *)event {
    UIButton *button = (UIButton *)sender;
    UITouch *touch = [event allTouches].anyObject;
    CGPoint touchLocation = [touch locationInView:self.tableView];
    
    int row = [self.tableView indexPathForRowAtPoint:touchLocation].row;
    int offset = 0;
    if (row > 0) {
        offset = (row - 1) * 2 + 1;
    }
    
    PostsView *postsView = [[PostsView alloc] init];
    postsView.posts = self.posts;
    //postsView.page = offset + button.tag - 1;
    Post *post = [self.posts objectAtIndex:offset + button.tag - 1];
    postsView.currentPost = post;
    
    //NSLog(@"%@ , page = %d", NSStringFromSelector(_cmd), postsView.page);    
    
    [self.navigationController pushViewController:postsView animated:YES];
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
    [self reloadTableViewDataSource];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view {
    return self.isLoading;
}

- (NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view {
    return [NSDate date];
}

#pragma mark - Menu
- (IBAction)onAddButtonClick:(id)sender {   
    AddNewView *addNewView = [[AddNewView alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:addNewView];
    [SCAppUtils customizeNavigationController:navigationController];
    [self presentModalViewController:navigationController animated:YES];
}

- (IBAction)onTop30ButtonClick:(id)sender {
    Top30View *top30View = [[Top30View alloc] init];
    [self.navigationController pushViewController:top30View animated:NO];
}

- (IBAction)onMapButtonClick:(id)sender {
    OnMapView *onMapView = [[OnMapView alloc] init];
    [self.navigationController pushViewController:onMapView animated:NO];
}

@end

