//
//  TrololoView.m
//  HumorLine
//
//  Created by Yazhenskikh Stanislaw on 13.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TrololoView.h"
//#import "Picture.h"
#import "AppDelegate.h"
#import "Post.h"
#import "Image.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+Thumbnail.h"
#import "Trollface.h"
#import "SCAppUtils.h"
#import "KeyboardListener.h"

@interface TrololoView()
@property (nonatomic) int currentImage;
@property (nonatomic, strong) UIActionSheet *addRageSheet;
@property (nonatomic, strong) UIActionSheet *addPhotoSheet;
@property (nonatomic, strong) UIAlertView *saveAlert;
//@property (nonatomic, unsafe_unretained) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, strong) UIPopoverController *popover;
@property (nonatomic, strong) NSMutableArray *imageViews;
@property (nonatomic, strong) UIImageView *currentImageView;
//@property (nonatomic, strong) UIScrollView *currentScrollView;
@property (nonatomic) BOOL isPreviewing;
@property (nonatomic) CGPoint lastPoint;
@property (nonatomic) BOOL mouseSwiped;
@property (nonatomic) BOOL isGesture;
//@property (nonatomic, strong) UIButton *selectedButton;
@property (nonatomic, unsafe_unretained) UIView *selectedView;
//@property (nonatomic, strong) UIPopoverController *popoverWithTrollfaces;
@property (nonatomic) BOOL isEditing;
- (void)updateUI;
- (void)viewDragged:(UIPanGestureRecognizer *)gesture;
- (void)viewPinched:(UIPinchGestureRecognizer *)gesture;
- (void)viewRotated:(UIRotationGestureRecognizer *)gesture;
//- (void)viewTapped:(UITapGestureRecognizer *)gesture;
- (void)onTextFieldDidEndOnExit:(id)sender;
- (BOOL)saveImageToLine;
- (BOOL)saveImageToPhotosAlbum;
//- (void)selectButton:(UIButton *)button;
//- (void)deselectButton:(UIButton *)button;
- (void)onButtonClick:(id)sender;
- (void)showTrollfacePicker;
- (void)selectView:(UIView *)view;
- (void)deselectView;
- (void)onButtonTouchDown:(UIButton *)sender;
- (void)onMenuDeleteButtonClick;
- (void)onSaveButtonClick;
- (UIImage *)prepareImageToSave;
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
@end

@implementation TrololoView
//@synthesize currentScrollView = _currentScrollView;
@synthesize imageView;
@synthesize saveAlert = _saveAlert;
@synthesize imagesCount = _imagesCount;
@synthesize faceButton = _faceButton;
@synthesize photoButton = _photoButton;
@synthesize textButton = _textButton;
@synthesize nextButton = _nextButton;
@synthesize nextItem = _nextItem;
@synthesize trollfacePicker = _trollfacePicker;
@synthesize currentImage = _currentImage;
@synthesize addRageSheet = _addRageSheet;
@synthesize addPhotoSheet = _addPhotoSheet;
//@synthesize panGestureRecognizer = _panGestureRecognizer;
@synthesize popover = _popover;
@synthesize imageViews = _imageViews;
@synthesize currentImageView = _currentImageView;
@synthesize isPreviewing = _isPreviewing;
@synthesize lastPoint = _lastPoint;
@synthesize mouseSwiped = _mouseSwiped;
@synthesize isGesture = _isGesture;
//@synthesize selectedButton = _selectedButton;
//@synthesize popoverWithTrollfaces = _popoverWithTrollfaces;
@synthesize isEditing = _isEditing;
@synthesize selectedView = _selectedView;

- (NSMutableArray *)imageViews {
    if (!_imageViews) {
        _imageViews = [[NSMutableArray alloc] init];
    }
    return _imageViews;
}

- (UIActionSheet *)addRageSheet {
    if (!_addRageSheet) {
        _addRageSheet = [[UIActionSheet alloc] initWithTitle:@"Trollface" delegate:self cancelButtonTitle:@"Отмена" destructiveButtonTitle:nil otherButtonTitles:@"", nil];
        [[[_addRageSheet valueForKey:@"_buttons"] objectAtIndex:0] setImage:[UIImage imageNamed:@"trollface.png"] forState:UIControlStateNormal];
    }
    return _addRageSheet;
}

