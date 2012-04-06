//
//  RKPost.h
//  HumorLine
//
//  Created by Yazhenskikh Stanislaw on 28.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

@interface RKPost : NSObject 
@property (nonatomic, strong) NSNumber *postID;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, strong) NSNumber *likes;
@property (nonatomic, strong) NSNumber *lat;
@property (nonatomic, strong) NSNumber *lng;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *videoURL;
@property (nonatomic, strong) NSSet *comments;
@end