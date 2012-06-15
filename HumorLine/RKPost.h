//
//  RKPost.h
//  HumorLine
//
//  Created by Yazhenskikh Stanislaw on 09.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RKComment;

@interface RKPost : NSManagedObject

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSNumber * lat;
@property (nonatomic, retain) NSNumber * likes;
@property (nonatomic, retain) NSNumber * lng;
@property (nonatomic, retain) NSNumber * postID;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * videoURL;
@property (nonatomic, retain) NSSet *comments;
@end

@interface RKPost (CoreDataGeneratedAccessors)

- (void)addCommentsObject:(RKComment *)value;
- (void)removeCommentsObject:(RKComment *)value;
- (void)addComments:(NSSet *)values;
- (void)removeComments:(NSSet *)values;
@end
