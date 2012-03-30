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
    [navBar setTintColor:kSCNavBarColor];
    
    //NSLog(@"Nav bar height = %f", navBar.frame.size.height);
    
//    CGRect contextRect = CGRectMake(0, 0, 320, 44);
//    CGSize contextSize = contextRect.size;
//    
//    UIGraphicsBeginImageContext(contextSize);
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
//    CGContextClearRect(context, contextRect);
//    [[UIImage imageNamed:@"top_bar.png"] drawInRect:CGRectMake(0, 0, contextSize.width, contextSize.height)];
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();           
//    UIGraphicsEndImageContext();

    UIImage *image = [UIImage imageNamed:@"top_bar.png"];
    
    if ([navBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)])
    {              
        [navBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];            
    }
    else
    {
        UIImageView *imageView = (UIImageView *)[navBar viewWithTag:kSCNavBarImageTag];
        if (imageView == nil)
        {
            imageView = [[UIImageView alloc] initWithImage:image];
            [imageView setTag:kSCNavBarImageTag];
            [navBar insertSubview:imageView atIndex:0];
        }
    }
}

@end
