//
//  Comment.h
//  HumorLine
//
//  Created by Yazhenskikh Stanislaw on 28.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Comment : NSObject

@property (nonatomic, strong) NSNumber *ID; 
@property (nonatomic, strong) NSString *text;

@end
