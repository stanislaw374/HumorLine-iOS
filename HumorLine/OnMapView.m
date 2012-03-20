//
//  OnMapView.m
//  HumorLine
//
//  Created by Yazhenskikh Stanislaw on 20.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OnMapView.h"
#import "MainMenu.h"
#import "AppDelegate.h"
#import "Post.h"
#import "PostAnnotation.h"
#import "PostsView.h"

@interface OnMapView()
@property (nonatomic, strong) MainMenu *mainMenu;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) PostsView *postsView;
- (void)addAnnotations;
@end

@implementation OnMapView
@synthesize mapView;
@synthesize mainMenu = _mainMenu;
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
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Post"];
        
        NSSortDescriptor *desc = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
        [fetchRequest setSortDescriptors:[[NSArray alloc] initWithObjects:desc, nil]];
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:appDelegate.managedObjectContext sectionNameKeyPath:nil cacheName:@"Map"];
    }
    return _fetchedResultsController;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"На карте";
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
    
    self.mapView.showsUserLocation = YES;
    
    self.mainMenu = [[MainMenu alloc] initWithViewController:self];
    [self.mainMenu addLoginButton];
    
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

- (void)addAnnotations {
    int i = 0;
    for (Post *post in self.fetchedResultsController.fetchedObjects) {        
        if (post.lat && post.lng) {
            PostAnnotation *annotation = [[PostAnnotation alloc] init];
            annotation.coordinate = CLLocationCoordinate2DMake(post.lat, post.lng);
            annotation.post = post;
            annotation.index = i++;
            [self.mapView addAnnotation:annotation];
        }
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    self.postsView.fetchedResultsController = self.fetchedResultsController;
    self.postsView.currentPage = ((PostAnnotation *)view.annotation).index;
    [self.navigationController pushViewController:self.postsView animated:YES];
}

@end
