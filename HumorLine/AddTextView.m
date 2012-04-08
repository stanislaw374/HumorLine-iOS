//
//  AddTextView.m
//  HumorLine
//
//  Created by Yazhenskikh Stanislaw on 20.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AddTextView.h"
#import "AppDelegate.h"
#import "Post.h"
#import "KeyboardListener.h"

@interface AddTextView()
@property (nonatomic, strong) CLLocationManager *locationManager;
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
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Добавить" style:UIBarButtonItemStyleBordered target:self action:@selector(onAddButtonClick:)];
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
            [self.locationManager startUpdatingLocation];
        }
        else {
            [sw setOn:NO];
        }
    }
}

- (IBAction)onAddButtonClick:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
//    Post *newPost = [NSEntityDescription insertNewObjectForEntityForName:@"Post" inManagedObjectContext:appDelegate.managedObjectContext];
//    newPost.type = kPostTypeText;
//    newPost.text = self.txtText.text;
//    newPost.date = [NSDate date];
//    
//    if (swAddLocation.on) {
//        newPost.lat = self.locationManager.location.coordinate.latitude;
//        newPost.lng = self.locationManager.location.coordinate.longitude;
//    }
//    
//    NSError *error;
//    if ([appDelegate.managedObjectContext save:&error]) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Текст успешно добавлен" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
//        [alert show];
//        //[self.navigationController popViewControllerAnimated:YES];
//        [self.navigationController popToRootViewControllerAnimated:YES];
//    }
//    else {
//        NSLog(@"Error saving to CoreData: %@", error.localizedDescription);
//    }
}

- (IBAction)onCancelButtonClick:(id)sender {
    //[self.presentingViewController dismissModalViewControllerAnimated:YES];
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    [self.locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self.locationManager stopUpdatingLocation];
    [self.swAddLocation setOn:NO];
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

@end
