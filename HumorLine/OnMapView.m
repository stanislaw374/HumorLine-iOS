//
//  OnMapView.m
//  HumorLine
//
//  Created by Yazhenskikh Stanislaw on 20.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OnMapView.h"
#import "AppDelegate.h"
#import "PostAnnotation.h"
#import "PostsView.h"
#import "MainView.h"
#import <CoreLocation/CoreLocation.h>
#import "MBProgressHUD.h"

@interface OnMapView()
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSArray *annotations;
//@property (nonatomic, strong) NSArray *posts;
- (void)loadObjects;
- (void)updateMap;
@end

@implementation OnMapView
@synthesize mapView;
@synthesize locationManager = _locationManager;
@synthesize annotations = _annotations;
//@synthesize posts = _posts;

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.delegate = self;
    }
    return _locationManager;
}

- (NSArray *)annotations {
    if (!_annotations) {
        _annotations = [[NSArray alloc] init];
    }
    return _annotations;
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    [manager stopUpdatingLocation];
    
    [self loadObjects];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [manager stopUpdatingLocation];
    
    [self loadObjects];
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
    
    self.navigationItem.hidesBackButton = YES;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    if ([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
        [self.locationManager startUpdatingLocation];
    }
    else {
        [self loadObjects];
    }
}

- (void)viewDidUnload
{
    [self setMapView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - MKMapViewDelegate
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    self.mapView.centerCoordinate = userLocation.coordinate;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView_ viewForAnnotation:(id<MKAnnotation>)annotation {
    static NSString *kReuseIdentifier = @"AnnotationView";
    MKAnnotationView *view = [mapView_ dequeueReusableAnnotationViewWithIdentifier:kReuseIdentifier];
    if (!view) {
        view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kReuseIdentifier];
        view.canShowCallout = YES;
        view.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    }
    else {
        view.annotation = annotation;
    }
    return view;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    Post *post = ((PostAnnotation *)view.annotation).post;
    if ([post.type isEqualToString:@"image"] || [post.type isEqualToString:@"video"]) {
        if ([post hasPreviewImage]) {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
            imageView.image = [post previewImage];
            view.leftCalloutAccessoryView = imageView;            
        }
        else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                UIImage *image = [post previewImage];
                dispatch_async(dispatch_get_main_queue(), ^{ 
                    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
                    imageView.image = image;
                    view.leftCalloutAccessoryView = imageView;
                });
            });
        }
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    PostAnnotation *annotation = view.annotation;
    Post *post = (Post *)annotation.post;
     
    PostsView *postsView = [[PostsView alloc] init];
    postsView.posts = [NSArray arrayWithObject:post];
    postsView.currentPost = post;
    [self.navigationController pushViewController:postsView animated:YES];
}
#pragma mark -

- (IBAction)onTop30ButtonClick:(id)sender {
    MainView *mainView = (MainView *)[self.navigationController.viewControllers objectAtIndex:0];
    [self.navigationController popViewControllerAnimated:NO];
    
    [mainView onTop30ButtonClick:nil];
}

- (IBAction)onAddButtonClick:(id)sender {
    MainView *mainView = (MainView *)[self.navigationController.viewControllers objectAtIndex:0];
    [self.navigationController popViewControllerAnimated:NO];

    [mainView onAddButtonClick:nil];
}

- (IBAction)onNewButtonClick:(id)sender {
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - Data loading
- (void)loadObjects {
    [Post getNearestByCoordinate:self.locationManager.location.coordinate withDelegate:self];
}

- (void)updateMap {
    if (self.mapView.annotations) {
        [self.mapView removeAnnotations:self.mapView.annotations];
    }
    [self.mapView addAnnotations:self.annotations];
    
    NSLog(@"Added %d annotations", self.annotations.count);
}

#pragma mark - PostDelegate
- (void)postsDidLoad:(NSArray *)posts {    
    NSMutableArray *annotations = [NSMutableArray array];
    for (Post *post in posts) {
        if (CLLocationCoordinate2DIsValid(post.coordinate)) {
            PostAnnotation *annotation = [PostAnnotation annotationWithPost:post];
            [annotations addObject:annotation];
        }
    }
    self.annotations = annotations;
    [self updateMap];
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)postsDidFailWithError:(NSError *)error {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

@end
