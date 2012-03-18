//
//  Post.h
//  HumorLine
//
//  Created by Yazhenskikh Stanislaw on 18.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef enum { kPostTypePhoto, kPostTypeVideo, kPostTypeText } PostType;

@class Comment, Image;

@interface Post : NSManagedObject

@property (nonatomic) double lat;
@property (nonatomic) int32_t likesCount;
@property (nonatomic) double lng;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * title;
@property (nonatomic) int16_t type;
@property (nonatomic, retain) NSString * videoURL;
@property (nonatomic, retain) NSSet *comments;
@property (nonatomic, retain) Image *image;
@end

@interface Post (CoreDataGeneratedAccessors)

- (void)addCommentsObject:(Comment *)value;
- (void)removeCommentsObject:(Comment *)value;
- (void)addComments:(NSSet *)values;
- (void)removeComments:(NSSet *)values;
@end
