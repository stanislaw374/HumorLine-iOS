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
#import "MainMenu.h"
#import "Constants.h"
#import "DetailView.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "Post.h"
#import "Image.h"
#import <MediaPlayer/MediaPlayer.h>

@interface MainView()
- (void)onButtonClick:(id)sender;
@property (nonatomic, strong) MainMenu *mainMenu;
@property (nonatomic, strong) DetailView *detailView;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) EGORefreshTableHeaderView *refreshTableHeaderView;
@property (nonatomic) BOOL isLoading;
@property (nonatomic, strong) NSMutableArray *players;
- (void)setButtonContent:(UIButton *)button withPost:(Post *)post;
- (NSManagedObjectContext *)managedObjectContext;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)reloadTableViewDataSource;
- (void)doneReloadingTableViewDataSource;
- (void)prepareCell:(UITableViewCell *)cell;
@end

@implementation MainView
@synthesize tableView = _tableView;
@synthesize mainMenu = _mainMenu;
@synthesize detailView = _detailView;
@synthesize dataSource = _dataSource;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize refreshTableHeaderView = _refreshTableHeaderView;
@synthesize isLoading = _isLoading;
@synthesize players = _players;

/*
 - (NSFetchedResultsController *)fetchedResultsController {
 // Set up the fetched results controller if needed.
 if (fetchedResultsController == nil) {
 
 }
 
 return fetchedResultsController;
 } 
 */

#pragma mark - Lazy Instantiation

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
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"likesCount" ascending:NO];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[self managedObjectContext] sectionNameKeyPath:nil cacheName:@"Root"];
        //aFetchedResultsController.delegate = self;
        _fetchedResultsController = aFetchedResultsController;
    }
    return _fetchedResultsController;
}

- (DetailView *)detailView {
    if (!_detailView) {
        _detailView = [[DetailView alloc] init];
    }
    return _detailView;
}

- (MainMenu *)mainMenu {
    if (!_mainMenu) {
        _mainMenu = [[MainMenu alloc] initWithViewController:self];
    }
    return _mainMenu;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"HumorLine";
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
    [self.mainMenu addAddButton];
    [self.mainMenu addLoginButton];
    
    self.refreshTableHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, 0 - self.tableView.frame.size.height, self.tableView.bounds.size.width, self.tableView.bounds.size.height) arrowImageName:@"whiteArrow.png" textColor:[UIColor whiteColor]];
    //self.refreshTableHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, 0 - self.tableView.frame.size.height, self.tableView.bounds.size.width, self.tableView.bounds.size.height)];
    self.refreshTableHeaderView.delegate = self;
    [self.tableView addSubview:self.refreshTableHeaderView];
    
    [self reloadTableViewDataSource];
    [self doneReloadingTableViewDataSource];
}

- (void)viewDidUnload
{
    self.fetchedResultsController = nil;
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
    id<NSFetchedResultsSectionInfo> info = [self.fetchedResultsController.sections objectAtIndex:section];
    
    NSLog(@"Number of objects : %d", [info numberOfObjects]);
    //[info numberOfObjects] % 3;
    int result = [info numberOfObjects] / 3 + 1;
    if ([info numberOfObjects] % 3) result++;
    return result;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kCell;
    kCell = @"MainViewCell";

    UITableViewCell *cell;
    if (indexPath.row < 2) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:kCell];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCell];
        }
    }
   
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
    //Picture *currentPicture = [self.dataSource objectAtIndex:button.tag];
    //self.detailView.currentPicture = currentPicture;
    [self.navigationController pushViewController:self.detailView animated:YES];
}

