//
//  MainView.m
//  HumorLine
//
//  Created by Yazhenskikh Stanislaw on 11.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MainView.h"
#import "UIButton+WebCache.h"
#import "MBProgressHUD.h"
//#import "MainMenu.h"
#import "Constants.h"
#import "PostsView.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "Post.h"
#import "Image.h"
#import <MediaPlayer/MediaPlayer.h>
#import "CustomBadge.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "AddPhotoView.h"
#import "AddVideoView.h"
#import "AddTextView.h"
#import "OnMapView.h"
#import <AVFoundation/AVFoundation.h>
#import "VideoView.h"
#import "Top30View.h"
#import "AddTrololoView.h"
#import "AddNewView.h"
#import "SCAppUtils.h"

#define kCELL1 @"MainCell1"
#define kCELL2 @"MainCell4"

//enum { kTAG_BADGE = 47, kTAG_VIDEO_PLAYER };
enum { kCELL_CONTENT_VIEW1 = 1, kCELL_CONTENT_VIEW2 = 2, kCELL_FRAME1 = 3, kCELL_FRAME2 = 4, kCELL_BADGE, kCELL_IMAGE_VIEW, kCELL_VIDEO_VIEW, kCELL_TEXT_VIEW };

@interface MainView()
@property (nonatomic, strong) AddPhotoView *addPhotoView;
@property (nonatomic, strong) AddVideoView *addVideoView;
@property (nonatomic, strong) AddTextView *addTextView;
@property (nonatomic, strong) OnMapView *onMapView;
@property (nonatomic, strong) Top30View *top30View;
@property (nonatomic, strong) AddTrololoView *addTrololoView;
//-----
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) PostsView *postsView;
@property (nonatomic, strong) EGORefreshTableHeaderView *refreshTableHeaderView;
@property (nonatomic) BOOL isLoading;
@property (strong, nonatomic) NSMutableArray *players;
@property (nonatomic) int rowsCount;
@property (nonatomic) BOOL isMenuOpened;
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) UIActionSheet *photoActionSheet;
@property (nonatomic, strong) UIActionSheet *videoActionSheet;
@property (nonatomic, strong) UIActionSheet *loginActionSheet;
@property (nonatomic) BOOL isMenuMaximized;
@property (nonatomic, strong) UIPopoverController *popoverWithImagePicker;
@property (nonatomic, strong) Vkontakte *vkontakte;
//@property (nonatomic, strong) EGORefreshTableHeaderView *tableHeaderView;

- (void)onButtonClick:(id)sender withEvent:(UIEvent *)event;
//- (void)setButtonContent:(UIButton *)button withPost:(Post *)post;
//- (NSManagedObjectContext *)managedObjectContext;
//- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)reloadTableViewDataSource;
- (void)doneReloadingTableViewDataSource;
//- (void)prepareCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
//- (void)clearCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

// Т
- (void)prepareCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)prepareContentView:(UIView *)contentView;
- (void)clearCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)clearContentView:(UIView *)contentView;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)configureContentView:(UIView *)contentView withOffset:(int)offset;

// Авторизация
- (void)loginWithFacebook;
- (void)loginWithVK;

@end

@implementation MainView
@synthesize tableView = _tableView;
@synthesize menuButton = _menuButton;
@synthesize menu = _menu;
@synthesize menuMaximized = _menuMaximized;
@synthesize postsView = _postsView;
//@synthesize dataSource = _dataSource;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize refreshTableHeaderView = _refreshTableHeaderView;
@synthesize isLoading = _isLoading;
@synthesize players = _players;
@synthesize rowsCount = _rowsCount;
@synthesize isMenuOpened = _isMenuOpened;
@synthesize imagePicker = _imagePicker;
@synthesize photoActionSheet = _photoActionSheet;
@synthesize videoActionSheet = _videoActionSheet;
@synthesize addPhotoView = _addPhotoView;
@synthesize addVideoView = _addVideoView;
@synthesize addTextView = _addTextView;
@synthesize onMapView = _onMapView;
@synthesize isMenuMaximized = _isMenuMaximized;
@synthesize top30View = _top30View;
@synthesize addTrololoView = _addTrololoView;
//@synthesize tableHeaderView = _tableHeaderView;
@synthesize popoverWithImagePicker = _popoverWithImagePicker;
@synthesize loginActionSheet = _loginActionSheet;
@synthesize vkontakte = _vkontakte;

