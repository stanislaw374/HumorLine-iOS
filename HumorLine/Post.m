//
//  Post.m
//  HumorLine
//
//  Created by Yazhenskikh Stanislaw on 28.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Post.h"
#import "Comment.h"
#import "ASIHTTPRequest.h"
#import "Config.h"
#import "SBJSON.h"
#import "SDImageCache.h"
#import <AVFoundation/AVFoundation.h>
#import "Comment.h"
#import "NSURLConnection+Block.h"
#import <MediaPlayer/MediaPlayer.h>

@implementation Post
@synthesize ID = _ID;
@synthesize createdAt = _createdAt;
@synthesize imageURL = _imageURL;
@synthesize likes = _likes;
@synthesize text = _text;
@synthesize title = _title;
@synthesize type = _type;
@synthesize videoURL = _videoURL;
@synthesize comments = _comments;
@synthesize previewImage = _previewImage;
@synthesize imageData = _imageToSave;
@synthesize videoData = _videoToSave;
@synthesize delegate = _delegate;
@synthesize coordinate = _coordinate;

- (NSMutableArray *)comments {
    if (!_comments) {
        _comments = [NSMutableArray array];
    }
    return _comments;
}

+ (void)getNearestByCoordinate:(CLLocationCoordinate2D)coordinate withDelegate:(id<PostDelegate>)delegate {
    return [self get:-1 andSortBy:@"distance" withDelegate:delegate];
}

+ (void)get:(int)page withDelegate:(id<PostDelegate>)delegate {
    return [self get:page andSortBy:@"created_at" withDelegate:delegate];
}

+ (void)get:(int)page andSortBy:(NSString *)sort withDelegate:(id<PostDelegate>)delegate {
    NSString *path = [NSString stringWithFormat:@"/posts.json?sort_by=%@", sort];
    if (page != -1) {
        path = [path stringByAppendingString:[NSString stringWithFormat:@"&page=%d", page]];
    }
    
    NSURL *url = [NSURL URLWithString:path relativeToURL:API_URL];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSStringEncoding encoding;
        NSError *error;
        NSString *responseString = [NSString stringWithContentsOfURL:url usedEncoding:&encoding error:&error]; 
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate postsDidFailWithError:error];
            });
        }
        else {
            NSMutableArray *result = [NSMutableArray array];
            SBJsonParser *parser = [[SBJsonParser alloc] init];
            NSArray *posts = [parser objectWithString:responseString];
            for (NSDictionary *post in posts) {
                Post *p = [[Post alloc] init];
                NSDateFormatter *df = [[NSDateFormatter alloc] init];
                df.dateFormat = @"E MMM d HH:mm:ss Z y";
                p.ID = [post objectForKey:@"id"];
                p.createdAt = [df dateFromString:[post objectForKey:@"created_at"]];
                p.likes = [[post objectForKey:@"likes"] intValue];
                
                NSString *latStr = [post objectForKey:@"lat"];
                NSString *lngStr = [post objectForKey:@"lng"];
                if (![latStr isEqual:[NSNull null]] && ![lngStr isEqual:[NSNull null]]) {
                    double lat = [latStr doubleValue];
                    double lng = [lngStr doubleValue];
                    p.coordinate = CLLocationCoordinate2DMake(lat, lng);
                }
            
                p.type = [post objectForKey:@"post_type"];
                NSLog(@"post_type = %@", p.type);
                
                p.title = [post objectForKey:@"title"];
                if ([p.title isEqual:[NSNull null]]) {
                    p.title = @"";
                }
                p.text = [post objectForKey:@"text"];
                if ([p.text isEqual:[NSNull null]]) {
                    p.text = @"";
                }
                NSString *imageURLString = [post objectForKey:@"image_url"];
                //imageURLString = [imageURLString stringByReplacingOccurrencesOfString:@"png.*" withString:@"png" options:NSCaseInsensitiveSearch | NSRegularExpressionSearch range:NSMakeRange(0, imageURLString.length)];
                p.imageURL = [NSURL URLWithString:[API_PATH stringByAppendingString:imageURLString]];
                
                NSLog(@"Image url: %@", p.imageURL.absoluteString);
                
                NSString *videoURLString = [post objectForKey:@"video_url"];
                videoURLString = [videoURLString stringByReplacingOccurrencesOfString:@"MOV.*" withString:@"MOV" options:NSRegularExpressionSearch range:NSMakeRange(0, videoURLString.length)];
                p.videoURL = [NSURL URLWithString:[API_PATH stringByAppendingString:videoURLString]];
                
                NSLog(@"Video url: %@", p.videoURL.absoluteString);
                
                NSArray *comments = [post objectForKey:@"comments"];
                for (NSDictionary *comment in comments) {
                    Comment *c = [[Comment alloc] init];
                    c.ID = [comment objectForKey:@"id"];
                    c.text = [comment objectForKey:@"text"];
                    
                    [p.comments addObject:c];
                }
                
                
                [result addObject:p];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate postsDidLoad:result];
            });
        }
    });
}

