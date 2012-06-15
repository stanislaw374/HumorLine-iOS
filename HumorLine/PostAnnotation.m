//
//  PostAnnotation.m
//  HumorLine
//
//  Created by Yazhenskikh Stanislaw on 20.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PostAnnotation.h"

@implementation PostAnnotation
@synthesize post = _post;

+ (PostAnnotation *)annotationWithPost:(Post *)post {
    PostAnnotation *annotation = [[PostAnnotation alloc] init];
    annotation.post = post;
    return annotation;
}

- (NSString *)title {
    return [self.post.type isEqualToString:@"image"] ? @"Изображение" : @"Видео";
}

- (NSString *)subtitle {
    return @"";
}

- (CLLocationCoordinate2D)coordinate {
    return self.post.coordinate;
}

@end
