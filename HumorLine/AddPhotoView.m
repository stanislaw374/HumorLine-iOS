//
//  AddPhotoView.m
//  HumorLine
//
//  Created by Yazhenskikh Stanislaw on 12.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AddPhotoView.h"
#include <QuartzCore/QuartzCore.h>

@implementation AddPhotoView
@synthesize imageView;
@synthesize lblHeader;
@synthesize lblSubheader;
@synthesize txtHeader;
@synthesize txtSubheader;
@synthesize swAddLocation;
@synthesize image = _image;
@synthesize scrollView;

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
    self.imageView.image = self.image;
}

- (void)viewDidUnload
{
    [self setImageView:nil];
    [self setLblHeader:nil];
    [self setLblSubheader:nil];
    [self setTxtHeader:nil];
    [self setTxtSubheader:nil];
    [self setSwAddLocation:nil];
    [self setScrollView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (UIImage *)renderView:(UIView *)view {
    UIGraphicsBeginImageContext(view.bounds.size);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:ctx];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (IBAction)onAddButtonClick:(id)sender {
    UIImage *image = [self renderView:self.scrollView];
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Фото добавлено в фотогаллерею" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    [self.presentingViewController dismissModalViewControllerAnimated:YES];
}

- (IBAction)onCancelButtonClick:(id)sender {
    [self.presentingViewController dismissModalViewControllerAnimated:YES];
}

- (IBAction)onBgClick:(id)sender {
    [self.txtHeader becomeFirstResponder];
    [self.txtHeader resignFirstResponder];
}

- (IBAction)onSwAddLocationValueChanged:(id)sender {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([textField isEqual:self.txtHeader]) {
        self.lblHeader.text = textField.text;
    }
    else if ([textField isEqual:self.txtSubheader]) {
        self.lblSubheader.text = textField.text;
    }
    return YES;
}

@end