- (BOOL)hasPreviewImage {
    NSString *imageKey;
    if ([self.type isEqualToString:@"image"]) {
        imageKey = self.imageURL.absoluteString;
    }
    else if ([self.type isEqualToString:@"video"]) {
        imageKey = self.videoURL.absoluteString;
    }
    return [[SDImageCache sharedImageCache] imageFromKey:imageKey] != nil;
}

- (UIImage *)previewImage {
    if (!_previewImage) {    
        NSString *imageKey;
        if ([self.type isEqualToString:@"image"]) {
            imageKey = self.imageURL.absoluteString;
        }
        else if ([self.type isEqualToString:@"video"]) {
            imageKey = self.videoURL.absoluteString;
        }
        _previewImage = [[SDImageCache sharedImageCache] imageFromKey:imageKey];    
        if (!_previewImage) {
            if ([self.type isEqualToString:@"image"]) {
                NSData *imageData = [NSData dataWithContentsOfURL:self.imageURL];
                _previewImage = [UIImage imageWithData:imageData];                    
            }
            else if ([self.type isEqualToString:@"video"]) {
               // MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:self.videoURL];
                //_previewImage = [player thumbnailImageAtTime:0 timeOption:MPMovieTimeOptionNearestKeyFrame]; 
                
                AVAsset *asset = [AVAsset assetWithURL:self.videoURL];
                if ([asset tracksWithMediaCharacteristic:AVMediaTypeVideo]) {
                    AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
                    Float64 duration = CMTimeGetSeconds(asset.duration);
                    CMTime actualTime;
                    NSError *error;
                    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:CMTimeMake(duration / 2, 600) actualTime:&actualTime error:&error];
                    _previewImage = [UIImage imageWithCGImage:imageRef];
                    CGImageRelease(imageRef);
                }
            }
            [[SDImageCache sharedImageCache] storeImage:_previewImage forKey:imageKey];
        }
    }
    return _previewImage;
}

//- (void)getComments {
//    NSString *path = [NSString stringWithFormat:@"/posts/%d/comments.json", self.ID];
//    NSURL *url = [NSURL URLWithString:path relativeToURL:API_URL];
//            
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSError *error;
//        NSString *responseString = [NSString stringWithContentsOfURL:url usedEncoding:nil error:&error];
//        if (error) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.delegate postCommentsDidFailWithError:error];
//            });            
//        }
//        else {
//            NSMutableArray *result = [NSMutableArray array];
//            SBJsonParser *parser = [[SBJsonParser alloc] init];
//            NSArray *comments = [parser objectWithString:responseString];
//            for (NSDictionary *comment in comments) {
//                Comment *c = [[Comment alloc] init];
//                c.ID = [comment objectForKey:@"id"];
//                c.text = [comment objectForKey:@"text"];        
//                [result addObject:c];
//            }
//            
//            self.comments = result;
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.delegate postCommentsDidLoad];
//            });
//        }
//    });
//}

