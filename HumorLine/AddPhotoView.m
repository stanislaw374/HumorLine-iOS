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
#import "AppDelegate.h"
#import "KeyboardListener.h"
#import "MBProgressHUD.h"

@interface AddPhotoView()
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) UIAlertView *saveAlertView;
- (void)savePhoto;
- (void)savePhotoToCameraRoll;
- (void)savePhotoToFeed;
- (void)image: (UIImage *) image
didFinishSavingWithError: (NSError *) error
                 contextInfo: (void *) contextInfo;
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
@synthesize saveAlertView = _saveAlertView;

#pragma mark - Lazy Instantiation
- (UIAlertView *)saveAlertView {
    if (!_saveAlertView) {
        _saveAlertView = [[UIAlertView alloc] initWithTitle:@"Сохранить" message:@"" delegate:self cancelButtonTitle:@"Отмена" otherButtonTitles:@"В фотогалерее", @"В ленте", nil];
    }
    return _saveAlertView;
}

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
        //self.title = @"Добавить фото";
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
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(savePhoto)];
    
    self.imageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.imageView.layer.borderWidth = 1;
    
    UIScrollView *scrollView_ = (UIScrollView *)self.view;
    scrollView_.contentSize = self.view.frame.size;
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

- (IBAction)onBgClick:(id)sender {
    [self.txtHeader becomeFirstResponder];
    [self.txtHeader resignFirstResponder];
}

- (IBAction)onSwAddLocationValueChanged:(id)sender {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    UISwitch *switch_ = (UISwitch *)sender;
    if (switch_.on) {
        if ([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText = @"Определение местонахождения";
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

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (![self.view isKindOfClass:[UIScrollView class]]) {
        NSLog(@"self.view is not UIScrollView O_O");
    }
    
    [KeyboardListener setScrollView:(UIScrollView *)self.view];
    [KeyboardListener setActiveView:textField];    
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [KeyboardListener unsetScrollView];
    [KeyboardListener unsetActiveView];
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    [self.locationManager stopUpdatingLocation];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self.locationManager stopUpdatingLocation];
    [self.swAddLocation setOn:NO];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

#pragma mark - UIAlertViewDelegate 
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView isEqual:self.saveAlertView]) {
        switch (buttonIndex) {
            case 1: [self savePhotoToCameraRoll]; break;
            case 2: [self savePhotoToFeed]; break;
        }
    }
}

#pragma mark - Photo saving
- (void)savePhoto {
    [self.saveAlertView show];
}

- (void)savePhotoToCameraRoll {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    UIImage *image = [self renderView:self.scrollView];
    
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:error.localizedDescription message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Фото успешно сохранено в фотогалерее" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

- (void)savePhotoToFeed {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    UIImage *image = [self renderView:self.scrollView];
    
    Post *post = [[Post alloc] init];
    post.type = @"image";
    if (self.swAddLocation.on) {
        //post.lat = [NSNumber numberWithDouble:self.locationManager.location.coordinate.latitude];
        //post.lng = [NSNumber numberWithDouble:self.locationManager.location.coordinate.longitude];
        post.coordinate = self.locationManager.location.coordinate;
    }
    post.imageData = UIImagePNGRepresentation(image);
    
    [Post addPost:post withDelegate:self];
}

#pragma mark - PostDelegate
- (void)postDidAdd {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Фото успешно добавлено в ленту" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)postDidFailWithError:(NSError *)error {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:error.localizedDescription message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

@end
