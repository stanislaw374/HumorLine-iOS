//
//  MainMenu.m
//  HumorLine
//
//  Created by Yazhenskikh Stanislaw on 12.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MainMenu.h"
#import "AddTrololoView.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "AuthorizationView.h"

@interface MainMenu()
- (void)onLoginButtonClick;
- (void)onAddButtonClick;
@property (nonatomic, unsafe_unretained) UIViewController *viewController;
@property (nonatomic, strong) AddPhotoView *addPhotoView;
@property (nonatomic, strong) UIPopoverController *popoverContoller;
@property (nonatomic, strong) UIActionSheet *addActionSheet;
@property (nonatomic, strong) UIActionSheet *photoActionSheet;
@property (nonatomic, strong) UIActionSheet *videoActionSheet;
@property (nonatomic, strong) UIActionSheet *loginActionSheet;
@property (nonatomic, strong) AddTrololoView *addTrololoView;
@property (nonatomic, strong) AuthorizationView *authorizationView;
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@end

@implementation MainMenu
@synthesize viewController = _viewController;
@synthesize addPhotoView = _addPhotoView;
@synthesize popoverContoller = _popoverContoller;
@synthesize addActionSheet = _addActionSheet;
@synthesize photoActionSheet = _photoActionSheet;
@synthesize videoActionSheet = _videoActionSheet;
@synthesize loginActionSheet = _loginActionSheet;
@synthesize addTrololoView = _addTrololoView;
@synthesize authorizationView = _authorizationView;

#pragma mark - Lazy Instantiation

- (AuthorizationView *)authorizationView {
    if (!_authorizationView) {
        _authorizationView = [[AuthorizationView alloc] init];
    }
    return _authorizationView;
}

- (UIActionSheet *)addActionSheet {
    if (!_addActionSheet) {
        _addActionSheet = [[UIActionSheet alloc] initWithTitle:@"Добавить прикол" delegate:self cancelButtonTitle:@"Отмена" destructiveButtonTitle:nil otherButtonTitles:@"Фото", @"Видео", @"Текст", @"Trololo", nil];                
    }
    return _addActionSheet;
}

- (UIActionSheet *)photoActionSheet {
    if (!_photoActionSheet) {
        _photoActionSheet = [[UIActionSheet alloc] initWithTitle:@"Фото" delegate:self cancelButtonTitle:@"Отмена" destructiveButtonTitle:nil otherButtonTitles:@"Выбрать из библиотеки", @"Сделать фото", nil];
    }
    return _photoActionSheet;
}

- (UIActionSheet *)videoActionSheet {
    if (!_videoActionSheet) {
        _videoActionSheet = [[UIActionSheet alloc] initWithTitle:@"Видео" delegate:self cancelButtonTitle:@"Отмена" destructiveButtonTitle:nil otherButtonTitles:@"Выбрать из библиотеки", @"Снять видео", nil];
    }
    return _videoActionSheet;
}

- (UIActionSheet *)loginActionSheet {
    if (!_loginActionSheet) {
        _loginActionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Отмена" destructiveButtonTitle:nil otherButtonTitles:@"Вход", @"TOP30", @"На карте", nil];
    }
    return _loginActionSheet;
}

//- (AddPhotoView *)addPhotoView {
//    if (1) {
//        _addPhotoView = [[AddPhotoView alloc] init];
//    }
//    return _addPhotoView;
//}

- (AddTrololoView *)addTrololoView {
    if (!_addTrololoView) {
        _addTrololoView = [[AddTrololoView alloc] init];
    }
    return _addTrololoView;
}

- (id)initWithViewController:(UIViewController *)viewController {
    if (self = [super init]) {
        self.viewController = viewController;
    }
    return self;
}

- (void)addAddButton {
    //UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Добавить" style:UIBarButtonItemStyleBordered target:self action:@selector(onAddButtonClick)];
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(onAddButtonClick)];
    self.viewController.navigationItem.leftBarButtonItem = button;
}

- (void)addLoginButton {
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Войти" style:UIBarButtonItemStyleBordered target:self action:@selector(onLoginButtonClick)];
    self.viewController.navigationItem.rightBarButtonItem = button;
}

- (void)onLoginButtonClick {
    [self.loginActionSheet showFromBarButtonItem:self.viewController.navigationItem.rightBarButtonItem animated:YES];
}

- (void)onAddButtonClick {
    [self.addActionSheet showFromBarButtonItem:self.viewController.navigationItem.leftBarButtonItem animated:YES];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"%@, buttonIndex: %d", NSStringFromSelector(_cmd), buttonIndex);
    
    if ([actionSheet isEqual:self.addActionSheet]) {
        switch (buttonIndex) {
            case 0:
                [self.photoActionSheet showFromBarButtonItem:self.viewController.navigationItem.leftBarButtonItem animated:YES];
                break;
            case 1:
                [self.videoActionSheet showFromBarButtonItem:self.viewController.navigationItem.leftBarButtonItem animated:YES];
                break;
            case 2: break;
            case 3:
                [self.viewController.navigationController pushViewController:self.addTrololoView animated:YES];                
                break;
        }        
    }
    else if ([actionSheet isEqual:self.photoActionSheet] || [actionSheet isEqual:self.videoActionSheet]) {
        //UIImagePickerController *imagePicker;
        switch (buttonIndex) {
            case 0:
                if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:@"Невозможно выбрать из библиотеки" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
                    [alert show];      
                    return;
                }
                else {
                    self.imagePicker = [[UIImagePickerController alloc] init];
                    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;  
                    if ([actionSheet isEqual:self.videoActionSheet]) {
                        self.imagePicker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, nil];
                    }
                }
                break;
            case 1:
                if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:@"Нет камеры" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
                    [alert show];                    
                    return;
                }
                else {
                    self.imagePicker = [[UIImagePickerController alloc] init];
                    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                    if ([actionSheet isEqual:self.videoActionSheet]) {
                        self.imagePicker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, nil];
                    }
                }
                break;
            case 2:
                return;
        }
        self.imagePicker.delegate = self;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [self.viewController presentModalViewController:self.imagePicker animated:YES];
        }
        else {
            self.popoverContoller = [[UIPopoverController alloc] initWithContentViewController:self.imagePicker];
            [self.popoverContoller presentPopoverFromBarButtonItem:self.viewController.navigationItem.leftBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    }
    else if ([actionSheet isEqual:self.loginActionSheet]) {
        switch (buttonIndex) {
            case 0:
                [self.viewController.navigationController pushViewController:self.authorizationView animated:YES];
                break;
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self.viewController dismissModalViewControllerAnimated:NO];
    }
    else {
        [self.popoverContoller dismissPopoverAnimated:NO];
    }
    CFStringRef mediaType = (__bridge CFStringRef)[info objectForKey:UIImagePickerControllerMediaType];
    if (CFStringCompare (mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        self.addPhotoView = [[AddPhotoView alloc] init];
        self.addPhotoView.image = image;
        [self.viewController presentModalViewController:self.addPhotoView animated:YES];
    }
    else if (CFStringCompare(mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
        NSURL *videoUrl = [info objectForKey:UIImagePickerControllerMediaURL];
        NSLog(@"videoURL : %@", videoUrl.description);
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self.viewController dismissModalViewControllerAnimated:YES];
}

//#pragma mark - AddPhotoViewDelegate
//- (void)addPhotoViewDidFinish {
//    [self.viewController dismissModalViewControllerAnimated:YES];
//}

@end
