//
//  AddNewView.m
//  HumorLine
//
//  Created by Yazhenskikh Stanislaw on 29.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AddNewView.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "AddPhotoView.h"
#import "AddVideoView.h"
#import "AddTextView.h"
#import "AddTrololoView.h"

@interface AddNewView()
@property (nonatomic, strong) UIActionSheet *photoActionSheet;
@property (nonatomic, strong) UIActionSheet *videoActionSheet;
@property (nonatomic, strong) UIImagePickerController *imagePicker;
- (void)onCancelButtonClick;
@end

@implementation AddNewView
@synthesize photoActionSheet = _photoActionSheet;
@synthesize videoActionSheet = _videoActionSheet;
@synthesize imagePicker = _imagePicker;

- (UIImagePickerController *)imagePicker {
    if (!_imagePicker) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.allowsEditing = YES;
        _imagePicker.videoQuality = UIImagePickerControllerQualityTypeLow;
        _imagePicker.videoMaximumDuration = 30;
        _imagePicker.delegate = self;
    }
    return _imagePicker;
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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Отмена" style:UIBarButtonItemStyleBordered target:self action:@selector(onCancelButtonClick)];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)onCancelButtonClick {
    [self.presentingViewController dismissModalViewControllerAnimated:YES];
//    [UIView  beginAnimations:nil context:NULL];
//    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//    [UIView setAnimationDuration:0.75];
//    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.navigationController.view cache:NO];
//    [UIView commitAnimations];
//    
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDelay:0.375];
//    [self.navigationController popViewControllerAnimated:NO];
//    [UIView commitAnimations];
}

- (IBAction)onPhotoButtonClick {
    [self.photoActionSheet showInView:self.view];
}

- (IBAction)onVideoButtonClick {
    [self.videoActionSheet showInView:self.view];
}

- (IBAction)onTextButtonClick {
    AddTextView *addTextView = [[AddTextView alloc] init];
    [self.navigationController pushViewController:addTextView animated:YES];
}

- (IBAction)onTrololoButtonClick {
    AddTrololoView *addTrololoView = [[AddTrololoView alloc] init];
    [self.navigationController pushViewController:addTrololoView animated:YES];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if ([actionSheet isEqual:self.photoActionSheet] || [actionSheet isEqual:self.videoActionSheet]) {
        UIImagePickerControllerSourceType sourceType;
        
        switch (buttonIndex) {
            case 0:
                sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                break;
            case 1:
                sourceType = UIImagePickerControllerSourceTypeCamera;
                break;
            default:
                return;
        }
        if (![UIImagePickerController isSourceTypeAvailable:sourceType]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:@"Источник не доступен" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
            [alert show];
        }
        else {
            self.imagePicker.sourceType = sourceType;
            if ([actionSheet isEqual:self.videoActionSheet]) {
                self.imagePicker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, nil];
            }
            else {
                self.imagePicker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeImage, nil];
            }
            [self presentModalViewController:self.imagePicker animated:YES];                      
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
   [self dismissModalViewControllerAnimated:NO];  
    
    CFStringRef mediaType = (__bridge CFStringRef)[info objectForKey:UIImagePickerControllerMediaType];
    
    if (CFStringCompare(mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
        UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        UIImage *editedImage = [info objectForKey:UIImagePickerControllerEditedImage];
        UIImage *imageToSave = editedImage ? editedImage : originalImage;
        AddPhotoView *addPhotoView = [[AddPhotoView alloc] init];
        addPhotoView.image = imageToSave;
        //[self presentModalViewController:addPhotoView animated:YES];
        [self.navigationController pushViewController:addPhotoView animated:YES];
    }
    else if (CFStringCompare(mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
        NSURL *originalVideoURL = [info objectForKey:UIImagePickerControllerReferenceURL];
        NSURL *editedVideoURL = [info objectForKey:UIImagePickerControllerMediaURL];
        NSURL *videoURLToSave = editedVideoURL ? editedVideoURL : originalVideoURL;
        
        AddVideoView *addVideoView = [[AddVideoView alloc] init];
        addVideoView.videoURL = videoURLToSave;
        //[self presentModalViewController:addVideoView animated:YES];
        [self.navigationController pushViewController:addVideoView animated:YES];
    }    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissModalViewControllerAnimated:YES];
}

@end
