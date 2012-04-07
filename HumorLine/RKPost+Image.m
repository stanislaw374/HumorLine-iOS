//
//  RKPost+Image.m
//  HumorLine
//
//  Created by Yazhenskikh Stanislaw on 06.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RKPost+Image.h"
#import "SDImageCache.h"
#import <AVFoundation/AVFoundation.h>

@implementation RKPost (Image)
- (BOOL)hasImage {
    NSString *imageKey;
    if ([self.type isEqualToString:@"image"]) {
        imageKey = self.imageURL;
    }
    else if ([self.type isEqualToString:@"video"]) {
        imageKey = self.videoURL;
    }
    return [[SDImageCache sharedImageCache] imageFromKey:imageKey] != nil;
}

- (UIImage *)image {
    NSString *imageKey;
    if ([self.type isEqualToString:@"image"]) {
        imageKey = self.imageURL;
    }
    else if ([self.type isEqualToString:@"video"]) {
        imageKey = self.videoURL;
    }
    UIImage *image = [[SDImageCache sharedImageCache] imageFromKey:imageKey];    
    if (!image) {
        if ([self.type isEqualToString:@"image"]) {
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.imageURL]];
            image = [UIImage imageWithData:imageData];                    
        }
        else if ([self.type isEqualToString:@"video"]) {
            AVAsset *asset = [AVAsset assetWithURL:[NSURL URLWithString:self.videoURL]];
            if ([asset tracksWithMediaCharacteristic:AVMediaTypeVideo]) {
                AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
                Float64 duration = CMTimeGetSeconds(asset.duration);
                CMTime actualTime;
                NSError *error;
                CGImageRef imageRef = [imageGenerator copyCGImageAtTime:CMTimeMake(duration / 2.0, 600) actualTime:&actualTime error:&error];
                image = [UIImage imageWithCGImage:imageRef];
                CGImageRelease(imageRef);
            }
        }
        [[SDImageCache sharedImageCache] storeImage:image forKey:imageKey];
    }
    return image;
}
@end
