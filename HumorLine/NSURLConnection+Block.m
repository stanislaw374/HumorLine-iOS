//
//  NSURLConnection+Block.m
//  HumorLine
//
//  Created by Yazhenskikh Stanislaw on 16.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSURLConnection+Block.h"

@implementation NSURLConnection (Block)
+ (void)sendAsynchronousRequest:(NSURLRequest *)request successBlock:(void (^)(NSData *, NSURLResponse *))success failureBlock:(void (^)(NSData *, NSError *))failure {
    NSError *error;
    NSURLResponse *response;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error) {
        failure(data, error);
    }
    else {
        success(data, response);
    }
}
@end
