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

#define kCELL_ID1 @"Cell1"
#define kCELL_ID2 @"Cell2"
#define kCELL_ID3 @"Cell3"

enum { kTAG_BADGE = 47, kTAG_VIDEO_PLAYER };

@interface MainView()
- (void)onButtonClick:(id)sender;
//@property (nonatomic, strong) MainMenu *mainMenu;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) PostsView *postsView;
//@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) EGORefreshTableHeaderView *refreshTableHeaderView;
@property (nonatomic) BOOL isLoading;
@property (nonatomic, strong) NSMutableArray *players;
@property (nonatomic) int rowsCount;
@property (nonatomic) BOOL isMenuOpened;
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) UIActionSheet *photoActionSheet;
@property (nonatomic, strong) UIActionSheet *videoActionSheet;
@property (nonatomic, strong) AddPhotoView *addPhotoView;
@property (nonatomic, strong) AddVideoView *addVideoView;
@property (nonatomic, strong) AddTextView *addTextView;
@property (nonatomic, strong) OnMapView *onMapView;
@property (nonatomic) BOOL isMenuMaximized;
- (void)setButtonContent:(UIButton *)button withPost:(Post *)post;
- (NSManagedObjectContext *)managedObjectContext;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)reloadTableViewDataSource;
- (void)doneReloadingTableViewDataSource;
- (void)prepareCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)clearCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
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
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
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

//- (DetailView *)detailView {
//    if (!_detailView) {
//        _detailView = [[DetailView alloc] init];
//    }
//    return _detailView;
//}

//- (MainMenu *)mainMenu {
//    if (!_mainMenu) {
//        _mainMenu = [[MainMenu alloc] initWithViewController:self];
//    }
//    return _mainMenu;
//}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //self.title = @"HumorLine";
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
    id<NSFetchedResultsSectionInfo> info = [self.fetchedResultsController.sections objectAtIndex:section];
    NSLog(@"Number of objects : %d", [info numberOfObjects]);
    
    int result = [info numberOfObjects] / 3 + 1;
    if ([info numberOfObjects] % 3) result++;
    return result;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    NSString *cellIdentifier;
    
    switch (indexPath.row) {
        case 0:
            cellIdentifier = kCELL_ID1;
            break;
        case 1:
            cellIdentifier = kCELL_ID2;
            break;
        default:
            cellIdentifier = kCELL_ID3;
    }
    
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        [self prepareCell:cell atIndexPath:indexPath];
    }
    
    [self clearCell:cell atIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];

    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat result;
    switch (indexPath.row) {
        case 0: result = 300; break;
        case 1: result = 150; break;
        default: result = 100;
    }
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        result *= 2.5;
    }
    return result;
}

#pragma mark -

- (void)onButtonClick:(id)sender {
    UIButton *button = (UIButton *)sender;
    self.postsView.fetchedResultsController = self.fetchedResultsController;
    self.postsView.currentPage = button.tag - 1;
    
    NSLog(@"current page = %d", self.postsView.currentPage);
    
    [self.navigationController pushViewController:self.postsView animated:YES];
}

- (void)setButtonContent:(UIButton *)button withPost:(Post *)post {    
    button.layer.borderWidth = 10;
    
    switch (post.type) {
        case kPostTypePhoto: {
            [button setImage:post.image.image forState:UIControlStateNormal];
            break;
        }
        case kPostTypeText:
            [button setTitle:post.text forState:UIControlStateNormal];
            break;
        case kPostTypeVideo:
        {
            MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:post.videoURL]];
            player.shouldAutoplay = NO;
            //NSLog(@"video url: %@", post.videoURL);
            player.view.frame = button.bounds;
            //NSLog(@"bounds = %@", NSStringFromCGRect(button.bounds));
            player.scalingMode = MPMovieScalingModeAspectFit;
            player.view.userInteractionEnabled = NO;
            [button addSubview:player.view];
            
            [self.players addObject:player];
            break;
        }
    }
    
    CustomBadge *badge = (CustomBadge *)[button viewWithTag:kTAG_BADGE];
    if (badge) {
        badge.hidden = NO;
        badge.badgeText = [NSString stringWithFormat:@"%d", post.likesCount];
        [badge setNeedsDisplay];
        [button bringSubviewToFront:badge];
    }
    else {
        NSLog(@"Could not find badge!");
    }
}

