//
//  NSURLConnection+Block.h
//  HumorLine
//
//  Created by Yazhenskikh Stanislaw on 16.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLConnection (Block)
+ (void)sendAsynchronousRequest:(NSURLRequest *)request successBlock:(void(^)(NSData *, NSURLResponse *))success failureBlock:(void(^)(NSData *, NSError *))failure;
@end
