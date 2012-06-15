//
//  Post.h
//  HumorLine
//
//  Created by Yazhenskikh Stanislaw on 28.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class Comment;

@protocol PostDelegate <NSObject>
@optional
- (void)postsDidLoad:(NSArray *)posts;
- (void)postsDidFailWithError:(NSError *)error;
- (void)postDidAdd;
- (void)postDidFailWithError:(NSError *)error;
//- (void)postCommentsDidLoad;
//- (void)postCommentsDidFailWithError:(NSError *)error;
- (void)postCommentDidAdd;
- (void)postCommentDidFailWithError:(NSError *)error;
@end

@interface Post : NSObject 
@property (nonatomic, unsafe_unretained) id <PostDelegate> delegate;

@property (nonatomic, strong) NSNumber *ID;             // Идентификатор поста
@property (nonatomic, strong) NSDate *createdAt;        // Дата создания поста
@property (nonatomic, strong) NSURL *imageURL;          // url фото
@property (nonatomic, strong) NSURL *videoURL;          // url видео
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic) int likes;          // количество лайков
@property (nonatomic, strong) NSString *text;           // текст поста
@property (nonatomic, strong) NSString *title;          // заголовок поста
@property (nonatomic, strong) NSString *type;           // тип поста (image, video, text)
@property (nonatomic, strong) NSMutableArray *comments;        // комментарии поста

@property (nonatomic, strong) UIImage *previewImage;

@property (nonatomic, strong) NSData *imageData;    
@property (nonatomic, strong) NSData *videoData;  

+ (void)getNearestByCoordinate:(CLLocationCoordinate2D)coordinate withDelegate:(id <PostDelegate>)delegate; // получение всех постов с сортировкой по возрастанию расстояния до пользователя
+ (void)get:(int)page withDelegate:(id <PostDelegate>)delegate;                             // получение массива постов по номеру страницы
+ (void)get:(int)page andSortBy:(NSString *)sort withDelegate:(id <PostDelegate>)delegate;  // получение массива постов по номеру страницы и с сортировкой
+ (void)addPost:(Post *)post withDelegate:(id <PostDelegate>)delegate;                      // добавление поста

- (BOOL)hasPreviewImage;
//- (void)getComments;                                                                        // Получение комментариев поста
- (void)addComment:(Comment *)comment;                                                      // добавление комментария
- (void)like;           
- (void)reload;

@end