- (void)clearCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    int offset = indexPath.row;
    if (indexPath.row > 1) {
        offset = (indexPath.row - 2) * 3 + 3;
    }
    
    UIButton *button = (UIButton *)[cell viewWithTag:offset + 1];
    if (button) {
        [button setImage:nil forState:UIControlStateNormal];
        [button setTitle:@"" forState:UIControlStateNormal];
        button.layer.borderWidth = 0;
        CustomBadge *badge = (CustomBadge *)[button viewWithTag:kTAG_BADGE];
        badge.hidden = YES;
    }
    
    button = (UIButton *)[cell viewWithTag:offset + 2];
    if (button) {
        [button setImage:nil forState:UIControlStateNormal];
        [button setTitle:@"" forState:UIControlStateNormal];
        button.layer.borderWidth = 0;
        CustomBadge *badge = (CustomBadge *)[button viewWithTag:kTAG_BADGE];
        badge.hidden = YES;
    }
    
    button = (UIButton *)[cell viewWithTag:offset + 3];
    if (button) {
        [button setImage:nil forState:UIControlStateNormal];
        [button setTitle:@"" forState:UIControlStateNormal];
        button.layer.borderWidth = 0;
        CustomBadge *badge = (CustomBadge *)[button viewWithTag:kTAG_BADGE];
        badge.hidden = YES;
    }
}

