//
//  SCAppUtils.m
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 28.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SCAppUtils.h"
//#import "UIImage+Thumbnail.h"

@implementation SCAppUtils

+ (void)customizeNavigationController:(UINavigationController *)navController
{
    UINavigationBar *navBar = [navController navigationBar];
    //navBar.barStyle = UIBarStyleBlackTranslucent;
    //[navBar setTintColor:kSCNavBarColor];
    
    NSLog(@"Nav bar height = %f", navBar.frame.size.height);
    
    CGRect contextRect = CGRectMake(0, 0, 320, 44);
    CGSize contextSize = contextRect.size;
    
    UIGraphicsBeginImageContext(contextSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextClearRect(context, contextRect);
    [[UIImage imageNamed:@"navigation_bar.png"] drawInRect:CGRectMake(0, 0, contextSize.width, contextSize.height)];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();           
    UIGraphicsEndImageContext();
    
    if ([navBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)])
    {              
        //UIImage *image = [[UIImage imageNamed:@"navigation_bar.png"] thumbnailByScalingProportionallyAndCroppingToSize:CGSizeMake(navBar.frame.size.width, navBar.frame.size.height)];
        //[navBar setBackgroundColor:[UIColor blackColor]];
        [navBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];            
    }
    else
    {
        UIImageView *imageView = (UIImageView *)[navBar viewWithTag:kSCNavBarImageTag];
        if (imageView == nil)
        {
            //UIImage *image = [[UIImage imageNamed:@"navigation_bar.png"] thumbnailByScalingProportionallyAndCroppingToSize:CGSizeMake(navBar.frame.size.width, navBar.frame.size.height)];
            imageView = [[UIImageView alloc] initWithImage:image];
            //imageView.backgroundColor = [UIColor clearColor];
            [imageView setTag:kSCNavBarImageTag];
            [navBar insertSubview:imageView atIndex:0];
        }
    }
}

@end
