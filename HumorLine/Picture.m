//
//  Picture.m
//  HumorLine
//
//  Created by Yazhenskikh Stanislaw on 13.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Picture.h"
#import <QuartzCore/QuartzCore.h>

static NSArray *_urls;

@implementation Picture
@synthesize viewsCount = _viewsCount;
@synthesize url = _url;
@synthesize text = _text;
@synthesize type = _type;

+ (NSArray *)urls {
    if (!_urls) {
        NSMutableArray *result = [[NSMutableArray alloc] init];
        [result addObject:[NSURL URLWithString:@"http://www.avazun.ru/storage1/images/demotivators/2010/11/01/12/46/O3goKEMYXI6n4Yscr3.jpg"]];
        [result addObject:[NSURL URLWithString:@"http://tabulorasa.info/uploads/posts/2010-06/1276401520_demotivator-139.jpg"]];
        [result addObject:[NSURL URLWithString:@"http://pics.livejournal.com/che_ratnik/pic/0004adqe"]];
        [result addObject:[NSURL URLWithString:@"http://rudemotivators.com/wp-content/uploads/2010/04/demotivator111.jpg"]];
        _urls = result;
    }
    return _urls;
}

+ (NSArray *)all {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 0; i < 100; i++) {
        Picture *pic = [[Picture alloc] init];
        pic.viewsCount = arc4random() % 1000;
        pic.type = arc4random() % 2;
        if (pic.type == Photo) {
            int photo = arc4random() % [Picture urls].count;
            pic.url = [[Picture urls] objectAtIndex:photo];
            //if (photo == 2) pic.viewsCount = 100500;
        }
        else if (pic.type == Text) {
            pic.text = @"Думал как лучше, а получилось как всегда";
        }
        [array addObject:pic];
    }
    return [array sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        Picture *pic1 = (Picture *)obj1;
        Picture *pic2 = (Picture *)obj2;
        if (pic1.viewsCount < pic2.viewsCount) return NSOrderedAscending;
        else if (pic1.viewsCount > pic2.viewsCount) return NSOrderedDescending;
        else return NSOrderedSame;
    }];
}

+ (UIImage *)renderView:(UIView *)view {
    UIGraphicsBeginImageContext(view.frame.size);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:ctx];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
