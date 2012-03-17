//
//  Picture.h
//  HumorLine
//
//  Created by Yazhenskikh Stanislaw on 13.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum { Photo, Text, Video } PostTypeL;

@interface Picture : NSObject
@property (nonatomic) int viewsCount;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSString *text;
@property (nonatomic) PostTypeL type;

+ (NSArray *)all;
+ (UIImage *)renderView:(UIView *)view;

@end
