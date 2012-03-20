//
//  main.m
//  HumorLine
//
//  Created by Yazhenskikh Stanislaw on 11.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"
#import "SCClassUtils.h"

int main(int argc, char *argv[])
{
    @autoreleasepool {
        
        // Начало магии
        [SCClassUtils swizzleSelector:@selector(insertSubview:atIndex:)
                              ofClass:[UINavigationBar class]
                         withSelector:@selector(scInsertSubview:atIndex:)];
        [SCClassUtils swizzleSelector:@selector(sendSubviewToBack:)
                              ofClass:[UINavigationBar class]
                         withSelector:@selector(scSendSubviewToBack:)];
        
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
