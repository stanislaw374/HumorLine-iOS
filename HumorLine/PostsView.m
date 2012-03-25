//
//  DetailView.m
//  SDWebImage
//
//  Created by Yazhenskikh Stanislaw on 12.03.12.
//  Copyright (c) 2012 Dailymotion. All rights reserved.
//

#import "PostsView.h"
#import "UIImageView+WebCache.h"
#import "Constants.h"
//#import "MainMenu.h"
#import "AddCommentView.h"
#import "UIButton+WebCache.h"
#import "Image.h"
#import "PostView.h"
#import "Comment.h"
#import "AppDelegate.h"

@interface PostsView()
//@property (nonatomic, strong) MainMenu *mainMenu;
//@property (nonatomic, strong) AddCommentView *addCommentView;
@property (nonatomic, strong) NSMutableArray *viewControllers;
@property (nonatomic) int pagesCount;
@property (nonatomic, strong) NSArray *comments;
- (void)loadScrollViewWithPage:(int)page;
- (void)initUIForCurrentPage;
@end

@implementation PostsView
@synthesize lblRating;
@synthesize lblComments;
//@synthesize imageView;
@synthesize btnContent;
//@synthesize mainMenu = _mainMenu;
//@synthesize addCommentView = _addCommentView;
//@synthesize post = _post;
@synthesize scrollView;
@synthesize ratingItem;
@synthesize commentsItem;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize currentPage = _currentPage;
@synthesize tableView;
@synthesize pagesCount = _pagesCount;
@synthesize viewControllers = _viewControllers;
@synthesize comments = _comments;

- (NSMutableArray *)viewControllers {
    if (!_viewControllers) {
        _viewControllers = [[NSMutableArray alloc] init];
        for (int i = 0; i < self.pagesCount; i++) {
            [_viewControllers addObject:[NSNull null]];
        }
    }
    return _viewControllers;
}

- (int)pagesCount {
    return self.fetchedResultsController.fetchedObjects.count;
}

//- (AddCommentView *)addCommentView {
//    if (!_addCommentView) {
//        _addCommentView = [[AddCommentView alloc] init];
//    }
//    return _addCommentView;
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
        //self.title = @"Просмотр";
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
    //[self.mainMenu addLoginButton];    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * self.pagesCount, self.scrollView.frame.size.height);
    self.scrollView.contentOffset = CGPointMake(self.currentPage * self.scrollView.frame.size.width, 0);
    
    [self loadScrollViewWithPage:self.currentPage - 1];
    [self loadScrollViewWithPage:self.currentPage];
    [self loadScrollViewWithPage:self.currentPage + 1];
    
    [self initUIForCurrentPage];
}

- (void)viewWillDisappear:(BOOL)animated {
    self.viewControllers = nil;
}

- (void)viewDidUnload
{
    //[self setImageView:nil];
    [self setLblRating:nil];
    [self setLblComments:nil];
    [self setRatingItem:nil];
    [self setCommentsItem:nil];
    [self setBtnContent:nil];
    [self setScrollView:nil];
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

- (IBAction)onPlusButtonClick:(id)sender {
    Post *post = (Post *)[self.fetchedResultsController.fetchedObjects objectAtIndex:self.currentPage];
    self.ratingItem.title = [NSString stringWithFormat:@"%d", ++post.likesCount];
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    NSError *error;
    if (![appDelegate.managedObjectContext save:&error]) {
        NSLog(@"Error saving: %@", error.localizedDescription);
    }
}

- (IBAction)onCommentButtonClick:(id)sender {
    AddCommentView *addCommentView = [[AddCommentView alloc] init];
    addCommentView.post = [self.fetchedResultsController.fetchedObjects objectAtIndex:self.currentPage];
    [self presentModalViewController:addCommentView animated:YES];
}

- (IBAction)onFacebookButtonClick:(id)sender {
}

- (IBAction)onVKButtonClick:(id)sender {
}

#pragma mark - UITableViewDataSource
- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    Post *post = (Post *)[self.fetchedResultsController.fetchedObjects objectAtIndex:self.currentPage];
    return post.comments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kCellIdentifier = @"CommentCell";
    UITableViewCell *cell = [tableView_ dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
    }    

    cell.textLabel.text = ((Comment *)[self.comments objectAtIndex:indexPath.row]).text;
    return cell;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView_ {
    int pageWidth = scrollView_.frame.size.width;
    int page = floor((scrollView_.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.currentPage = page;
    
    [self loadScrollViewWithPage:self.currentPage - 1];
    [self loadScrollViewWithPage:self.currentPage];
    [self loadScrollViewWithPage:self.currentPage + 1];
    
    [self initUIForCurrentPage];
}

- (void)loadScrollViewWithPage:(int)page {
    if (page < 0)
        return;
    if (page >= self.pagesCount)
        return;
    
    // replace the placeholder if necessary
    PostView *controller = [self.viewControllers objectAtIndex:page];
    if ((NSNull *)controller == [NSNull null])
    {
        controller = [[PostView alloc] init];
        controller.post = [self.fetchedResultsController.fetchedObjects objectAtIndex:page];
        [self.viewControllers replaceObjectAtIndex:page withObject:controller];
    }
    
    // add the controller's view to the scroll view
    if (controller.view.superview == nil)
    {
        CGRect frame = scrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        controller.view.frame = frame;
        [scrollView addSubview:controller.view];
    }    
}

- (void)initUIForCurrentPage {
    Post *post = (Post *)[self.fetchedResultsController.fetchedObjects objectAtIndex:self.currentPage];
    self.ratingItem.title = [NSString stringWithFormat:@"%d", post.likesCount];
    self.commentsItem.title = [NSString stringWithFormat:@"%d", post.comments.count];
    
    NSSortDescriptor *desc = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    NSArray *descs = [[NSArray alloc] initWithObjects:desc, nil];
    self.comments = [post.comments sortedArrayUsingDescriptors:descs];
    
    [self.tableView reloadData];
}

@end
