//
//  AddVideoView.m
//  HumorLine
//
//  Created by Yazhenskikh Stanislaw on 16.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AddVideoView.h"
#import <AVFoundation/AVFoundation.h>

@interface AddVideoView()
//@property (nonatomic
@end

@implementation AddVideoView
@synthesize scrollView;
@synthesize lblTitle;
@synthesize swAddLocation;
@synthesize txtTitle;
@synthesize videoURL = _videoURL;

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
    
    AVPlayer *player = [[AVPlayer alloc] initWithURL:self.videoURL];
    
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [self setLblTitle:nil];
    [self setSwAddLocation:nil];
    [self setTxtTitle:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)onAddButtonClick:(id)sender {
}

- (IBAction)onCancelButtonClick:(id)sender {
}
@end
