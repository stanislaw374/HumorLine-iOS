//
//  DetailView.m
//  SDWebImage
//
//  Created by Yazhenskikh Stanislaw on 12.03.12.
//  Copyright (c) 2012 Dailymotion. All rights reserved.
//

#import "PostsView.h"
#import "UIImageView+WebCache.h"
#import "AddCommentView.h"
#import "UIButton+WebCache.h"
#import "PostView.h"
#import "Comment.h"
#import "AppDelegate.h"
#import "RKPost.h"
#import "Config.h"
#import "MBProgressHUD.h"

@interface PostsView() <UITableViewDataSource, UIScrollViewDelegate, FBSessionDelegate, FBDialogDelegate>
@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *scrollView;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *btnContent;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *lblRating;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *lblComments;
@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *lblLikes;

@property (nonatomic, strong) NSMutableArray *viewControllers;
@property (nonatomic) int page;
@property (nonatomic) int pagesCount;
@property (nonatomic, strong) NSArray *comments;
@property (nonatomic) BOOL like;

- (IBAction)onPlusButtonClick:(id)sender;
- (IBAction)onCommentButtonClick:(id)sender;
- (IBAction)onFacebookButtonClick:(id)sender;
- (IBAction)onVKButtonClick:(id)sender;

- (void)loadScrollViewWithPage:(int)page;
- (void)initUIForCurrentPage;
- (void)postToFacebook;
//- (void)postToVK;
@end

@implementation PostsView
@synthesize lblRating;
@synthesize lblComments;
@synthesize btnContent;
@synthesize scrollView;
@synthesize tableView;
@synthesize lblLikes;
@synthesize pagesCount = _pagesCount;
@synthesize viewControllers = _viewControllers;
@synthesize comments = _comments;
@synthesize like = _like;
@synthesize page = _page;
@synthesize posts = _posts;
@synthesize currentPost = _currentPost;

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
    return self.posts.count;
}

- (void)setCurrentPost:(Post *)currentPost {
    _currentPost = currentPost;
    int page = [self.posts indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        Post *post = (Post *)obj;
        if ([post.ID isEqualToNumber:_currentPost.ID]) {
            return YES;
        }
        else return NO;
    }];
    self.page = page;
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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * self.pagesCount, self.scrollView.frame.size.height);
    self.scrollView.contentOffset = CGPointMake(self.page * self.scrollView.frame.size.width, 0);
    
    [self loadScrollViewWithPage:self.page - 1];
    [self loadScrollViewWithPage:self.page];
    [self loadScrollViewWithPage:self.page + 1];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        Post *post = (Post *)[self.posts objectAtIndex:self.page];
        [post reload];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self initUIForCurrentPage];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    });
}

- (void)viewWillDisappear:(BOOL)animated {
    self.viewControllers = nil;
}

- (void)viewDidUnload
{
    //[self setImageView:nil];
    [self setLblRating:nil];
    [self setLblComments:nil];
    [self setBtnContent:nil];
    [self setScrollView:nil];
    [self setTableView:nil];
    [self setLblLikes:nil];
    [self setLblComments:nil];
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
    Post *post = (Post *)[self.posts objectAtIndex:self.page];
    [post like];
    //post.likes = [NSNumber numberWithInt:[post.likes intValue] + 1];
    [self initUIForCurrentPage];
}

- (IBAction)onCommentButtonClick:(id)sender {
    AddCommentView *addCommentView = [[AddCommentView alloc] init];
    addCommentView.post = [self.posts objectAtIndex:self.page];
    //[self presentModalViewController:addCommentView animated:YES];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.75];
    [self.navigationController pushViewController:addCommentView animated:NO];
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.navigationController.view cache:NO];
    [UIView commitAnimations];
}

#pragma mark - Facebook
- (IBAction)onFacebookButtonClick:(id)sender {
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.facebook = [[Facebook alloc] initWithAppId:FB_APP_ID andDelegate:self];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"] && [defaults objectForKey:@"FBExpirationDateKey"]) {
        delegate.facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        delegate.facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }
    
    if (![delegate.facebook isSessionValid]) {
        NSArray *permissions = [[NSArray alloc] initWithObjects:@"publish_stream", nil];
        [delegate.facebook authorize:permissions];
    }
    else {
        [self postToFacebook];
    }
}

#pragma mark - FBSessionDelegate
- (void)fbDidLogin {
    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[delegate.facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[delegate.facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
    [self postToFacebook];
}

- (void)postToFacebook {
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    Post *post = (Post *)[self.posts objectAtIndex:self.page];
    
    NSMutableDictionary *params;
    if (1) {
        params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                  FB_APP_ID, @"app_id",
                  post.imageURL, @"link",
                  post.previewImage, @"picture",
                  post.title, @"name",
                  @"", @"caption",
                  post.text, @"description",
                  nil];
    }
    
    NSLog(@"%@: %@", NSStringFromSelector(_cmd), params.description);
    
    [delegate.facebook dialog:@"feed" andParams:params andDelegate:self];
}

- (IBAction)onVKButtonClick:(id)sender {
}

#pragma mark - UITableViewDataSource
- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    Post *post = (Post *)[self.posts objectAtIndex:self.page];
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
    Comment *comment = (Comment *)[((Post *)[self.posts objectAtIndex:self.page]).comments objectAtIndex:indexPath.row];
    cell.textLabel.text = comment.text;
    return cell;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView_ {
    if ([self.scrollView isEqual:scrollView_]) {
            
        int pageWidth = scrollView_.frame.size.width;
        self.page = floor((scrollView_.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        
        [self loadScrollViewWithPage:self.page - 1];
        [self loadScrollViewWithPage:self.page];
        [self loadScrollViewWithPage:self.page + 1];
        
        [self initUIForCurrentPage];
    }
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
        controller.post = [self.posts objectAtIndex:page];
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
    Post *post = (Post *)[self.posts objectAtIndex:self.page];
    self.lblLikes.text = [NSString stringWithFormat:@"%d", post.likes]; 
    self.lblComments.text = [NSString stringWithFormat:@"%d", post.comments.count];
    [self.tableView reloadData];
}

#pragma mark Shit
//- (void)loadObjects {
//    RKObjectManager *om = [RKObjectManager sharedManager];
//    [om loadObjectsAtResourcePath:@"/posts.json" usingBlock:^(RKObjectLoader *loader) {
//        loader.objectMapping = [om.mappingProvider objectMappingForClass:[RKPost class]]; 
//        //loader.delegate = self;
//    }];
//}
//
//- (void)loadObjectsFromDataStore {
//    //RKPost *post = (RKPost *)[self.posts objectAtIndex:self.page];
//}

//- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects {
//    [self loadObjectsFromDataStore];
//}
//
//- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error {
//    NSLog(@"%@ : %@", NSStringFromSelector(_cmd), error.localizedDescription);
//}

@end
