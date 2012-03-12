//
//  DetailView.m
//  SDWebImage
//
//  Created by Yazhenskikh Stanislaw on 12.03.12.
//  Copyright (c) 2012 Dailymotion. All rights reserved.
//

#import "DetailView.h"
#import "UIImageView+WebCache.h"
#import "Constants.h"
#import "MainMenu.h"
#import "AddCommentView.h"

@interface DetailView()
@property (nonatomic, strong) MainMenu *mainMenu;
@property (nonatomic, strong) AddCommentView *addCommentView;
@end

@implementation DetailView
@synthesize lblRating;
@synthesize lblComments;
@synthesize imageView;
@synthesize mainMenu = _mainMenu;
@synthesize addCommentView = _addCommentView;

- (AddCommentView *)addCommentView {
    if (!_addCommentView) {
        _addCommentView = [[AddCommentView alloc] init];
    }
    return _addCommentView;
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
        self.title = @"Просмотр картинки";
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
    [self.mainMenu addLoginButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.imageView setImageWithURL:kIMAGEURL];
}

- (void)viewDidUnload
{
    [self setImageView:nil];
    [self setLblRating:nil];
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
    self.lblRating.text = [NSString stringWithFormat:@"%d", [self.lblRating.text intValue] + 1];
}

- (IBAction)onCommentButtonClick:(id)sender {
    [self.navigationController pushViewController:self.addCommentView animated:YES];
}

- (IBAction)onFacebookButtonClick:(id)sender {
}

- (IBAction)onVKButtonClick:(id)sender {
}

#pragma mark - UITableViewDataSource
- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kCellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
    }    
    cell.textLabel.text = [NSString stringWithFormat:@"Коммент %d", indexPath.row];
    return cell;
}

@end
