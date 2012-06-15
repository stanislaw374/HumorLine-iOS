//
//  DetailView.h
//  SDWebImage
//
//  Created by Yazhenskikh Stanislaw on 12.03.12.
//  Copyright (c) 2012 Dailymotion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"
#import "Facebook.h"

@interface PostsView : UIViewController
@property (nonatomic, strong) NSArray *posts;
@property (nonatomic, strong) Post *currentPost;
@end