- (UIActionSheet *)addPhotoSheet {
    if (!_addPhotoSheet) {
        _addPhotoSheet = [[UIActionSheet alloc] initWithTitle:@"Фото" delegate:self cancelButtonTitle:@"Отмена" destructiveButtonTitle:nil otherButtonTitles:@"Выбрать из библиотеки", @"Сделать фото", nil];
    }
    return _addPhotoSheet;
}

- (UIAlertView *)saveAlert {
    if (!_saveAlert) {
        _saveAlert = [[UIAlertView alloc] initWithTitle:@"Сохранить" message:@"" delegate:self cancelButtonTitle:@"Отмена" otherButtonTitles:@"В фотоальбом", @"В ленте", nil];
    }
    return _saveAlert;
}
//
//- (UIPanGestureRecognizer *)panGestureRecognizer {
//    return [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(viewDragged:)];
//}

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
    
    self.currentImage = 0;    
    self.isEditing = YES;
    
    [self updateUI];
    
    NSLog(@"%@ : imageView.frame = %@", NSStringFromSelector(_cmd), NSStringFromCGRect(self.imageView.frame));
    
    for (int i = 0; i < self.imagesCount; i++) {
        UIImageView *iv = [[UIImageView alloc] initWithFrame:self.imageView.frame];
        //iv.contentSize = iv.frame.size;
        iv.clipsToBounds = YES;
        iv.autoresizingMask = self.imageView.autoresizingMask;
        iv.userInteractionEnabled = YES;
        iv.contentMode = UIViewContentModeScaleToFill;
        iv.backgroundColor = [UIColor whiteColor];
        if (i > 0) iv.hidden = YES;
        else iv.hidden = NO; 
        [self.imageViews addObject:iv];
        [self.view addSubview:iv];
    }
    self.currentImageView = [self.imageViews objectAtIndex:0];
    [self.view bringSubviewToFront:self.trollfacePicker];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(onSaveButtonClick)];
} 

- (void)viewDidUnload
{
    [self setImageView:nil];
    [self setNextButton:nil];
    [self setNextItem:nil];
    [self setFaceButton:nil];
    [self setPhotoButton:nil];
    [self setTrollfacePicker:nil];
    [self setTextButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)showTrollfacePicker {
    self.trollfacePicker.hidden = !self.trollfacePicker.hidden;
}

- (IBAction)onRageButtonClick:(id)sender {    
    FacePickerView *faceView = [[FacePickerView alloc] init];
    faceView.delegate = self;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:faceView];
    [SCAppUtils customizeNavigationController:navigationController];
    [self presentModalViewController:navigationController animated:YES];
    
//    if (!self.selectedView) {
//        int trollfaceNumber = arc4random() % [Trollface all].count;
//        UIImage *trollface = [[Trollface all] objectAtIndex:trollfaceNumber];
//        
//    }
//    else {
//        [self showTrollfacePicker];
//    }
}

//- (void)onButtonClick:(id)sender {
//    if (self.isEditing) {
//        UIButton *button = (UIButton *)sender;
//        [self selectButton:button];
//    }    
//}

- (void)onButtonTouchDown:(UIButton *)sender {
    [self selectView:sender];
    
    [sender becomeFirstResponder];
    
    UIMenuController *menu = [UIMenuController sharedMenuController];
    menu.menuItems = [NSArray arrayWithObjects:
                      [[UIMenuItem alloc] initWithTitle:@"Удалить" action:@selector(onMenuDeleteButtonClick)], nil];
    [menu setTargetRect:CGRectMake(sender.center.x, sender.center.y, 1, 1) inView:sender];
    [menu setMenuVisible:YES animated:YES];
}

- (IBAction)onPhotoButtonClick:(id)sender {
    [self.addPhotoSheet showInView:self.navigationController.view];
}

