//
//  User.h
//  HumorLine
//
//  Created by Yazhenskikh Stanislaw on 26.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Like;

@interface User : NSManagedObject

@property (nonatomic) int64_t userID;
@property (nonatomic, retain) NSSet *likes;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addLikesObject:(Like *)value;
- (void)removeLikesObject:(Like *)value;
- (void)addLikes:(NSSet *)values;
- (void)removeLikes:(NSSet *)values;
@end
