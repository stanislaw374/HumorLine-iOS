//
//  OnMapView.m
//  HumorLine
//
//  Created by Yazhenskikh Stanislaw on 20.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OnMapView.h"
//#import "MainMenu.h"
#import "AppDelegate.h"
#import "Post.h"
#import "PostAnnotation.h"
#import "PostsView.h"
#import "MainView.h"

@interface OnMapView()
//@property (nonatomic, strong) MainMenu *mainMenu;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) PostsView *postsView;
- (void)addAnnotations;
- (void)showPosts;
@end

@implementation OnMapView
@synthesize mapView;
//@synthesize mainMenu = _mainMenu;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize postsView = _postsView;

- (PostsView *)postsView {
    if (!_postsView) {
        _postsView = [[PostsView alloc] init];
    }
    return _postsView;
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (!_fetchedResultsController) {
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Post"];
        
        NSSortDescriptor *desc = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
        [fetchRequest setSortDescriptors:[[NSArray alloc] initWithObjects:desc, nil]];
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:appDelegate.managedObjectContext sectionNameKeyPath:nil cacheName:@"Map"];
    }
    return _fetchedResultsController;
}

- (void)addAnnotations {
    int i = 0;
    for (Post *post in self.fetchedResultsController.fetchedObjects) {        
        if (post.lat && post.lng) {
            PostAnnotation *annotation = [[PostAnnotation alloc] init];
            
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Post"];            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(lat == $lat) AND (lng == $lng)"];
            predicate = [predicate predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:post.lat], @"lat", [NSNumber numberWithDouble:post.lng], @"lng", nil]];
            
            [request setPredicate:predicate];
            
            NSError *error;
            int count = [appDelegate.managedObjectContext countForFetchRequest:request error:&error];
            
            annotation.title = [NSString stringWithFormat:@"Количество постов: %d", count];       
            //annotation.title = @"Title";
            annotation.coordinate = CLLocationCoordinate2DMake(post.lat, post.lng);
            annotation.post = post;
            annotation.index = i++;
            [self.mapView addAnnotation:annotation];
        }
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //self.title = @"На карте";
        //self.tabBarItem.image = [UIImage imageNamed:@"icon_map.png"];
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
    
    NSError *error;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Error fetching : %@", error.localizedDescription);
    }
    else {
        [self addAnnotations];
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
    static NSString *kReuseIdentifier = @"Annotation";
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


//    NSError *error;
//    int count = [appDelegate.managedObjectContext countForFetchRequest:request error:&error];
//    self.postsView.fetchedResultsController = self.fetchedResultsController;
//    self.postsView.currentPage = ((PostAnnotation *)view.annotation).index;
//    [self.navigationController pushViewController:self.postsView animated:YES];
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    PostAnnotation *annotation = view.annotation;
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Post"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(lat == $lat) AND (lng == $lng)"];
    predicate = [predicate predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:annotation.coordinate.latitude], @"lat", [NSNumber numberWithDouble:annotation.coordinate.longitude], @"lng", nil]];
    [request setPredicate:predicate];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:appDelegate.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    NSError *error;
    [fetchedResultsController performFetch:&error];
    
    NSLog(@"Fetched %d objects", fetchedResultsController.fetchedObjects.count);
    
    PostsView *postsView = [[PostsView alloc] init];
    postsView.fetchedResultsController = fetchedResultsController;
    postsView.currentPage = 0;
    [self.navigationController pushViewController:postsView animated:YES];
}

- (void)showPosts {
    
}

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

- (IBAction)onSigninButtonClick:(id)sender {
    MainView *mainView = (MainView *)[self.navigationController.viewControllers objectAtIndex:0];
    [self.navigationController popViewControllerAnimated:NO];
    [mainView onLoginButtonClick:nil];
}

@end
