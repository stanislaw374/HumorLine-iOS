//
//  SCAppUtils.m
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 28.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SCAppUtils.h"
#import "UIImage+Thumbnail.h"

@implementation SCAppUtils

+ (void)customizeNavigationController:(UINavigationController *)navController
{
    UINavigationBar *navBar = [navController navigationBar];
    [navBar setTintColor:kSCNavBarColor];
    
    if ([navBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)])
    {
        UIImage *image = [[UIImage imageNamed:@"navigation_bar.png"] thumbnailByScalingProportionallyAndCroppingToSize:CGSizeMake(navBar.frame.size.width, navBar.frame.size.height)];
        [navBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    }
    else
    {
        UIImageView *imageView = (UIImageView *)[navBar viewWithTag:kSCNavBarImageTag];
        if (imageView == nil)
        {
            UIImage *image = [[UIImage imageNamed:@"navigation_bar.png"] thumbnailByScalingProportionallyAndCroppingToSize:CGSizeMake(navBar.frame.size.width, navBar.frame.size.height)];
            imageView = [[UIImageView alloc] initWithImage:image];
            [imageView setTag:kSCNavBarImageTag];
            [navBar insertSubview:imageView atIndex:0];
        }
    }
}

@end