- (void)addComment:(Comment *)comment {    
    NSString *path = [NSString stringWithFormat:@"/posts/%d/comments", [self.ID intValue]];
    NSURL *url = [NSURL URLWithString:path relativeToURL:API_URL];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"comment[text]=%@", comment.text] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:body];
    
    [NSURLConnection sendAsynchronousRequest:request successBlock:^(NSData *data, NSURLResponse *response) {
        NSString *responseString = [[NSString alloc] initWithUTF8String:data.bytes];
        
        NSLog(@"%@, %@", NSStringFromSelector(_cmd), responseString);
        
        [self.delegate postCommentDidAdd];
    } failureBlock:^(NSData *data, NSError *error) {
        [self.delegate postCommentDidFailWithError:error];
    }];
}

- (void)like {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"LikePost_%d", self.ID];
    if (![userDefaults objectForKey:key]) {
        self.likes++;
    }
}

+ (void)addPost:(Post *)post withDelegate:(id<PostDelegate>)delegate {
    NSString *path = [API_PATH stringByAppendingPathComponent:@"/posts"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:path]];    
    [request setHTTPMethod:@"POST"];
    
    NSString *boundary = [NSString stringWithString:@"---------------------------14737809831466499882746641449"];
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    
    if ([post.type isEqualToString:@"image"] || [post.type isEqualToString:@"video"]) {
        // file
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        if ([post.type isEqualToString:@"image"]) {
            [body appendData:[[NSString stringWithString:@"Content-Disposition: attachment; name=\"post[image]\"; filename=\".png\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithString:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        }
        else {
            [body appendData:[[NSString stringWithString:@"Content-Disposition: attachment; name=\"post[video]\"; filename=\".MOV\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithString:@"Content-Type: video/quicktime\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        
        }
        if ([post.type isEqualToString:@"image"]) {
            [body appendData:[NSData dataWithData:post.imageData]];
        }
        else {
            [body appendData:[NSData dataWithData:post.videoData]];
        }
        [body appendData:[[NSString stringWithString:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // post type
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"post[post_type]\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[post.type dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithString:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // likes
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"post[likes]\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%d", post.likes] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithString:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    if (post.text) {
        // text
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"post[text]\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[post.text dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithString:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    if (post.title) {
        // title
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"post[title]\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[post.title dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithString:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    if (CLLocationCoordinate2DIsValid(post.coordinate)) {
        // lat
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"post[lat]\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%lf", post.coordinate.latitude] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithString:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        
        // lng
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"post[lng]\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%lf", post.coordinate.longitude] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithString:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // close form
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // set request body
    [request setHTTPBody:body];
    
    [NSURLConnection sendAsynchronousRequest:request successBlock:^(NSData *data, NSURLResponse *response) {
        [delegate postDidAdd];
    } failureBlock:^(NSData *data, NSError *error) {
        [delegate postDidFailWithError:error];
    }];
}

- (void)reload {
    NSString *path = [NSString stringWithFormat:@"/posts/%d.json", [self.ID intValue]];
    NSURL *url = [NSURL URLWithString:path relativeToURL:API_URL];
    
    NSStringEncoding encoding;
    NSError *error;
    
    NSString *responseString = [NSString stringWithContentsOfURL:url usedEncoding:&encoding error:&error];
    NSLog(@"%@, %@", NSStringFromSelector(_cmd), responseString);
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dict = [parser objectWithString:responseString];
    
    self.likes = [[dict objectForKey:@"likes"] intValue];
    [self.comments removeAllObjects];
    NSArray *comments = [dict objectForKey:@"comments"];
    for (NSDictionary *comment in comments) {
        Comment *c = [[Comment alloc] init];
        c.ID = [comment objectForKey:@"id"];
        c.text = [comment objectForKey:@"text"];
        [self.comments addObject:c];
    }
}

@end
            