//
//  AddPhotoView.m
//  HumorLine
//
//  Created by Yazhenskikh Stanislaw on 12.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AddPhotoView.h"

@implementation AddPhotoView
@synthesize imageView;
@synthesize lblHeader;
@synthesize lblSubheader;
@synthesize txtHeader;
@synthesize txtSubheader;
@synthesize swAddLocation;
@synthesize delegate = _delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Добавить фото";
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

- (void)viewDidUnload
{
    [self setImageView:nil];
    [self setLblHeader:nil];
    [self setLblSubheader:nil];
    [self setTxtHeader:nil];
    [self setTxtSubheader:nil];
    [self setSwAddLocation:nil];
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
    [self.delegate addPhotoViewDidFinish];
}

- (IBAction)onCancelButtonClick:(id)sender {
    [self.delegate addPhotoViewDidFinish];
}

@end
