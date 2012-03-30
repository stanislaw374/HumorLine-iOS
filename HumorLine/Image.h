//
//  Image.h
//  HumorLine
//
//  Created by Yazhenskikh Stanislaw on 28.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Post;

@interface Image : NSManagedObject

@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) Post *post;

@end
