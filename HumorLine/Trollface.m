//
//  Trollface.m
//  HumorLine
//
//  Created by Yazhenskikh Stanislaw on 23.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Trollface.h"

static const int _count = 3;
static NSArray *_all;

@implementation Trollface

+ (NSArray *)all {
    if (!_all) {     
        NSMutableArray *t = [[NSMutableArray alloc] init];
        for (int i = 0; i < _count; i++) {
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"trollface%d.png", i + 1]];
            [t addObject:image];
        }
        _all = t;
    }
    return _all;
}

@end
