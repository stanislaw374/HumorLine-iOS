//
//  AddVideoView.m
//  HumorLine
//
//  Created by Yazhenskikh Stanislaw on 16.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AddVideoView.h"
#import "MainMenu.h"
#import <MediaPlayer/MediaPlayer.h>
#import "AppDelegate.h"
#import "Post.h"
#import "Constants.h"

@interface AddVideoView()
@property (nonatomic, strong) MainMenu *mainMenu;
@property (nonatomic, strong) MPMoviePlayerController *player;
@property (nonatomic, strong) CLLocationManager *locationManager;
- (BOOL)saveVideo;
@end

@implementation AddVideoView
//@synthesize scrollView;
@synthesize lblTitle;
@synthesize swAddLocation;
@synthesize txtTitle;
@synthesize videoURL = _videoURL;
@synthesize videoView;
@synthesize mainMenu = _mainMenu;
@synthesize player = _player;
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
#pragma mark -

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
    
    self.title = @"Добавить видео";
    
    self.mainMenu = [[MainMenu alloc] initWithViewController:self];
    [self.mainMenu addLoginButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.player = [[MPMoviePlayerController alloc] initWithContentURL:self.videoURL];
    self.player.view.frame = self.videoView.bounds;
    self.player.scalingMode = MPMovieScalingModeAspectFit;
    [self.videoView addSubview:self.player.view];
    [self.player play];
}

- (void)viewDidUnload
{
    //[self setScrollView:nil];
    [self setLblTitle:nil];
    [self setSwAddLocation:nil];
    [self setTxtTitle:nil];
    [self setVideoView:nil];
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
    if ([self saveVideo]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)onCancelButtonClick:(id)sender {
    [self.presentingViewController dismissModalViewControllerAnimated:YES];
}

- (IBAction)onLocationSwitchValueChange:(id)sender {
    UISwitch *sw = (UISwitch *)sender;
    if (sw.on) {
        if ([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
            [self.locationManager startUpdatingLocation];
        }
        else [sw setOn:NO];
    }
}

- (IBAction)onTextFieldDidEndOnExit:(id)sender {
    [sender resignFirstResponder];
}

- (BOOL)saveVideo {
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    
    Post *newPost = (Post *)[NSEntityDescription insertNewObjectForEntityForName:@"Post" inManagedObjectContext:appDelegate.managedObjectContext];
    newPost.type = kPostTypeVideo;
    newPost.title = self.lblTitle.text;
    
    if (self.swAddLocation.on) {
        newPost.lat = self.locationManager.location.coordinate.latitude;
        newPost.lng = self.locationManager.location.coordinate.longitude;
    }
    
    NSString *videosPath = [[appDelegate applicationDocumentsDirectory] stringByAppendingPathComponent:VIDEOS_PATH];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:videosPath]) {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:videosPath withIntermediateDirectories:NO attributes:nil error:&error];
    }
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"yyyy-MM-dd_HH_mm_ss";
    NSString *videoName = [[df stringFromDate:[NSDate date]] stringByAppendingPathExtension:@"MOV"];
    NSString *videoPath = [videosPath stringByAppendingPathComponent:videoName];
    NSURL *videoURL = [NSURL fileURLWithPath:videoPath];   
    
    newPost.videoURL = videoURL.absoluteString;
    
    NSError *error;
    if (![appDelegate.managedObjectContext save:&error]) {
        NSLog(@"Error saving! : %@", error.localizedDescription);
    }
    else {
        [[NSFileManager defaultManager] copyItemAtURL:self.videoURL toURL:videoURL error:&error];
        if (error) {
            NSLog(@"Ошибка копирования : %@", error.localizedDescription);
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Видео успешно добавлено" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            return YES;
        }
    }    
    return NO;
}

#pragma mark - CLLocationManagerDelegate 
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    [self.locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self.locationManager stopUpdatingLocation];
    [self.swAddLocation setOn:NO];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    self.lblTitle.text = self.txtTitle.text;
    return YES;
}

@end
