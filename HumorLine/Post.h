//
//  Post.h
//  HumorLine
//
//  Created by Yazhenskikh Stanislaw on 26.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Comment, Image, Like;

@interface Post : NSManagedObject

@property (nonatomic) NSTimeInterval date;
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
@property (nonatomic, retain) NSSet *likes;
@end

@interface Post (CoreDataGeneratedAccessors)

- (void)addCommentsObject:(Comment *)value;
- (void)removeCommentsObject:(Comment *)value;
- (void)addComments:(NSSet *)values;
- (void)removeComments:(NSSet *)values;
- (void)addLikesObject:(Like *)value;
- (void)removeLikesObject:(Like *)value;
- (void)addLikes:(NSSet *)values;
- (void)removeLikes:(NSSet *)values;
@end