- (IBAction)onTextButtonClick:(id)sender {
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.imageView.frame.size.width - 20, 50)];
    textView.autoresizingMask = 
    //UIViewAutoresizingFlexibleWidth | 
    //UIViewAutoresizingFlexibleHeight | 
    UIViewAutoresizingFlexibleBottomMargin | 
    UIViewAutoresizingFlexibleLeftMargin | 
    UIViewAutoresizingFlexibleRightMargin | 
    UIViewAutoresizingFlexibleTopMargin;
    textView.text = @"Текст";
    textView.font = [UIFont boldSystemFontOfSize:24];
    textView.textColor = [UIColor blackColor];
    
    UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(viewDragged:)];
    [textView addGestureRecognizer:gesture];
    gesture.delegate = self;
    
    textView.backgroundColor = [UIColor clearColor];
    //[textView addTarget:self action:@selector(onTextFieldDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
    textView.delegate = self;
    
    UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(viewRotated:)];
    [textView addGestureRecognizer:rotationGesture];
    rotationGesture.delegate = self;
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(viewPinched:)];
    [textView addGestureRecognizer:pinchGesture];
    pinchGesture.delegate = self;
    
    [self.currentImageView addSubview:textView];
}

- (IBAction)onBackButtonClick:(id)sender {
    if (self.currentImage > 0) {
        ((UIView *)[self.imageViews objectAtIndex:self.currentImage]).hidden = YES;
        self.currentImage--;
        ((UIImageView *)[self.imageViews objectAtIndex:self.currentImage]).hidden = NO;
        self.currentImageView = [self.imageViews objectAtIndex:self.currentImage];
        [self updateUI];
    }
}

- (IBAction)onNextButtonClick:(id)sender {
    if (self.currentImage < self.imagesCount - 1) {
        if (self.isPreviewing) { [self onPreviewButtonClick:nil]; }
        else {
            ((UIView *)[self.imageViews objectAtIndex:self.currentImage]).hidden = YES;
            self.currentImage++;
            ((UIImageView *)[self.imageViews objectAtIndex:self.currentImage]).hidden = NO;
            [self.imageViews objectAtIndex:self.currentImage];        
            self.currentImageView = [self.imageViews objectAtIndex:self.currentImage];
            [self updateUI];
        }
    }
    else {
        if (!self.isPreviewing) [self onPreviewButtonClick:nil];
//        if ([self saveImage]) {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Трололо успешно добавлено" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
//            [alert show];
//            //[self.presentingViewController dismissModalViewControllerAnimated:YES];
//            [self.navigationController popToRootViewControllerAnimated:YES];
//        }
    }
}

- (void)onSaveButtonClick {
    [self deselectView];
    [self.saveAlert show];
}

- (UIImage *)prepareImageToSave {
    UIGraphicsBeginImageContext(CGSizeMake(self.currentImageView.frame.size.width, self.currentImageView.frame.size.height));
    CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), [UIColor blackColor].CGColor);
    CGContextFillRect(UIGraphicsGetCurrentContext(), self.imageView.bounds);
    UIView *viewToSave = [[UIView alloc] initWithFrame:self.currentImageView.bounds];
    for (UIImageView *iv in self.imageViews) {
        CGRect frame = CGRectMake(iv.frame.origin.x - self.imageView.frame.origin.x, iv.frame.origin.y - self.imageView.frame.origin.y, iv.frame.size.width, iv.frame.size.height);
        iv.frame = frame;
        [viewToSave addSubview:iv];
    }
    [viewToSave.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *imageToSave = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();    
    
    return imageToSave;
}

- (BOOL)saveImageToPhotosAlbum {
    UIImage *imageToSave = [self prepareImageToSave];
    UIImageWriteToSavedPhotosAlbum(imageToSave, self, nil, nil);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Трололо сохранено в фотоальбоме" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    [self.navigationController popViewControllerAnimated:YES];
    return YES;
}

- (void)               image: (UIImage *) image
    didFinishSavingWithError: (NSError *) error
                 contextInfo: (void *) contextInfo {    
}

- (BOOL)saveImageToLine {          
    UIImage *imageToSave = [self prepareImageToSave];    
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    Post *newPost = [NSEntityDescription insertNewObjectForEntityForName:@"Post" inManagedObjectContext:appDelegate.managedObjectContext];
//    newPost.type = kPostTypeImage;
//    newPost.image = (Image *)[NSEntityDescription insertNewObjectForEntityForName:@"Image" inManagedObjectContext:appDelegate.managedObjectContext];
//    newPost.image.image = imageToSave;
//    newPost.date = [NSDate date];
//    
//    NSError *error;
//    if (![appDelegate.managedObjectContext save:&error]) {
//        NSLog(@"Error saving: %@", error.localizedDescription);
//        return NO;
//    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Трололо сохранено в ленте" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    [self.navigationController popViewControllerAnimated:YES];
    return YES;
}

//- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
//    NSString *message = error ? @"Ошибка при сохранении изображения" : @"Изображение сохранено в фотогаллерее";
//    
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
//    [alert show];
//    
//    if (!error) {
//        [self.navigationController popViewControllerAnimated:YES];
//    }
//}

- (IBAction)onPreviewButtonClick:(id)sender {
    if (!self.isPreviewing) {
        self.isPreviewing = YES;
        //self.imageView.hidden = NO;
        //self.currentImageView.hidden = YES;
        //self.title = @"Просмотр";
//        NSMutableArray *previewImages = [[NSMutableArray alloc] init];
//        for (UIImageView *imageView_ in self.imageViews) {
//            UIImage *previewImage = [Picture renderView:imageView_];
//            UIImageWriteToSavedPhotosAlbum(previewImage, nil, nil, nil);
//            [previewImages addObject:previewImage];
//        }
//        for (UIView *view in self.imageView.subviews) {
//            [view removeFromSuperview];
//        }
//        
//        NSLog(@"%@ : preview images count: %d", NSStringFromSelector(_cmd), previewImages.count);
//        
//        int dx = 0, dy = 0;
//        for (int i = 0; i < self.imagesCount; i++) {
//            int width, height;
//            switch (self.imagesCount) {
//                case 1:
//                    width = self.imageView.frame.size.width;
//                    height = self.imageView.frame.size.height;
//                    break;
//                case 2:
//                    width = self.imageView.frame.size.width;
//                    height = self.imageView.frame.size.height / 2;                    
//                    break;
//            }
//            UIImageView *previewImageView = [[UIImageView alloc] initWithFrame:CGRectMake(dx, dy, width, height)];
//            NSLog(@"%@ previewImageViewFrame: %@", NSStringFromSelector(_cmd), NSStringFromCGRect(previewImageView.frame));
//            previewImageView.contentMode = UIViewContentModeScaleAspectFill;
//            dy += previewImageView.frame.size.height + 8;
//            previewImageView.image = [previewImages objectAtIndex:i];
//            [self.imageView addSubview:previewImageView];
//        }    
//        //
        
        int dx = self.imageView.frame.origin.x, dy = self.imageView.frame.origin.y;
        int sy = 8, sx = 8;
        for (int i = 0; i < self.imagesCount; i++) 
        {
            UIImageView *iv = [self.imageViews objectAtIndex:i];
            iv.hidden = NO;
            iv.userInteractionEnabled = NO;
            int width, height;
            switch (self.imagesCount) {
                case 1:
                    width = self.imageView.frame.size.width;
                    height = self.imageView.frame.size.height;
                    break;
                case 2:
                    width = self.imageView.frame.size.width;
                    height = (self.imageView.frame.size.height - sy) / 2;                    
                    break;
                case 3:
                    if (i > 0) width = (self.imageView.frame.size.width - sx) / 2;
                    else width = self.imageView.frame.size.width;
                    height = (self.imageView.frame.size.height - sy) / 2;                                          
                    break;
                case 4:
                    width = (self.imageView.frame.size.width - sx) / 2;
                    height = (self.imageView.frame.size.height - sy) / 2;
                    break;
            }
            iv.frame = CGRectMake(dx, dy, width, height);
            switch (self.imagesCount) {
                case 1:
                    break;
                case 2:
                    dy += height + sy;
                    break;
                case 3:
                    if (!i)  dy += height + sy;
                    if (i > 0) dx += width + sx;
                    break;
                case 4:
                    if (i == 1) dy += height + sy;                    
                    if (i == 1) dx -= sx;
                    if (i == 0 || i == 2) dx += width + sx;                    
                    else dx -= width;
                    break;
            }
        }        
    }
    else {
        self.isPreviewing = NO;
        [self updateUI];
        for (UIImageView *iv in self.imageViews) {
            iv.frame = self.imageView.frame;
            iv.hidden = YES;
            iv.userInteractionEnabled = YES;
        }
        self.currentImageView.hidden = NO;
    }
}

