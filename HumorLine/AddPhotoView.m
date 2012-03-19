//
//  AddPhotoView.m
//  HumorLine
//
//  Created by Yazhenskikh Stanislaw on 12.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AddPhotoView.h"
#import <QuartzCore/QuartzCore.h>
#import "Post.h"
#import "Image.h"
#import "AppDelegate.h"
#import "Constants.h"

@interface AddPhotoView()
@property (nonatomic, strong) CLLocationManager *locationManager;
@end

@implementation AddPhotoView
@synthesize imageView;
@synthesize lblHeader;
@synthesize lblSubheader;
@synthesize txtHeader;
@synthesize txtSubheader;
@synthesize swAddLocation;
@synthesize image = _image;
@synthesize scrollView;
@synthesize locationManager = _locationManager;

#pragma mark - Lazy Instantiation
- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.delegate = self;
    }
    return _locationManager;
}

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
    
    self.scrollView.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.scrollView.layer.borderWidth = 1;
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
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    Post *post = (Post *)[NSEntityDescription insertNewObjectForEntityForName:@"Post" inManagedObjectContext:appDelegate.managedObjectContext];
    post.type = kPostTypePhoto;
    post.image = (Image *)[NSEntityDescription insertNewObjectForEntityForName:@"Image" inManagedObjectContext:appDelegate.managedObjectContext];
    post.image.image = image;
    
    if (self.swAddLocation.on) {
        post.lat = self.locationManager.location.coordinate.latitude;
        post.lng = self.locationManager.location.coordinate.longitude;
    }
    
    NSError *error;    
    if (![appDelegate.managedObjectContext save:&error]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Ошибка добавления фото" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
        [alert show];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Фото успешно добавлено" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [self.presentingViewController dismissModalViewControllerAnimated:YES];
    }
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
    
    UISwitch *switch_ = (UISwitch *)sender;
    if (switch_.on) {
        if ([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
            [self.locationManager startUpdatingLocation];
        }
        else {
            [switch_ setOn:NO];
        }
    }
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

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    [self.locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self.locationManager stopUpdatingLocation];
    [self.swAddLocation setOn:NO];
}

@end
