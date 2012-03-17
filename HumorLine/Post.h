//
//  Post.h
//  HumorLine
//
//  Created by Yazhenskikh Stanislaw on 16.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef enum { kPostTypePhoto = 0, kPostTypeVideo, kPostTypeText } PostType;

@class Comment, Image;

@interface Post : NSManagedObject

@property (nonatomic) float lat;
@property (nonatomic) int32_t likesCount;
@property (nonatomic) float lng;
@property (nonatomic, retain) NSString * text;
@property (nonatomic) int16_t type;
@property (nonatomic, retain) id video;
@property (nonatomic, retain) NSSet *comments;
@property (nonatomic, retain) Image *image;
@end

@interface Post (CoreDataGeneratedAccessors)
- (void)addCommentsObject:(Comment *)value;
- (void)removeCommentsObject:(Comment *)value;
- (void)addComments:(NSSet *)values;
- (void)removeComments:(NSSet *)values;
@end