- (IBAction)onEditingSwitchValueChange:(id)sender {
    self.isEditing = !self.isEditing;
//    if (self.isEditing) {
//        //self.faceButton.enabled = YES;
//        //self.photoButton.enabled = YES;
//        //self.textButton.enabled = YES;
//    }
//    else {
//        //self.faceButton.enabled = NO;
//        self.photoButton.enabled = NO;
//        self.textButton.enabled = NO;
//    }
}

- (void)updateUI {
    //self.title = [NSString stringWithFormat:@"%d / %d", self.currentImage + 1, self.imagesCount];
    //UIImage *image = (self.currentImage < self.imagesCount - 1) ? [UIImage imageNamed:@"next_button.png"] : [UIImage imageNamed:@"save_button.png"];
    //[self.nextButton setImage:image forState:UIControlStateNormal];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
//    if ([actionSheet isEqual:self.addRageSheet]) {
//        switch (buttonIndex) {
//            case 0:
//            {
//                UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"trollface-hello-kitty.png"]];
//                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
//                    image.transform = CGAffineTransformMakeScale(0.5, 0.5);
//                }
//                image.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
//                UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(viewDragged:)];
//                [image addGestureRecognizer:gesture];
//                UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(viewPinched:)];
//                [image addGestureRecognizer:pinchGesture];
//                [image setUserInteractionEnabled:YES];
//                [self.currentImageView addSubview:image];
//                break;
//            }
//        }        
//    }
//    else 
    if ([actionSheet isEqual:self.addPhotoSheet]) {
        UIImagePickerController *imagePicker;
        switch (buttonIndex) {
            case 0:
            {
                imagePicker = [[UIImagePickerController alloc] init];
                imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                imagePicker.delegate = self;                
                break;
            }
            case 1:
            {
                imagePicker = [[UIImagePickerController alloc] init];
                imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                imagePicker.delegate = self;
                break;
            }
            default: return;
        }
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [self presentModalViewController:imagePicker animated:YES];
        }
        else {
            self.popover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
            [self.popover presentPopoverFromRect:self.photoButton.frame inView:self.navigationController.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }        
    }
}

//- (void)selectButton:(UIButton *)button {
//    //UIButton *t = self.selectedButton;
//    //[self deselectButton:nil];
//    
//    //if (![t isEqual:button]) {
//        self.selectedButton = button;
//        self.selectedButton.layer.borderWidth = 4;
//        self.selectedButton.layer.borderColor = [UIColor redColor].CGColor;
//    //}
//}
//
//- (void)deselectButton:(UIButton *)button {
//    if (self.selectedButton) {
//        self.selectedButton.layer.borderWidth = 0;
//        self.selectedButton = nil;
//    }
//}

- (void)selectView:(UIView *)view {
    [self deselectView];
    
    self.selectedView = view;
    self.selectedView.layer.borderColor = [UIColor redColor].CGColor;
    self.selectedView.layer.borderWidth = 4;
}

- (void)deselectView {
    if (self.selectedView) {
        self.selectedView.layer.borderWidth = 0;
        self.selectedView = nil;
    }
}

#pragma mark - Gestures
- (void)viewDragged:(UIPanGestureRecognizer *)gesture {
    //if (!self.isEditing) return;
    
    UIView *view = (UIView *)gesture.view;
	CGPoint translation = [gesture translationInView:view];
    
    //NSLog(@"translation = %@", NSStringFromCGPoint(translation));
    
   
    // move label
    //view.center = CGPointMake(view.center.x + translation.x, 
    //                           view.center.y + translation.y);
    view.transform = CGAffineTransformTranslate(view.transform, translation.x, translation.y);
    
    // reset translation
    [gesture setTranslation:CGPointZero inView:view];
    
    //self.isGesture = NO;
}

