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
#import "KeyboardListener.h"
#import "MBProgressHUD.h"

@interface AddVideoView()
@property (nonatomic, strong) MPMoviePlayerController *player;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) UIAlertView *saveAlertView;
- (void)saveVideo;
- (void)saveVideoToPhotosAlbum;
- (void)saveVideoToFeed;
- (void)video: (NSString *) videoPath
    didFinishSavingWithError: (NSError *) error
                 contextInfo: (void *) contextInfo;
@end

@implementation AddVideoView
@synthesize lblTitle;
@synthesize swAddLocation;
@synthesize txtTitle;
@synthesize videoURL = _videoURL;
@synthesize videoView;
@synthesize player = _player;
@synthesize locationManager = _locationManager;
@synthesize saveAlertView = _saveAlertView;

#pragma mark - Lazy Instantiation
- (UIAlertView *)saveAlertView {
    if (!_saveAlertView) {
        _saveAlertView = [[UIAlertView alloc] initWithTitle:@"Сохранить видео" message:nil delegate:self cancelButtonTitle:@"Отмена" otherButtonTitles:@"В фотоальбоме", @"В ленте", nil];
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
    
    //self.title = @"Добавить видео";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(saveVideo)];    
    ((UIScrollView *)self.view).contentSize = self.view.frame.size;
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

- (IBAction)onLocationSwitchValueChange:(id)sender {
    UISwitch *sw = (UISwitch *)sender;
    if (sw.on) {
        if ([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText = @"Определение местонахождения";
            [self.locationManager startUpdatingLocation];
        }
        else [sw setOn:NO];
    }
}

- (IBAction)onTextFieldDidEndOnExit:(id)sender {
    [sender resignFirstResponder];
}

#pragma mark - Video saving
- (void)saveVideo {
    [self.saveAlertView show];
}

- (void)saveVideoToPhotosAlbum {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSLog(@"%@ : %@", NSStringFromSelector(_cmd), self.videoURL.path);
    UISaveVideoAtPathToSavedPhotosAlbum(self.videoURL.path, self, @selector(video:didFinishSavingWithError:contextInfo:), NULL);
}

- (void)saveVideoToFeed {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    Post *p = [[Post alloc] init];
    p.type = @"video";
    p.title = self.txtTitle.text;
    if (self.swAddLocation.on) {
        p.coordinate = self.locationManager.location.coordinate;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        p.videoData = [NSData dataWithContentsOfURL:self.videoURL];        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [Post addPost:p withDelegate:self];        
        });
    });    
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:error.localizedDescription message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Видео успешно сохранено в фотоальбоме" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark - PostDelegate
- (void)postDidFailWithError:(NSError *)error {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:error.localizedDescription message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)postDidAdd {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Видео успешно добавлено в ленту" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
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

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    self.lblTitle.text = self.txtTitle.text;
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [KeyboardListener setScrollView:(UIScrollView *)self.view];
    [KeyboardListener setActiveView:textField];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [KeyboardListener unsetScrollView];
    [KeyboardListener unsetActiveView];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView isEqual:self.saveAlertView]) {
        switch (buttonIndex) {
            case 1: [self saveVideoToPhotosAlbum]; break;
            case 2: [self saveVideoToFeed]; break;                
        }
    }
}

@end
