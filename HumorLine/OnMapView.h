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
@end
