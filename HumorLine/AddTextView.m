//
//  AddTextView.m
//  HumorLine
//
//  Created by Yazhenskikh Stanislaw on 20.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AddTextView.h"
#import "AppDelegate.h"
#import "KeyboardListener.h"
#import "MBProgressHUD.h"

@interface AddTextView()
@property (nonatomic, strong) CLLocationManager *locationManager;
- (void)save;
@end

@implementation AddTextView
@synthesize txtText;
@synthesize swAddLocation;
@synthesize locationManager = _locationManager;

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
    ((UIScrollView *)self.view).contentSize = self.view.frame.size;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Добавить" style:UIBarButtonItemStyleBordered target:self action:@selector(save)];
}

- (void)viewDidUnload
{
    [self setTxtText:nil];
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

- (IBAction)onSwAddLocationValueChanged:(id)sender {
    UISwitch *sw = (UISwitch *)sender;
    if (sw.on) {
        if ([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText = @"Определение местонахождения";
            [self.locationManager startUpdatingLocation];
        }
        else {
            [sw setOn:NO];
        }
    }
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

#pragma mark - UITextViewDelegate 
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [KeyboardListener setScrollView:(UIScrollView *)self.view];
    [KeyboardListener setActiveView:textView];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [KeyboardListener unsetScrollView];
    [KeyboardListener unsetActiveView];
}

- (void)save {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    Post *p = [[Post alloc] init];
    p.type = @"text";
    p.text = self.txtText.text;
    if (self.swAddLocation.on) {
        p.coordinate = self.locationManager.location.coordinate;
    }
    
    [Post addPost:p withDelegate:self];
}

#pragma mark - PostDelegate
- (void)postDidAdd {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Текст успешно добавлен в ленту" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)postDidFailWithError:(NSError *)error {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:error.localizedDescription message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

@end