- (void)viewPinched:(UIPinchGestureRecognizer *)gesture {     
     {
    
        NSLog(@"%@", NSStringFromSelector(_cmd));
        UIView *view = (UIView *)[gesture view];
        
        //self.isGesture = YES;

//        CGRect frame = view.frame;
//        if (![view isKindOfClass:[UITextView class]]) {
//            frame.size.width *= gesture.scale;
//        }    
//        frame.size.height *= gesture.scale;
//        view.frame = frame;
        
        
        view.transform = CGAffineTransformScale(view.transform, gesture.scale, gesture.scale);
        
        [gesture setScale:1.0f];
        //self.isGesture = NO;    
    }
}

- (void)viewRotated:(UIRotationGestureRecognizer *)gesture {
    NSLog(@"%@", NSStringFromSelector(_cmd));    
     {
        CGFloat angle = gesture.rotation;
        UIView *view = (UIView *)[gesture view];
        
        //CGAffineTransform tr = CGAffineTransformRotate(view.transform, rotation);
        //view.transform = tr
        
        //CGAffineTransform affineTransform = CGAffineTransformRotate(view.transform, angle);
        //view.transform = affineTransform;
        view.layer.transform = CATransform3DRotate(view.layer.transform, angle, 0, 0, 1);
        
        [gesture setRotation:0];
        //self.isGesture = NO;
    }
}

//- (void)viewTapped:(UITapGestureRecognizer *)gesture {
//    UIView *view = gesture.view;
//    [self selectView:view];
//}

#pragma mark - UIImagePickerViewControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self dismissModalViewControllerAnimated:YES];
    }
    else {
        [self.popover dismissPopoverAnimated:YES];
    }
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    btn.adjustsImageWhenHighlighted = NO;
    
    [btn setImage:image forState:UIControlStateNormal];
    
    //UIImageView *imageView_ = [[UIImageView alloc] initWithFrame:self.imageView.bounds];
    //imageView_.image = image;
    //imageView_.contentMode = UIViewContentModeScaleToFill;
    //[imageView_ setUserInteractionEnabled:YES];

    //[self.currentImageView addSubview:imageView_];
    
    UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(viewRotated:)];
    //[imageView_ addGestureRecognizer:rotationGesture];
    [btn addGestureRecognizer:rotationGesture];
    rotationGesture.delegate = self;
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(viewPinched:)];
    //[imageView_ addGestureRecognizer:pinchGesture];
    [btn addGestureRecognizer:pinchGesture];
    pinchGesture.delegate = self;
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(viewDragged:)];
    //[imageView_ addGestureRecognizer:panGestureRecognizer];
    [btn addGestureRecognizer:panGestureRecognizer];
    panGestureRecognizer.delegate = self;
    
    [btn addTarget:self action:@selector(onButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
    
    [self.currentImageView addSubview:btn];
    
    // Быдлокод O_O
    [self onPreviewButtonClick:nil];
    [self onPreviewButtonClick:nil];
    //------------------------------
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self dismissModalViewControllerAnimated:YES];
    }
    else {
        [self.popover dismissPopoverAnimated:YES];
    }
}

#pragma mark - UITextFieldDelegate
//- (void)onTextFieldDidEndOnExit:(id)sender {
//    UITextField *textField = (UITextField *)sender;
//    [textField resignFirstResponder];
//}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    textView.layer.borderWidth = 1;
    textView.layer.borderColor = [UIColor redColor].CGColor;
    
    //[KeyboardListener setScrollView:self.currentImageView];
    //[KeyboardListener setActiveView:textView];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    textView.layer.borderWidth = 0;
    
    [KeyboardListener setScrollView:nil];
    [KeyboardListener setActiveView:nil];
}

#pragma mark - UIResponder
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self deselectView];
    //self.trollfacePicker.hidden = YES;
    
    if (self.editing) {
        //if (self.isGesture) return;
        
        //self.mouseSwiped = NO;
        UITouch *touch = touches.anyObject;
        CGPoint touchLocation = [touch locationInView:self.currentImageView];
        self.lastPoint = touchLocation;
        
        //NSLog(@"%@ subviews count = %d", NSStringFromSelector(_cmd), self.currentImageView.subviews.count);
        
        //[self deselectButton:nil];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.isEditing) return;
    
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self.currentImageView];
    
    //if (CGPointEqualToPoint(self.lastPoint, touchLocation)) return;
    
    UIGraphicsBeginImageContext(self.currentImageView.frame.size);
    //CGSize imageSize = self.currentImageView.image.size;
    CGSize imageViewSize = self.currentImageView.frame.size;