- (void)prepareCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    //cell.backgroundColor = [UIColor blackColor];
    switch (indexPath.row) {
        case 0:
        {
            int sx = 20, sy = 20;
            CGFloat rowHeight = [self tableView:self.tableView heightForRowAtIndexPath:indexPath];
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, rowHeight - sx, rowHeight - sy)];            
            button.center = CGPointMake(self.tableView.frame.size.width / 2, button.center.y);
            [button addTarget:self action:@selector(onButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:button];
            //button.layer.borderWidth = borderWidth;
            button.layer.borderColor = [[UIColor whiteColor] CGColor];
            button.contentMode = UIViewContentModeScaleAspectFit;
            button.tag = indexPath.row + 1;
            button.backgroundColor = [UIColor blackColor];
            
            [cell addSubview:button];
            
            CustomBadge *customBadge = [CustomBadge customBadgeWithString:@"0"];
            customBadge.frame = CGRectMake(button.frame.size.width - customBadge.frame.size.width, 0, customBadge.frame.size.width, customBadge.frame.size.height);
            customBadge.tag = kTAG_BADGE;
            customBadge.hidden = YES;
            [button addSubview:customBadge];
            break;
        }
        case 1:
        {
            int sx = 25, sy = 10;
            int dx = 8;
            int buttonSize = (self.tableView.frame.size.width - 2 * sx - dx) / 2;
            UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake(sx, sy, buttonSize, buttonSize)];       
            [button1 addTarget:self action:@selector(onButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            //button1.layer.borderWidth = borderWidth;
            button1.layer.borderColor = [[UIColor whiteColor] CGColor];
            button1.contentMode = UIViewContentModeScaleAspectFit;
            button1.tag = indexPath.row + 1;
            button1.backgroundColor = [UIColor blackColor];
            //[self setButtonContent:button1 withPost:post];
            
            //post = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section]];
            UIButton *button2 = [[UIButton alloc] initWithFrame:CGRectMake(button1.frame.origin.x + button1.frame.size.width + dx, sy, buttonSize, buttonSize)];
            //[button2 setImageWithURL:pic2.url];
            [button2 addTarget:self action:@selector(onButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            //button2.layer.borderWidth = borderWidth;
            button2.layer.borderColor = [[UIColor whiteColor] CGColor];
            button2.contentMode = UIViewContentModeScaleAspectFit;
            button2.tag = indexPath.row + 2;
            button2.backgroundColor = [UIColor blackColor];
            //[self setButtonContent:button2 withPost:post];
            
            [cell addSubview:button1];
            [cell addSubview:button2];        
            
            CustomBadge *customBadge = [CustomBadge customBadgeWithString:@"0"];
            customBadge.frame = CGRectMake(button1.frame.size.width - customBadge.frame.size.width, 0, customBadge.frame.size.width, customBadge.frame.size.height);
            customBadge.tag = kTAG_BADGE;
            customBadge.hidden = YES;
            [button1 addSubview:customBadge];
            
            customBadge = [CustomBadge customBadgeWithString:@"0"];
            customBadge.frame = CGRectMake(button2.frame.size.width - customBadge.frame.size.width, 0, customBadge.frame.size.width, customBadge.frame.size.height);
            customBadge.tag = kTAG_BADGE;
            customBadge.hidden = YES;
            [button2 addSubview:customBadge];
            
            break;
        }
        default:
        {
            int sx = 30, sy = 10;
            int dx = 8;
            int buttonSize = (self.tableView.frame.size.width - 2 * sx - 2 * dx) / 3;
            
            int offset = (indexPath.row - 2) * 3 + 3;
            //NSIndexPath *ip = [NSIndexPath indexPathForRow:offset inSection:0];            
            
            UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake(sx, sy, buttonSize, buttonSize)];            
            [button1 addTarget:self action:@selector(onButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            button1.layer.borderColor = [[UIColor whiteColor] CGColor];
            button1.contentMode = UIViewContentModeScaleAspectFit;
            button1.tag = offset + 1;
            button1.backgroundColor = [UIColor blackColor];
            
            UIButton *button2 = [[UIButton alloc] initWithFrame:CGRectMake(button1.frame.origin.x + button1.frame.size.width + dx, sy, buttonSize, buttonSize)];
            [button2 addTarget:self action:@selector(onButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            button2.layer.borderColor = [[UIColor whiteColor] CGColor];
            button2.contentMode = UIViewContentModeScaleAspectFit;
            button2.tag = offset + 2;
            button2.backgroundColor = [UIColor blackColor];
            
            UIButton *button3 = [[UIButton alloc] initWithFrame:CGRectMake(button2.frame.origin.x + button2.frame.size.width + dx, sy, buttonSize, buttonSize)];                
            [button3 addTarget:self action:@selector(onButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            button3.layer.borderColor = [[UIColor whiteColor] CGColor];
            button3.contentMode = UIViewContentModeScaleAspectFit;
            button3.tag = offset + 3;
            button3.backgroundColor = [UIColor blackColor];
            
            [cell addSubview:button1];
            [cell addSubview:button2];  
            [cell addSubview:button3]; 
            
            CustomBadge *customBadge1 = [CustomBadge customBadgeWithString:@"0"];
            customBadge1.frame = CGRectMake(button1.frame.size.width - customBadge1.frame.size.width, 0, customBadge1.frame.size.width, customBadge1.frame.size.height);
            customBadge1.tag = kTAG_BADGE;
            customBadge1.hidden = YES;
            [button1 addSubview:customBadge1];
            
            CustomBadge *customBadge2 = [CustomBadge customBadgeWithString:@"0"];
            customBadge2.frame = CGRectMake(button2.frame.size.width - customBadge2.frame.size.width, 0, customBadge2.frame.size.width, customBadge2.frame.size.height);
            customBadge2.tag = kTAG_BADGE;
            customBadge2.hidden = YES;
            [button2 addSubview:customBadge2];
            
            CustomBadge *customBadge3 = [CustomBadge customBadgeWithString:@"0"];
            customBadge3.frame = CGRectMake(button3.frame.size.width - customBadge3.frame.size.width, 0, customBadge3.frame.size.width, customBadge3.frame.size.height);
            customBadge3.tag = kTAG_BADGE;
            customBadge3.hidden = YES;
            [button3 addSubview:customBadge3];
        }
    }                            
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    //CGFloat rowHeight = [self tableView:self.tableView heightForRowAtIndexPath:indexPath];
    //int borderWidth = 1;
    
    //NSLog(@"%@ : %@", NSStringFromSelector(_cmd), indexPath.description);
    
    int offset = indexPath.row;
    if (indexPath.row > 1) {
        offset = (indexPath.row - 2) * 3 + 3;
    }
    switch (indexPath.row) {
        case 0:
        {        
            Post *post = [self.fetchedResultsController objectAtIndexPath:indexPath];
            UIButton *button = (UIButton *)[cell viewWithTag:offset + 1];
            [self setButtonContent:button withPost:post];
            break;
        }
        case 1:
        {            
            Post *post = [self.fetchedResultsController objectAtIndexPath:indexPath];
            UIButton *button = (UIButton *)[cell viewWithTag:offset + 1];
            [self setButtonContent:button withPost:post];
            
            post = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section]];
            button = (UIButton *)[cell viewWithTag:offset + 2];
            [self setButtonContent:button withPost:post];
            break;
        }
        default:
        {
            //int offset = (indexPath.row - 2) * 3 + 3;
            
            NSIndexPath *ip = [NSIndexPath indexPathForRow:offset inSection:indexPath.section];
            UIButton *button1, *button2, *button3;
            Post *post;
            if (ip.row < self.fetchedResultsController.fetchedObjects.count) {            
                post = [self.fetchedResultsController objectAtIndexPath:ip];
                button1 = (UIButton *)[cell viewWithTag:offset + 1];                
                [self setButtonContent:button1 withPost:post];
            }
            
            ip = [NSIndexPath indexPathForRow:offset + 1 inSection:indexPath.section];           
            if (ip.row < self.fetchedResultsController.fetchedObjects.count) {
                post = [self.fetchedResultsController objectAtIndexPath:ip];
                button2 = (UIButton *)[cell viewWithTag:offset + 2];                
                [self setButtonContent:button2 withPost:post];
            }
            
            ip = [NSIndexPath indexPathForRow:offset + 2 inSection:indexPath.section];           
            if (ip.row < self.fetchedResultsController.fetchedObjects.count) {
                post = [self.fetchedResultsController objectAtIndexPath:ip];
                button3 = (UIButton *)[cell viewWithTag:offset + 3];
                [self setButtonContent:button3 withPost:post];
            }
        }
    }
}

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
    //NSLog(@"%@", NSStringFromSelector(_cmd));
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

//- (IBAction)onMenu1Click:(id)sender {
//    [UIView animateWithDuration:0.3f animations:^ {
//        CGAffineTransform transform = CGAffineTransformMakeTranslation(0, -85);
//        self.menuButton1.transform = transform;
//        self.menuView.transform = transform;
//    } completion:^(BOOL finished) {
//        self.menuButton1.hidden = YES;
//    }];
//}
//
//- (IBAction)onMenu2Click:(id)sender {
//    [UIView animateWithDuration:0.3f animations:^{
//        CGAffineTransform transform = CGAffineTransformMakeTranslation(0, 1);
//        self.menuView.transform = transform;
//        self.menuButton1.transform = transform;        
//    } completion:^(BOOL finished) {
//        self.menuButton1.hidden = NO;
//    }];
//}
//
//- (IBAction)onAddButtonClick:(id)sender {
//    if (!self.isMenuMaximized) {
//        self.menuViewMaximized.hidden = NO;
//        [UIView animateWithDuration:0.5f animations:^{
//            CGAffineTransform tr = CGAffineTransformMakeTranslation(0, -85);
//            self.menuViewMaximized.transform = tr;
//        } completion:^(BOOL finished) {
//            self.isMenuMaximized = YES;
//        }];
//    }
//    else {
//        [UIView animateWithDuration:0.5f animations:^{
//            CGAffineTransform tr = CGAffineTransformMakeTranslation(0, 1);
//            self.menuViewMaximized.transform = tr;
//        } completion:^(BOOL finished) {
//            self.isMenuMaximized = NO;
//            self.menuViewMaximized.hidden = YES;
//        }];
//    }
//}
#pragma mark - Menu
- (IBAction)onAddButtonClick:(id)sender {
    if (!self.isMenuMaximized) {
        self.menuMaximized.hidden = NO;
        CGRect frame = self.menuButton.frame;
        frame.origin.y -= 85;
        self.menuButton.frame = frame;
        self.isMenuMaximized = YES;
    }
    else {
        self.menuMaximized.hidden = YES;
        CGRect frame = self.menuButton.frame;
        frame.origin.y += 85;
        self.menuButton.frame = frame;
        self.isMenuMaximized = NO;
    }
}

- (IBAction)onLoginButtonClick:(id)sender {
}

- (IBAction)onTop30ButtonClick:(id)sender {
}

- (IBAction)onMapButtonClick:(id)sender {
    [self.navigationController pushViewController:self.onMapView animated:YES];
}

- (IBAction)onTrololoButtonClick:(id)sender {
}

- (IBAction)onPhotoButtonClick:(id)sender {
    [self.photoActionSheet showInView:self.view];
}

- (IBAction)onVideoButtonClick:(id)sender {
    [self.videoActionSheet showInView:self.view];
}

- (IBAction)onTextButtonClick:(id)sender {
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
    if ([actionSheet isEqual:self.photoActionSheet]) {
        UIImagePickerControllerSourceType sourceType;
        switch (buttonIndex) {
            case 0:
                sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                break;
            case 1:
                sourceType = UIImagePickerControllerSourceTypeCamera;
                break;
        }
        if (![UIImagePickerController isSourceTypeAvailable:sourceType]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:@"Источник не доступен" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
            [alert show];
        }
        else {
            self.imagePicker.sourceType = sourceType;
            [self presentModalViewController:self.imagePicker animated:YES];
        }
    }
}

#pragma mark - UIImagePickerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissModalViewControllerAnimated:NO];
    
    CFStringRef mediaType = (__bridge CFStringRef)[info objectForKey:UIImagePickerControllerMediaType];
    
    if (CFStringCompare (mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        //AddPhotoView *addPhotoView = [[AddPhotoView alloc] init];
        self.addPhotoView.image = image;
        [self presentModalViewController:self.addPhotoView animated:YES];
    }
    else if (CFStringCompare(mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
        NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
        //NSLog(@"videoURL : %@", videoURL.description);
        
        //AddVideoView *addVideoView = [[AddVideoView alloc] init];
        self.addVideoView.videoURL = videoURL;
        [self presentModalViewController:self.addVideoView animated:YES];
    }    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissModalViewControllerAnimated:YES];
}

@end

