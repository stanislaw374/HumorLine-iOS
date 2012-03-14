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
#import "Picture.h"
#import <QuartzCore/QuartzCore.h>

@interface MainView()
- (void)onButtonClick:(id)sender;
@property (nonatomic, strong) MainMenu *mainMenu;
@property (nonatomic, strong) DetailView *detailView;
@property (nonatomic, strong) NSArray *dataSource;
- (void)setButtonContent:(UIButton *)button picture:(Picture *)picture;
@end

@implementation MainView
@synthesize tableView = _tableView;
@synthesize mainMenu = _mainMenu;
@synthesize detailView = _detailView;
@synthesize dataSource = _dataSource;

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
    
    self.dataSource = [Picture all];
    
//    self.navigationController.toolbarHidden = NO;
//    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:nil];
//    self.navigationController.toolbarItems = [[NSArray alloc] initWithObjects:addItem, nil];
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
    return self.dataSource.count / 3 + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kCell;
    kCell = @"Cell";

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
   
    //CGSize winSize = [[UIScreen mainScreen] bounds].size;
    CGFloat rowHeight = [self tableView:tableView heightForRowAtIndexPath:indexPath];
    //NSLog(@"%@ : %f", NSStringFromSelector(_cmd), rowHeight);
    
    switch (indexPath.row) {
        case 0:
        {
            Picture *pic = [self.dataSource objectAtIndex:indexPath.row];
            int sx = 20, sy = 20;
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, rowHeight - sx, rowHeight - sy)];            
            button.center = CGPointMake(tableView.frame.size.width / 2, button.center.y);
            [button addTarget:self action:@selector(onButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:button];
            button.layer.borderWidth = 2;
            button.layer.borderColor = [[UIColor whiteColor] CGColor];
            button.contentMode = UIViewContentModeScaleAspectFill;
            button.tag = indexPath.row;
            [self setButtonContent:button picture:pic];
            break;
        }
        case 1:
        {
            Picture *pic1 = [self.dataSource objectAtIndex:indexPath.row];
            int sx = 25, sy = 10;
            int dx = 8;
            int buttonSize = (tableView.frame.size.width - 2 * sx - dx) / 2;
            UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake(sx, sy, buttonSize, buttonSize)];       
            [button1 addTarget:self action:@selector(onButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            button1.layer.borderWidth = 2;
            button1.layer.borderColor = [[UIColor whiteColor] CGColor];
            button1.contentMode = UIViewContentModeScaleAspectFit;
            button1.tag = indexPath.row;
            [self setButtonContent:button1 picture:pic1];
            
            Picture *pic2 = [self.dataSource objectAtIndex:indexPath.row + 1];
            UIButton *button2 = [[UIButton alloc] initWithFrame:CGRectMake(button1.frame.origin.x + button1.frame.size.width + dx, sy, buttonSize, buttonSize)];
            //[button2 setImageWithURL:pic2.url];
            [button2 addTarget:self action:@selector(onButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            button2.layer.borderWidth = 2;
            button2.layer.borderColor = [[UIColor whiteColor] CGColor];
            button2.contentMode = UIViewContentModeScaleAspectFit;
            button2.tag = indexPath.row + 1;
            [self setButtonContent:button2 picture:pic2];
            
            [cell addSubview:button1];
            [cell addSubview:button2];            
            break;
        }
        default:
        {
            int sx = 30, sy = 10;
            int dx = 8;
            int buttonSize = (tableView.frame.size.width - 2 * sx - 2 * dx) / 3;
            Picture *pic = [self.dataSource objectAtIndex:indexPath.row + 3];
            UIButton *button1 = (UIButton *)[cell viewWithTag:indexPath.row + 3];
            if (!button1) {
                button1 = [[UIButton alloc] initWithFrame:CGRectMake(sx, sy, buttonSize, buttonSize)];            
                [button1 addTarget:self action:@selector(onButtonClick:) forControlEvents:UIControlEventTouchUpInside];
                button1.layer.borderWidth = 2;
                button1.layer.borderColor = [[UIColor whiteColor] CGColor];
                button1.contentMode = UIViewContentModeScaleAspectFit;
                button1.tag = indexPath.row + 3;
            }
            else {
                [button1 setImage:nil forState:UIControlStateNormal];
                [button1 setTitle:@"" forState:UIControlStateNormal];
                UIView *view = [button1 viewWithTag:-1];
                [view removeFromSuperview];
            }
            [self setButtonContent:button1 picture:pic];
            
            pic = [self.dataSource objectAtIndex:indexPath.row + 4];
            UIButton *button2 = (UIButton *)[cell viewWithTag:indexPath.row + 4];
            if (!button2) {
                button2 = [[UIButton alloc] initWithFrame:CGRectMake(button1.frame.origin.x + button1.frame.size.width + dx, sy, buttonSize, buttonSize)];
                [button2 addTarget:self action:@selector(onButtonClick:) forControlEvents:UIControlEventTouchUpInside];
                button2.layer.borderWidth = 2;
                button2.layer.borderColor = [[UIColor whiteColor] CGColor];
                button2.contentMode = UIViewContentModeScaleAspectFit;
                button2.tag = indexPath.row + 4;
            }
            else {
                [button2 setImage:nil forState:UIControlStateNormal];
                [button2 setTitle:@"" forState:UIControlStateNormal];
                UIView *view = [button2 viewWithTag:-1];
                [view removeFromSuperview];
            }
            [self setButtonContent:button2 picture:pic];
            
            pic = [self.dataSource objectAtIndex:indexPath.row + 5];
            UIButton *button3 = (UIButton *)[cell viewWithTag:indexPath.row + 5];
            if (!button3) {
                button3 = [[UIButton alloc] initWithFrame:CGRectMake(button2.frame.origin.x + button2.frame.size.width, sy, buttonSize, buttonSize)];                
                [button3 addTarget:self action:@selector(onButtonClick:) forControlEvents:UIControlEventTouchUpInside];
                button3.layer.borderWidth = 2;
                button3.layer.borderColor = [[UIColor whiteColor] CGColor];
                button3.contentMode = UIViewContentModeScaleAspectFit;
                button3.tag = indexPath.row + 5;
            }
            else {
                [button3 setImage:nil forState:UIControlStateNormal];
                [button3 setTitle:@"" forState:UIControlStateNormal];
                UIView *view = [button3 viewWithTag:-1];
                [view removeFromSuperview];
            }
            [self setButtonContent:button3 picture:pic];
            
            [cell addSubview:button1];
            [cell addSubview:button2];  
            [cell addSubview:button3];        
        }
    }

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

- (void)onButtonClick:(id)sender {
    UIButton *button = (UIButton *)sender;
    Picture *currentPicture = [self.dataSource objectAtIndex:button.tag];
    self.detailView.currentPicture = currentPicture;
    [self.navigationController pushViewController:self.detailView animated:YES];
}

- (void)setButtonContent:(UIButton *)button picture:(Picture *)picture {
    switch (picture.type) {
        case Photo:
        {
//            UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
//            spinner.hidesWhenStopped = YES;
//            [spinner startAnimating];   
//            spinner.center = button.center;
//            spinner.tag = -1;
//            [button addSubview:spinner];
            [button setImageWithURL:picture.url success:^(UIImage *image) {
                //[spinner stopAnimating];
                //[spinner removeFromSuperview];
            } failure:nil];
            break;
        }
        case Text:
            [button setTitle:picture.text forState:UIControlStateNormal];
            break;
        case Video:
            break;
    }
}

@end