#pragma mark - Lazy Instantiation

- (OnMapView *)onMapView {
    if (!_onMapView) {
        _onMapView = [[OnMapView alloc] init];
    }
    return _onMapView;
}

- (AddPhotoView *)addPhotoView {
    if (!_addPhotoView) {
        _addPhotoView = [[AddPhotoView alloc] init];
    }
    return _addPhotoView;
}

- (AddVideoView *)addVideoView {
    if (!_addVideoView) {
        _addVideoView = [[AddVideoView alloc] init];
    }
    return _addVideoView;
}

- (AddTextView *)addTextView {
    if (!_addTextView) {
        _addTextView = [[AddTextView alloc] init];
    }
    return _addTextView;
}

- (Top30View *)top30View {
    if (!_top30View) {
        _top30View = [[Top30View alloc] init];
    }
    return _top30View;
}

- (AddTrololoView *)addTrololoView {
    if (!_addTrololoView) {
        _addTrololoView = [[AddTrololoView alloc] init];
    }
    return _addTrololoView;
}

- (UIActionSheet *)photoActionSheet {
    if (!_photoActionSheet) {
        _photoActionSheet = [[UIActionSheet alloc] initWithTitle:@"Фото" delegate:self cancelButtonTitle:@"Отмена" destructiveButtonTitle:nil otherButtonTitles:@"Выбрать из библиотеки", @"Сделать фото", nil];
    }
    return _photoActionSheet;
}

- (UIActionSheet *)videoActionSheet {
    if (!_videoActionSheet) {
        _videoActionSheet = [[UIActionSheet alloc] initWithTitle:@"Видео" delegate:self cancelButtonTitle:@"Отмена" destructiveButtonTitle:nil otherButtonTitles:@"Выбрать из библиотеки", @"Снять видео", nil];
    }
    return _videoActionSheet;
}

- (UIActionSheet *)loginActionSheet {
    if (!_loginActionSheet) {
        _loginActionSheet = [[UIActionSheet alloc] initWithTitle:@"Авторизация" delegate:self cancelButtonTitle:@"Отмена" destructiveButtonTitle:nil otherButtonTitles:@"Facebook", @"ВКонтакте", nil];
    }
    return _loginActionSheet;
}

- (UIImagePickerController *)imagePicker {
    if (!_imagePicker) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.delegate = self;
    }
    return _imagePicker;
}

- (PostsView *)postsView {
    if (!_postsView) {
        _postsView = [[PostsView alloc] init];
    }
    return _postsView;
}

- (NSMutableArray *)players {
    
    if (!_players) {
        _players = [[NSMutableArray alloc] init];
    }
    return _players;
}

- (NSManagedObjectContext *)managedObjectContext {
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    return delegate.managedObjectContext;
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (!_fetchedResultsController) {
        // Create the fetch request for the entity.
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        // Edit the entity name as appropriate.
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Post" inManagedObjectContext:[self managedObjectContext]];
        [fetchRequest setEntity:entity];
        
        // Edit the sort key as appropriate.
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[self managedObjectContext] sectionNameKeyPath:nil cacheName:@"Main"];
        //aFetchedResultsController.delegate = self;
        _fetchedResultsController = aFetchedResultsController;
    }
    return _fetchedResultsController;
}

- (Vkontakte *)vkontakte {
    if (!_vkontakte) {
        _vkontakte = [Vkontakte sharedInstance];
        _vkontakte.delegate = self;
    }
    return _vkontakte;
}

