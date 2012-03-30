//
//  OnMapView.h
//  HumorLine
//
//  Created by Yazhenskikh Stanislaw on 20.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface OnMapView : UIViewController <MKMapViewDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet MKMapView *mapView;

- (IBAction)onTop30ButtonClick:(id)sender;
- (IBAction)onAddButtonClick:(id)sender;
- (IBAction)onNewButtonClick:(id)sender;
- (IBAction)onSigninButtonClick:(id)sender;

@end
