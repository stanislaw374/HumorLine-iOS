//
//  MainMenu.m
//  HumorLine
//
//  Created by Yazhenskikh Stanislaw on 12.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MainMenu.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface MainMenu()
- (void)onLoginButtonClick;
- (void)onAddButtonClick;
@property (nonatomic, strong) UIViewController *viewController;
@property (nonatomic, strong) AddPhotoView *addPhotoView;
@property (nonatomic, strong) UIPopoverController *popoverContoller;
@property (nonatomic, strong) UIActionSheet *addActionSheet;
@property (nonatomic, strong) UIActionSheet *photoActionSheet;
@property (nonatomic, strong) UIActionSheet *videoActionSheet;
@property (nonatomic, strong) UIActionSheet *loginActionSheet;
@end

@implementation MainMenu
@synthesize viewController = _viewController;
@synthesize addPhotoView = _addPhotoView;
@synthesize popoverContoller = _popoverContoller;
@synthesize addActionSheet = _addActionSheet;
@synthesize photoActionSheet = _photoActionSheet;
@synthesize videoActionSheet = _videoActionSheet;
@synthesize loginActionSheet = _loginActionSheet;

#pragma mark - Lazy Instantiation
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

- (AddPhotoView *)addPhotoView {
    if (!_addPhotoView) {
        _addPhotoView = [[AddPhotoView alloc] init];
    }
    return _addPhotoView;
}

- (id)initWithViewController:(UIViewController *)viewController {
    if (self = [super init]) {
        self.viewController = viewController;
    }
    return self;
}

- (void)addAddButton {
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Добавить" style:UIBarButtonItemStyleBordered target:self action:@selector(onAddButtonClick)];
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
        }        
    }
    else if ([actionSheet isEqual:self.photoActionSheet] || [actionSheet isEqual:self.videoActionSheet]) {
        UIImagePickerController *imagePicker;
        switch (buttonIndex) {
            case 0:
                if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:@"Невозможно выбрать из библиотеки" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
                    [alert show];      
                    return;
                }
                else {
                    imagePicker = [[UIImagePickerController alloc] init];
                    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;  
                    if ([actionSheet isEqual:self.videoActionSheet]) {
                        imagePicker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, nil];
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
                    imagePicker = [[UIImagePickerController alloc] init];
                    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                    if ([actionSheet isEqual:self.videoActionSheet]) {
                        imagePicker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, nil];
                    }
                }
                break;
        }
        imagePicker.delegate = self;
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
            [self.viewController presentModalViewController:imagePicker animated:YES];
        }
        else {
            self.popoverContoller = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
            [self.popoverContoller presentPopoverFromBarButtonItem:self.viewController.navigationItem.leftBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [self.viewController dismissModalViewControllerAnimated:YES];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    //[self.viewController.navigationController pushViewController:self.addPhotoView animated:YES];
    //self.viewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    //self.viewController.modalPresentationStyle = UIModalPresenta
    //self.addPhotoView.delegate = self;
    //[self.viewController presentModalViewController:self.addPhotoView animated:YES];
    //self.addPhotoView.imageView.image = image;
    self.addPhotoView.delegate = self;
    self.addPhotoView.imageView.image = image;
    [self.viewController.navigationController pushViewController:self.addPhotoView animated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self.viewController dismissModalViewControllerAnimated:YES];
    self.addPhotoView.delegate = self;
    [self.viewController.navigationController pushViewController:self.addPhotoView animated:YES];
}

#pragma mark - AddPhotoViewDelegate
- (void)addPhotoViewDidFinish {
    //[self.viewController dismissModalViewControllerAnimated:YES];
}

@end
