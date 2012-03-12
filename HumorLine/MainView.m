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

@interface MainView()
- (void)onImageClick;
@property (nonatomic, strong) MainMenu *mainMenu;
@property (nonatomic, strong) DetailView *detailView;
@end

@implementation MainView
@synthesize mainMenu = _mainMenu;
@synthesize detailView = _detailView;

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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"Button index = %d", buttonIndex);
}

#pragma mark - UITableViewDataSource
- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kCell;
    kCell = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCell];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"Cell_iPhone" owner:self options:nil] objectAtIndex:0];
    }

    NSMutableArray *buttons = [[NSMutableArray alloc] init];
    const int cnt = 3;
    for (int i = 1; i <= cnt; i++) {
        UIButton *button = (UIButton *)[cell viewWithTag:i];
        [buttons addObject:button];
        [button addTarget:self action:@selector(onImageClick) forControlEvents:UIControlEventTouchUpInside];
    }
    for (UIButton *button in buttons) {
        //MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:button];
        //[hud show:YES];
        //__unsafe_unretained UIButton *weakButton = button;
        [button setImageWithURL:kIMAGEURL success:^(UIImage *image) {
            //NSLog(@"%@", NSStringFromSelector(_cmd));
            //MBProgressHUD *hud = (MBProgressHUD *)[weakImageView viewWithTag:4];
            //[hud hide:YES];            
        } failure:nil];
    }

    return cell;
}

- (void)onImageClick {
    [self.navigationController pushViewController:self.detailView animated:YES];
}

@end