- (void)setButtonContent:(UIButton *)button withPost:(Post *)post {
    switch (post.type) {
        case kPostTypePhoto:
        {
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
}

- (void)prepareCell:(UITableViewCell *)cell {
    
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    CGFloat rowHeight = [self tableView:self.tableView heightForRowAtIndexPath:indexPath];
    int borderWidth = 1;
    
    //NSLog(@"%@ : %@", NSStringFromSelector(_cmd), indexPath.description);
    
    switch (indexPath.row) {
        case 0:
        {
            //Picture *pic = [self.dataSource objectAtIndex:indexPath.row];
            Post *post = [self.fetchedResultsController objectAtIndexPath:indexPath];
            int sx = 20, sy = 20;
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, rowHeight - sx, rowHeight - sy)];            
            button.center = CGPointMake(self.tableView.frame.size.width / 2, button.center.y);
            [button addTarget:self action:@selector(onButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:button];
            button.layer.borderWidth = borderWidth;
            button.layer.borderColor = [[UIColor whiteColor] CGColor];
            button.contentMode = UIViewContentModeScaleAspectFit;
            button.tag = indexPath.row;
            [self setButtonContent:button withPost:post];
            break;
        }
        case 1:
        {
            //Picture *pic1 = [self.dataSource objectAtIndex:indexPath.row];
            Post *post = [self.fetchedResultsController objectAtIndexPath:indexPath];
            int sx = 25, sy = 10;
            int dx = 8;
            int buttonSize = (self.tableView.frame.size.width - 2 * sx - dx) / 2;
            UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake(sx, sy, buttonSize, buttonSize)];       
            [button1 addTarget:self action:@selector(onButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            button1.layer.borderWidth = borderWidth;
            button1.layer.borderColor = [[UIColor whiteColor] CGColor];
            button1.contentMode = UIViewContentModeScaleAspectFit;
            button1.tag = indexPath.row;
            [self setButtonContent:button1 withPost:post];
            
            post = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section]];
            UIButton *button2 = [[UIButton alloc] initWithFrame:CGRectMake(button1.frame.origin.x + button1.frame.size.width + dx, sy, buttonSize, buttonSize)];
            //[button2 setImageWithURL:pic2.url];
            [button2 addTarget:self action:@selector(onButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            button2.layer.borderWidth = borderWidth;
            button2.layer.borderColor = [[UIColor whiteColor] CGColor];
            button2.contentMode = UIViewContentModeScaleAspectFit;
            button2.tag = indexPath.row + 1;
            [self setButtonContent:button2 withPost:post];
            
            [cell addSubview:button1];
            [cell addSubview:button2];            
            break;
        }
        default:
        {
            int sx = 30, sy = 10;
            int dx = 8;
            int buttonSize = (self.tableView.frame.size.width - 2 * sx - 2 * dx) / 3;
            
            int offset = (indexPath.row - 2) * 3 + 3;
//            if (indexPath.row == 2) offset = 1;
//            else offset = indexPath.row * 2;
            
            NSIndexPath *ip = [NSIndexPath indexPathForRow:offset inSection:indexPath.section];
            UIButton *button1, *button2, *button3;
            Post *post;
            if (ip.row < self.fetchedResultsController.fetchedObjects.count) {            
                post = [self.fetchedResultsController objectAtIndexPath:ip];
                button1 = (UIButton *)[cell viewWithTag:ip.row];
                if (!button1) {
                    button1 = [[UIButton alloc] initWithFrame:CGRectMake(sx, sy, buttonSize, buttonSize)];            
                    [button1 addTarget:self action:@selector(onButtonClick:) forControlEvents:UIControlEventTouchUpInside];
                    button1.layer.borderWidth = borderWidth;
                    button1.layer.borderColor = [[UIColor whiteColor] CGColor];
                    button1.contentMode = UIViewContentModeScaleAspectFit;
                    button1.tag = ip.row;
                }
                else {
                    [button1 setImage:nil forState:UIControlStateNormal];
                    [button1 setTitle:@"" forState:UIControlStateNormal];
//                    for (UIView *view in button1.subviews) {
//                        [view removeFromSuperview];
//                    }
                }
                [self setButtonContent:button1 withPost:post];
            }
            
            ip = [NSIndexPath indexPathForRow:offset + 1 inSection:indexPath.section];           
            if (ip.row < self.fetchedResultsController.fetchedObjects.count)
            {
                post = [self.fetchedResultsController objectAtIndexPath:ip];
                button2 = (UIButton *)[cell viewWithTag:ip.row];
                if (!button2) {
                    button2 = [[UIButton alloc] initWithFrame:CGRectMake(button1.frame.origin.x + button1.frame.size.width + dx, sy, buttonSize, buttonSize)];
                    [button2 addTarget:self action:@selector(onButtonClick:) forControlEvents:UIControlEventTouchUpInside];
                    button2.layer.borderWidth = borderWidth;
                    button2.layer.borderColor = [[UIColor whiteColor] CGColor];
                    button2.contentMode = UIViewContentModeScaleAspectFit;
                    button2.tag = ip.row;
                }
                else {
                    [button2 setImage:nil forState:UIControlStateNormal];
                    [button2 setTitle:@"" forState:UIControlStateNormal];
//                    for (UIView *view in button2.subviews) {
//                        [view removeFromSuperview];
//                    }
                }
                [self setButtonContent:button2 withPost:post];
            }
            
            ip = [NSIndexPath indexPathForRow:offset + 2 inSection:indexPath.section];           
            if (ip.row < self.fetchedResultsController.fetchedObjects.count) {
                post = [self.fetchedResultsController objectAtIndexPath:ip];
                button3 = (UIButton *)[cell viewWithTag:ip.row];
                if (!button3) {
                    button3 = [[UIButton alloc] initWithFrame:CGRectMake(button2.frame.origin.x + button2.frame.size.width + dx, sy, buttonSize, buttonSize)];                
                    [button3 addTarget:self action:@selector(onButtonClick:) forControlEvents:UIControlEventTouchUpInside];
                    button3.layer.borderWidth = borderWidth;
                    button3.layer.borderColor = [[UIColor whiteColor] CGColor];
                    button3.contentMode = UIViewContentModeScaleAspectFit;
                    button3.tag = ip.row;
                }
                else {
                    [button3 setImage:nil forState:UIControlStateNormal];
                    [button3 setTitle:@"" forState:UIControlStateNormal];
//                    for (UIView *view in button3.subviews) {
//                        [view removeFromSuperview];
//                    }
                }
                [self setButtonContent:button3 withPost:post];
            }
            [cell addSubview:button1];
            [cell addSubview:button2];  
            [cell addSubview:button3];        
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
}

- (void)doneReloadingTableViewDataSource {
    self.isLoading = NO;
    [self.refreshTableHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    [self.tableView reloadData];
}

@end