#pragma mark -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization        
        //self.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemMostRecent tag:1];
        //self.title = @"Новое";
        //self.tabBarItem.image = [UIImage imageNamed:@"icon_new.png"];
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
    //[self.mainMenu addAddButton];
    //[self.mainMenu addLoginButton];
    
    self.refreshTableHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, 0 - self.tableView.frame.size.height, self.tableView.bounds.size.width, self.tableView.bounds.size.height) arrowImageName:@"whiteArrow.png" textColor:[UIColor whiteColor]];
    self.refreshTableHeaderView.delegate = self;
    [self.tableView addSubview:self.refreshTableHeaderView];
    
    [self reloadTableViewDataSource];
    [self doneReloadingTableViewDataSource];
}

- (void)viewDidUnload
{
    self.fetchedResultsController = nil;
    [self setTableView:nil];
    [self setMenuButton:nil];
    [self setMenu:nil];
    [self setMenuMaximized:nil];
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
    return self.fetchedResultsController.fetchedObjects.count / 2 + 1;
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
    
    VideoView *videoView = [[VideoView alloc] initWithFrame:contentView.bounds];
    videoView.autoresizingMask = contentView.autoresizingMask;
    videoView.contentMode = UIViewContentModeScaleAspectFill;
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
    textView.textAlignment = UITextAlignmentCenter;
    [contentView addSubview:textView];
    
    //CustomBadge *badge = [[CustomBadge alloc] initWithFrame:CGRectMake(contentView.frame.size.width - 25, 0, 25, 25)];
    CustomBadge *badge = [CustomBadge customBadgeWithString:@""];
    //badge.autoresizingMask = contentView.autoresizingMask & !UIViewAutoresizingFlexibleWidth & !UIViewAutoresizingFlexibleHeight;
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
    //[badge setNeedsLayout];
    [badge setNeedsDisplay];
    
    NSLog(@"Badge frame = %@", NSStringFromCGRect(badge.frame));
    NSLog(@"ContentView frame = %@", NSStringFromCGRect(contentView.frame));
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
    
    Post *post = (Post *)[self.fetchedResultsController.fetchedObjects objectAtIndex:offset];
    
    switch (post.type) {
        case kPostTypeImage:
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
    if (contentView && offset + 1 < self.fetchedResultsController.fetchedObjects.count) {
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

#pragma mark - UITableView Click Events

- (void)onButtonClick:(id)sender withEvent:(UIEvent *)event {
    UIButton *button = (UIButton *)sender;
    //UITableViewCell *cell = (UITableViewCell *)[button superview];
    UITouch *touch = [event allTouches].anyObject;
    CGPoint touchLocation = [touch locationInView:self.tableView];
    
    int row = [self.tableView indexPathForRowAtPoint:touchLocation].row;
    int offset = 0;
    if (row > 0) {
        offset = (row - 1) * 2 + 1;
    }
    
    PostsView *postsView = [[PostsView alloc] init];
    postsView.fetchedResultsController = self.fetchedResultsController;
    postsView.currentPage = offset + button.tag - 1;
    
    NSLog(@"current page = %d", self.postsView.currentPage);
    
    [self.navigationController pushViewController:postsView animated:YES];
}

//- (void)setButtonContent:(UIButton *)button withPost:(Post *)post {    
//    button.layer.borderWidth = 10;
//    
//    switch (post.type) {
//        case kPostTypePhoto: {
//            [button setImage:post.image.image forState:UIControlStateNormal];
//            break;
//        }
//        case kPostTypeText:
//            [button setTitle:post.text forState:UIControlStateNormal];
//            break;
//        case kPostTypeVideo:
//        {
////            MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:post.videoURL]];
////            player.shouldAutoplay = NO;
////            player.view.frame = button.bounds;
////            player.scalingMode = MPMovieScalingModeAspectFit;
////            player.view.userInteractionEnabled = NO;
////            [button addSubview:player.view];
////            [self.players addObject:player];
//
//            AVPlayer *player = [AVPlayer playerWithURL:[NSURL URLWithString:post.videoURL]];          
//            VideoView *videoView = [[VideoView alloc] initWithFrame:button.bounds];
//            videoView.autoresizingMask = button.autoresizingMask;
//            [videoView setPlayer:player];
//            videoView.userInteractionEnabled = NO;
//            [button addSubview:videoView];            
//            
//            break;
//        }
//    }
//    
//    CustomBadge *badge = (CustomBadge *)[button viewWithTag:kTAG_BADGE];
//    if (badge) {
//        badge.hidden = NO;
//        badge.badgeText = [NSString stringWithFormat:@"%d", post.likesCount];
//        [badge setNeedsDisplay];
//        [button bringSubviewToFront:badge];
//    }
//    else {
//        NSLog(@"Could not find badge!");
//    }
//}

//- (void)clearCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
//    int offset = indexPath.row;
//    if (indexPath.row > 1) {
//        offset = (indexPath.row - 2) * 3 + 3;
//    }
//    
//    UIButton *button = (UIButton *)[cell viewWithTag:offset + 1];
//    if (button) {
//        [button setImage:nil forState:UIControlStateNormal];
//        [button setTitle:@"" forState:UIControlStateNormal];
//        button.layer.borderWidth = 0;
//        CustomBadge *badge = (CustomBadge *)[button viewWithTag:kTAG_BADGE];
//        badge.hidden = YES;
//    }
//    
//    button = (UIButton *)[cell viewWithTag:offset + 2];
//    if (button) {
//        [button setImage:nil forState:UIControlStateNormal];
//        [button setTitle:@"" forState:UIControlStateNormal];
//        button.layer.borderWidth = 0;
//        CustomBadge *badge = (CustomBadge *)[button viewWithTag:kTAG_BADGE];
//        badge.hidden = YES;
//    }
//    
//    button = (UIButton *)[cell viewWithTag:offset + 3];
//    if (button) {
//        [button setImage:nil forState:UIControlStateNormal];
//        [button setTitle:@"" forState:UIControlStateNormal];
//        button.layer.borderWidth = 0;
//        CustomBadge *badge = (CustomBadge *)[button viewWithTag:kTAG_BADGE];
//        badge.hidden = YES;
//    }
//}
//
//- (void)prepareCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
//    //cell.backgroundColor = [UIColor blackColor];
//    switch (indexPath.row) {
//        case 0:
//        {
//            int sx = 20, sy = 20;
//            CGFloat rowHeight = [self tableView:self.tableView heightForRowAtIndexPath:indexPath];
//            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, rowHeight - sx, rowHeight - sy)];            
//            button.center = CGPointMake(self.tableView.frame.size.width / 2, button.center.y);
//            [button addTarget:self action:@selector(onButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//            [cell addSubview:button];
//            //button.layer.borderWidth = borderWidth;
//            button.layer.borderColor = [[UIColor whiteColor] CGColor];
//            button.contentMode = UIViewContentModeScaleAspectFit;
//            button.tag = indexPath.row + 1;
//            button.backgroundColor = [UIColor blackColor];
//            
//            [cell addSubview:button];
//            
//            CustomBadge *customBadge = [CustomBadge customBadgeWithString:@"0"];
//            customBadge.frame = CGRectMake(button.frame.size.width - customBadge.frame.size.width, 0, customBadge.frame.size.width, customBadge.frame.size.height);
//            customBadge.tag = kTAG_BADGE;
//            customBadge.hidden = YES;
//            [button addSubview:customBadge];
//            break;
//        }
//        case 1:
//        {
//            int sx = 25, sy = 10;
//            int dx = 8;
//            int buttonSize = (self.tableView.frame.size.width - 2 * sx - dx) / 2;
//            UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake(sx, sy, buttonSize, buttonSize)];       
//            [button1 addTarget:self action:@selector(onButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//            //button1.layer.borderWidth = borderWidth;
//            button1.layer.borderColor = [[UIColor whiteColor] CGColor];
//            button1.contentMode = UIViewContentModeScaleAspectFit;
//            button1.tag = indexPath.row + 1;
//            button1.backgroundColor = [UIColor blackColor];
//            //[self setButtonContent:button1 withPost:post];
//            
//            //post = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section]];
//            UIButton *button2 = [[UIButton alloc] initWithFrame:CGRectMake(button1.frame.origin.x + button1.frame.size.width + dx, sy, buttonSize, buttonSize)];
//            //[button2 setImageWithURL:pic2.url];
//            [button2 addTarget:self action:@selector(onButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//            //button2.layer.borderWidth = borderWidth;
//            button2.layer.borderColor = [[UIColor whiteColor] CGColor];
//            button2.contentMode = UIViewContentModeScaleAspectFit;
//            button2.tag = indexPath.row + 2;
//            button2.backgroundColor = [UIColor blackColor];
//            //[self setButtonContent:button2 withPost:post];
//            
//            [cell addSubview:button1];
//            [cell addSubview:button2];        
//            
//            CustomBadge *customBadge = [CustomBadge customBadgeWithString:@"0"];
//            customBadge.frame = CGRectMake(button1.frame.size.width - customBadge.frame.size.width, 0, customBadge.frame.size.width, customBadge.frame.size.height);
//            customBadge.tag = kTAG_BADGE;
//            customBadge.hidden = YES;
//            [button1 addSubview:customBadge];
//            
//            customBadge = [CustomBadge customBadgeWithString:@"0"];
//            customBadge.frame = CGRectMake(button2.frame.size.width - customBadge.frame.size.width, 0, customBadge.frame.size.width, customBadge.frame.size.height);
//            customBadge.tag = kTAG_BADGE;
//            customBadge.hidden = YES;
//            [button2 addSubview:customBadge];
//            
//            break;
//        }
//        default:
//        {
//            int sx = 30, sy = 10;
//            int dx = 8;
//            int buttonSize = (self.tableView.frame.size.width - 2 * sx - 2 * dx) / 3;
//            
//            int offset = (indexPath.row - 2) * 3 + 3;
//            //NSIndexPath *ip = [NSIndexPath indexPathForRow:offset inSection:0];            
//            
//            UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake(sx, sy, buttonSize, buttonSize)];            
//            [button1 addTarget:self action:@selector(onButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//            button1.layer.borderColor = [[UIColor whiteColor] CGColor];
//            button1.contentMode = UIViewContentModeScaleAspectFit;
//            button1.tag = offset + 1;
//            button1.backgroundColor = [UIColor blackColor];
//            
//            UIButton *button2 = [[UIButton alloc] initWithFrame:CGRectMake(button1.frame.origin.x + button1.frame.size.width + dx, sy, buttonSize, buttonSize)];
//            [button2 addTarget:self action:@selector(onButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//            button2.layer.borderColor = [[UIColor whiteColor] CGColor];
//            button2.contentMode = UIViewContentModeScaleAspectFit;
//            button2.tag = offset + 2;
//            button2.backgroundColor = [UIColor blackColor];
//            
//            UIButton *button3 = [[UIButton alloc] initWithFrame:CGRectMake(button2.frame.origin.x + button2.frame.size.width + dx, sy, buttonSize, buttonSize)];                
//            [button3 addTarget:self action:@selector(onButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//            button3.layer.borderColor = [[UIColor whiteColor] CGColor];
//            button3.contentMode = UIViewContentModeScaleAspectFit;
//            button3.tag = offset + 3;
//            button3.backgroundColor = [UIColor blackColor];
//            
//            [cell addSubview:button1];
//            [cell addSubview:button2];  
//            [cell addSubview:button3]; 
//            
//            CustomBadge *customBadge1 = [CustomBadge customBadgeWithString:@"0"];
//            customBadge1.frame = CGRectMake(button1.frame.size.width - customBadge1.frame.size.width, 0, customBadge1.frame.size.width, customBadge1.frame.size.height);
//            customBadge1.tag = kTAG_BADGE;
//            customBadge1.hidden = YES;
//            [button1 addSubview:customBadge1];
//            
//            CustomBadge *customBadge2 = [CustomBadge customBadgeWithString:@"0"];
//            customBadge2.frame = CGRectMake(button2.frame.size.width - customBadge2.frame.size.width, 0, customBadge2.frame.size.width, customBadge2.frame.size.height);
//            customBadge2.tag = kTAG_BADGE;
//            customBadge2.hidden = YES;
//            [button2 addSubview:customBadge2];
//            
//            CustomBadge *customBadge3 = [CustomBadge customBadgeWithString:@"0"];
//            customBadge3.frame = CGRectMake(button3.frame.size.width - customBadge3.frame.size.width, 0, customBadge3.frame.size.width, customBadge3.frame.size.height);
//            customBadge3.tag = kTAG_BADGE;
//            customBadge3.hidden = YES;
//            [button3 addSubview:customBadge3];
//        }
//    }                            
//}
//
//- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
//    //CGFloat rowHeight = [self tableView:self.tableView heightForRowAtIndexPath:indexPath];
//    //int borderWidth = 1;
//    
//    //NSLog(@"%@ : %@", NSStringFromSelector(_cmd), indexPath.description);
//    
//    int offset = indexPath.row;
//    if (indexPath.row > 1) {
//        offset = (indexPath.row - 2) * 3 + 3;
//    }
//    switch (indexPath.row) {
//        case 0:
//        {        
//            Post *post = [self.fetchedResultsController objectAtIndexPath:indexPath];
//            UIButton *button = (UIButton *)[cell viewWithTag:offset + 1];
//            [self setButtonContent:button withPost:post];
//            break;
//        }
//        case 1:
//        {            
//            Post *post = [self.fetchedResultsController objectAtIndexPath:indexPath];
//            UIButton *button = (UIButton *)[cell viewWithTag:offset + 1];
//            [self setButtonContent:button withPost:post];
//            
//            post = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section]];
//            button = (UIButton *)[cell viewWithTag:offset + 2];
//            [self setButtonContent:button withPost:post];
//            break;
//        }
//        default:
//        {
//            //int offset = (indexPath.row - 2) * 3 + 3;
//            
//            NSIndexPath *ip = [NSIndexPath indexPathForRow:offset inSection:indexPath.section];
//            UIButton *button1, *button2, *button3;
//            Post *post;
//            if (ip.row < self.fetchedResultsController.fetchedObjects.count) {            
//                post = [self.fetchedResultsController objectAtIndexPath:ip];
//                button1 = (UIButton *)[cell viewWithTag:offset + 1];                
//                [self setButtonContent:button1 withPost:post];
//            }
//            
//            ip = [NSIndexPath indexPathForRow:offset + 1 inSection:indexPath.section];           
//            if (ip.row < self.fetchedResultsController.fetchedObjects.count) {
//                post = [self.fetchedResultsController objectAtIndexPath:ip];
//                button2 = (UIButton *)[cell viewWithTag:offset + 2];                
//                [self setButtonContent:button2 withPost:post];
//            }
//            
//            ip = [NSIndexPath indexPathForRow:offset + 2 inSection:indexPath.section];           
//            if (ip.row < self.fetchedResultsController.fetchedObjects.count) {
//                post = [self.fetchedResultsController objectAtIndexPath:ip];
//                button3 = (UIButton *)[cell viewWithTag:offset + 3];
//                [self setButtonContent:button3 withPost:post];
//            }
//        }
//    }
//}

#pragma mark - NSFetchedResultsControllerDelegate
//
//- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
//    [self.tableView beginUpdates];
//}
//
//- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
//    NSLog(@"%@", NSStringFromSelector(_cmd));
//    
//    switch (type) {
//        case NSFetchedResultsChangeUpdate:
//        {
//            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
//            [self configureCell:cell atIndexPath:indexPath];
//            break;        
//        }
//    }
//}
//
//- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
//    [self.tableView endUpdates];
//}

#pragma mark - Scrolling
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.refreshTableHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self.refreshTableHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark - EGORefreshTableHeaderDelegate
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view {
    [self reloadTableViewDataSource];
    [self performSelector:@selector(doneReloadingTableViewDataSource) withObject:nil afterDelay:3];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view {
    return self.isLoading;
}

- (NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view {
    return [NSDate date];
}

#pragma mark - DataSource Reloading
- (void)reloadTableViewDataSource {
    self.isLoading = YES;
    
    NSError *error;
    [self.fetchedResultsController performFetch:&error];
    if (error) {
        NSLog(@"Fetch error: %@", error.localizedDescription);
    }
//    else {
//        self.rowsCount = 0;
//        for (int i = 0; i < self.fetchedResultsController.fetchedObjects.count - 1; i++) {
//            int sequentalCount = 0;
//            while (1) {
//                
//            }
//        }
//    }
}

- (void)doneReloadingTableViewDataSource {
    self.isLoading = NO;
    [self.refreshTableHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    [self.tableView reloadData];
}

#pragma mark - Menu
- (IBAction)onAddButtonClick:(id)sender {
//    if (!self.isMenuMaximized) {
//        self.menuMaximized.hidden = NO;
//        CGRect frame = self.menuButton.frame;
//        frame.origin.y -= 85;
//        self.menuButton.frame = frame;
//        self.isMenuMaximized = YES;
//    }
//    else {
//        self.menuMaximized.hidden = YES;
//        CGRect frame = self.menuButton.frame;
//        frame.origin.y += 85;
//        self.menuButton.frame = frame;
//        self.isMenuMaximized = NO;
//    }
    
    AddNewView *addNewView = [[AddNewView alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:addNewView];
    [SCAppUtils customizeNavigationController:navigationController];
    [self presentModalViewController:navigationController animated:YES];
    
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//    [UIView setAnimationDuration:0.75];
//    [self.navigationController pushViewController:addNewView animated:NO];
//    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.navigationController.view cache:NO];
//    [UIView commitAnimations];
}

- (IBAction)onLoginButtonClick:(id)sender {
    [self onMenuButtonClick:nil];
    [self.loginActionSheet showInView:self.view];
}

- (IBAction)onTop30ButtonClick:(id)sender {
    //[self onMenuButtonClick:nil];
    
    [self.navigationController pushViewController:self.top30View animated:NO];
}

- (IBAction)onMapButtonClick:(id)sender {
    [self onMenuButtonClick:nil];
    OnMapView *onMapView = [[OnMapView alloc] init];
    [self.navigationController pushViewController:onMapView animated:NO];
}

- (IBAction)onTrololoButtonClick:(id)sender {
    //[self presentModalViewController:self.addTrololoView animated:YES];
    [self onMenuButtonClick:nil];
    [self.navigationController pushViewController:self.addTrololoView animated:YES];
}

- (IBAction)onPhotoButtonClick:(id)sender {
    [self onMenuButtonClick:nil];
    [self.photoActionSheet showInView:self.view];
}

- (IBAction)onVideoButtonClick:(id)sender {
    [self onMenuButtonClick:nil];
    [self.videoActionSheet showInView:self.view];
}

- (IBAction)onTextButtonClick:(id)sender {
    [self onMenuButtonClick:nil];
    [self presentModalViewController:self.addTextView animated:YES];
}

- (IBAction)onMenuButtonClick:(id)sender {
    if (!self.isMenuOpened) { 
        if (!self.isMenuMaximized) {
            [UIView animateWithDuration:0.3f animations:^{
                CGRect frame = self.menuButton.frame;
                frame.origin.y -= 85;
                self.menuButton.frame = frame;
                frame = self.menu.frame;
                frame.origin.y -= 85;
                self.menu.frame = frame;
            } completion:^(BOOL finished) {
                [self.menuButton setImage:[UIImage imageNamed:@"menu_button_pressed"] forState:UIControlStateNormal];
                self.isMenuOpened = YES;
            }];
        }
        else {
            [UIView animateWithDuration:0.3f animations:^{
                CGRect frame = self.menuButton.frame;
                frame.origin.y -= 85 * 2;
                self.menuButton.frame = frame;
                frame = self.menu.frame;
                frame.origin.y -= 85;
                self.menu.frame = frame;
                frame = self.menuMaximized.frame;
                frame.origin.y -= 85 * 2;
                self.menuMaximized.frame = frame;
            } completion:^(BOOL finished) {
                [self.menuButton setImage:[UIImage imageNamed:@"menu_button_pressed"] forState:UIControlStateNormal];
                self.isMenuOpened = YES;
            }];
        }
    }
    else {
        if (!self.isMenuMaximized) {
            [UIView animateWithDuration:0.3f animations:^{
                CGRect frame = self.menuButton.frame;
                frame.origin.y += 85;
                self.menuButton.frame = frame;
                frame = self.menu.frame;
                frame.origin.y += 85;
                self.menu.frame = frame;
            } completion:^(BOOL finished) {
                [self.menuButton setImage:[UIImage imageNamed:@"menu_button"] forState:UIControlStateNormal];
                self.isMenuOpened = NO;
            }];
        }
        else {
            [UIView animateWithDuration:0.3f animations:^{
                CGRect frame = self.menuButton.frame;
                frame.origin.y += 85 * 2;
                self.menuButton.frame = frame;
                frame = self.menu.frame;
                frame.origin.y += 85;
                self.menu.frame = frame;
                frame = self.menuMaximized.frame;
                frame.origin.y += 85 * 2;
                self.menuMaximized.frame = frame;
            } completion:^(BOOL finished) {
                [self.menuButton setImage:[UIImage imageNamed:@"menu_button"] forState:UIControlStateNormal];
                self.isMenuOpened = NO;
            }];
        }
    }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {    
    if ([actionSheet isEqual:self.photoActionSheet] || [actionSheet isEqual:self.videoActionSheet]) {
        UIImagePickerControllerSourceType sourceType;
        
        switch (buttonIndex) {
            case 0:
                sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                break;
            case 1:
                sourceType = UIImagePickerControllerSourceTypeCamera;
                break;
            default:
                return;
        }
        if (![UIImagePickerController isSourceTypeAvailable:sourceType]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:@"Источник не доступен" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
            [alert show];
        }
        else {
            self.imagePicker.sourceType = sourceType;
            if ([actionSheet isEqual:self.videoActionSheet]) {
                self.imagePicker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, nil];
            }
            else {
                self.imagePicker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeImage, nil];
            }
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                [self presentModalViewController:self.imagePicker animated:YES];
            }
            else {
                self.popoverWithImagePicker = [[UIPopoverController alloc] initWithContentViewController:self.imagePicker];
                [self.popoverWithImagePicker presentPopoverFromRect:CGRectMake(self.view.center.x, self.view.center.y, 1, 1) inView:self.view permittedArrowDirections:0 animated:YES];
            }
        }
    }
    else if ([actionSheet isEqual:self.loginActionSheet]) {
        switch (buttonIndex) {
            case 0:
                [self loginWithFacebook];
                break;
            case 1:
                [self loginWithVK];
                break;
            default: return;
        }
    }
}

#pragma mark - UIImagePickerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self dismissModalViewControllerAnimated:NO];
    }
    else {
        [self.popoverWithImagePicker dismissPopoverAnimated:NO];
    }
    
    CFStringRef mediaType = (__bridge CFStringRef)[info objectForKey:UIImagePickerControllerMediaType];
    
    if (CFStringCompare (mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        AddPhotoView *addPhotoView = [[AddPhotoView alloc] init];
        addPhotoView.image = image;
        [self presentModalViewController:addPhotoView animated:YES];
    }
    else if (CFStringCompare(mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
        NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
        //NSLog(@"videoURL : %@", videoURL.description);
        
        AddVideoView *addVideoView = [[AddVideoView alloc] init];
        addVideoView.videoURL = videoURL;
        [self presentModalViewController:addVideoView animated:YES];
    }    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Sign in
- (void)loginWithFacebook {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    Facebook *facebook = appDelegate.facebook;    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"] 
        && [defaults objectForKey:@"FBExpirationDateKey"]) {
        facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }
    
    if (![facebook isSessionValid]) {
        [facebook authorize:nil];
    }
}

- (void)loginWithVK {
    if (![self.vkontakte isAuthorized]) 
    {
        [self.vkontakte authenticate];
    }
    else
    {
        [self.vkontakte logout];
    }
}

#pragma mark - VkontakteDelegate
- (void)vkontakteDidFailedWithError:(NSError *)error {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)showVkontakteAuthController:(UIViewController *)controller {
    [self presentModalViewController:controller animated:YES];
}

- (void)vkontakteAuthControllerDidCancelled {
    [self dismissModalViewControllerAnimated:YES];
}

@end

