//
//  PostAnnotation.h
//  HumorLine
//
//  Created by Yazhenskikh Stanislaw on 20.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Post.h"

@interface PostAnnotation : NSObject <MKAnnotation>
@property (nonatomic, strong) Post *post;

+ (PostAnnotation *)annotationWithPost:(Post *)post;
@end
