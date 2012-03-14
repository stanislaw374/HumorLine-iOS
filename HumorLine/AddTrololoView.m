//
//  AddTrololoView.m
//  HumorLine
//
//  Created by Yazhenskikh Stanislaw on 13.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AddTrololoView.h"
#import "MainMenu.h"
#import "TrololoView.h"

@interface AddTrololoView()
@property (nonatomic, strong) MainMenu *mainMenu;
@property (nonatomic, strong) TrololoView *trololoView;
@end

@implementation AddTrololoView
@synthesize mainMenu = _mainMenu;
@synthesize trololoView = _trololoView;

#pragma mark - Lazy Instantiation

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
        self.title = @"Trololo";
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

- (IBAction)onButtonClick:(id)sender {
    self.trololoView = [[TrololoView alloc] init];
    self.trololoView.imagesCount = ((UIButton *)sender).tag;
    [self.navigationController pushViewController:self.trololoView animated:YES];    
}

- (IBAction)onCancelButtonClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
