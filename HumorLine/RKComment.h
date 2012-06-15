//
//  RKComment.h
//  HumorLine
//
//  Created by Yazhenskikh Stanislaw on 09.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RKPost;

@interface RKComment : NSManagedObject

@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * commentID;
@property (nonatomic, retain) RKPost *post;

@end