//    int x = 0, y = 0;
//    if (imageSize.width < imageViewSize.width) {
//        x = (imageViewSize.width - imageSize.width) / 2;
//    }
//    if (imageSize.height < imageViewSize.height) {
//        y = (imageViewSize.height - imageSize.height) / 2;
//    }
    //NSLog(@"x = %d, y = %d", x, y);
    //UIImage *imageToDraw = self.currentImageView.image thumb
    [self.currentImageView.image drawInRect:CGRectMake(0, 0, imageViewSize.width, imageViewSize.height)];
    CGContextRef context = UIGraphicsGetCurrentContext();    
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, 2);
    CGContextSetStrokeColorWithColor(context, [[UIColor blackColor] CGColor]);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, self.lastPoint.x, self.lastPoint.y);
    CGContextAddLineToPoint(context, touchLocation.x, touchLocation.y);
    CGContextStrokePath(context);
    self.currentImageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.lastPoint = touchLocation;
    
    //NSLog(@"%@", NSStringFromSelector(_cmd));
}

//- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
//    if(!self.mouseSwiped) {
//        UIGraphicsBeginImageContext(self.currentImageView.frame.size);
//        [self.currentImageView.image drawInRect:CGRectMake(0, 0, self.currentImageView.frame.size.width, self.currentImageView.frame.size.height)];
//        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
//        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 5.0);
//        CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(), [[UIColor whiteColor] CGColor]);
//        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), self.lastPoint.x, self.lastPoint.y);
//        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), self.lastPoint.x, self.lastPoint.y);
//        CGContextStrokePath(UIGraphicsGetCurrentContext());
//        CGContextFlush(UIGraphicsGetCurrentContext());
//        self.currentImageView.image = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//    }
//}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [Trollface all].count;
}

#pragma mark - UIPickerViewDelegate
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 60;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UIImage *image = [[[Trollface all] objectAtIndex:row] thumbnailByScalingProportionallyAndCroppingToSize:CGSizeMake(60, 50)];
    UIImageView *iv = [[UIImageView alloc] initWithImage:image];
    iv.backgroundColor = [UIColor clearColor];
    return iv;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    UIButton *btn = (UIButton *)self.selectedView;
    UIImage *image = [[Trollface all] objectAtIndex:row];
    [btn setImage:image forState:UIControlStateNormal];
    //btn.frame = CGRectMake(btn.frame.origin.x, btn.frame.origin.y, image.size.width, image.size.height);
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
//        btn.transform = CGAffineTransformMakeScale(0.5, 0.5);
//    }
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - FacePickerViewDelegate
- (void)facePickerDidPickFace:(UIImage *)face {
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    btn.adjustsImageWhenHighlighted = NO;
    btn.layer.borderColor = [UIColor redColor].CGColor;
    [btn setImage:face forState:UIControlStateNormal];
    
    btn.autoresizingMask = 
    UIViewAutoresizingFlexibleWidth | 
    UIViewAutoresizingFlexibleHeight |
    UIViewAutoresizingFlexibleBottomMargin | 
    UIViewAutoresizingFlexibleLeftMargin | 
    UIViewAutoresizingFlexibleRightMargin | 
    UIViewAutoresizingFlexibleTopMargin;
    
    btn.contentMode = UIViewContentModeScaleToFill;
    
    UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(viewDragged:)];
    [btn addGestureRecognizer:gesture];
    gesture.delegate = self;
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(viewPinched:)];
    [btn addGestureRecognizer:pinchGesture];
    pinchGesture.delegate = self;
    
    UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(viewRotated:)];
    [btn addGestureRecognizer:rotationGesture];
    rotationGesture.delegate = self;
    
    [btn addTarget:self action:@selector(onButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
    
    [btn setUserInteractionEnabled:YES];
    
    [self.currentImageView addSubview:btn];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"%d", buttonIndex);
    
    if ([alertView isEqual:self.saveAlert]) {
        switch (buttonIndex) {
            case 1:
                [self saveImageToPhotosAlbum];
                break;
            case 2:
                [self saveImageToLine];
                break;
            default: return;
        }
    }
}

@end
