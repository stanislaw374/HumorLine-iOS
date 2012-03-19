//
//  TrololoView.m
//  HumorLine
//
//  Created by Yazhenskikh Stanislaw on 13.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TrololoView.h"
//#import "Picture.h"

@interface TrololoView()
@property (nonatomic) int currentImage;
@property (nonatomic, strong) UIActionSheet *addRageSheet;
@property (nonatomic, strong) UIActionSheet *addPhotoSheet;
@property (nonatomic, unsafe_unretained) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, strong) UIPopoverController *popover;
@property (nonatomic, strong) NSMutableArray *imageViews;
@property (nonatomic, strong) UIImageView *currentImageView;
@property (nonatomic) BOOL isPreviewing;
@property (nonatomic) CGPoint lastPoint;
@property (nonatomic) BOOL mouseSwiped;
@property (nonatomic) BOOL isGesture;
- (void)updateUI;
- (void)viewDragged:(UIPanGestureRecognizer *)gesture;
- (void)viewPinched:(UIPinchGestureRecognizer *)gesture;
- (void)onTextFieldDidEndOnExit:(id)sender;
- (void)saveImage;
- (void)image: (UIImage *) image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
@end

@implementation TrololoView
@synthesize imageView;
@synthesize imagesCount = _imagesCount;
@synthesize faceButton = _faceButton;
@synthesize photoButton = _photoButton;
@synthesize nextButton = _nextButton;
@synthesize nextItem = _nextItem;
@synthesize currentImage = _currentImage;
@synthesize addRageSheet = _addRageSheet;
@synthesize addPhotoSheet = _addPhotoSheet;
@synthesize panGestureRecognizer = _panGestureRecognizer;
@synthesize popover = _popover;
@synthesize imageViews = _imageViews;
@synthesize currentImageView = _currentImageView;
@synthesize isPreviewing = _isPreviewing;
@synthesize lastPoint = _lastPoint;
@synthesize mouseSwiped = _mouseSwiped;
@synthesize isGesture = _isGesture;

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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateUI];
    
    NSLog(@"%@ : imageView.frame = %@", NSStringFromSelector(_cmd), NSStringFromCGRect(self.imageView.frame));
    
    for (int i = 0; i < self.imagesCount; i++) {
        UIImageView *iv = [[UIImageView alloc] initWithFrame:self.imageView.frame];
        iv.autoresizingMask = self.imageView.autoresizingMask;
        iv.userInteractionEnabled = YES;
        iv.contentMode = UIViewContentModeScaleAspectFit;
        iv.backgroundColor = [UIColor whiteColor];
        if (i) iv.hidden = YES;
        [self.imageViews addObject:iv];
        [self.view addSubview:iv];
    }
    self.currentImageView = [self.imageViews objectAtIndex:self.currentImage];
}

- (void)viewDidUnload
{
    [self setImageView:nil];
    [self setNextButton:nil];
    [self setNextItem:nil];
    [self setFaceButton:nil];
    [self setPhotoButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)onRageButtonClick:(id)sender {
    [self.addRageSheet showInView:self.navigationController.view];
}

- (IBAction)onPhotoButtonClick:(id)sender {
    [self.addPhotoSheet showInView:self.navigationController.view];
}

- (IBAction)onTextButtonClick:(id)sender {
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, self.imageView.frame.size.width, 50)];
    textField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    textField.placeholder = @"Текст";
    textField.font = [UIFont boldSystemFontOfSize:36];
    textField.textColor = [UIColor blackColor];
    UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(viewDragged:)];
    [textField addGestureRecognizer:gesture];
    textField.backgroundColor = [UIColor clearColor];
    [textField addTarget:self action:@selector(onTextFieldDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.currentImageView addSubview:textField];
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
        ((UIView *)[self.imageViews objectAtIndex:self.currentImage]).hidden = YES;
        self.currentImage++;
        ((UIImageView *)[self.imageViews objectAtIndex:self.currentImage]).hidden = NO;
        [self.imageViews objectAtIndex:self.currentImage];        
        self.currentImageView = [self.imageViews objectAtIndex:self.currentImage];
        [self updateUI];
    }
    else {
        if (!self.isPreviewing) [self onPreviewButtonClick:nil];
        [self saveImage];
    }
}

- (void)saveImage {
    //NSLog(@"%@ : imageContextSize : %@", NSStringFromSelector(_cmd), NSStringFromCGSize(self.imageView.frame.size));
          
    UIGraphicsBeginImageContext(self.imageView.frame.size);
    //CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), [[UIColor blackColor] CGColor]);
    //CGContextClearRect(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, self.imageView.frame.size.width, self.imageView.frame.size.height));
    for (UIImageView *iv in self.imageViews) {
        [iv.image drawInRect:CGRectMake(iv.frame.origin.x - self.imageView.frame.origin.x, iv.frame.origin.y - self.imageView.frame.origin.y, iv.frame.size.width, iv.frame.size.height)];
    }
    UIImage *imageToSave = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageWriteToSavedPhotosAlbum(imageToSave, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSString *message = error ? @"Ошибка при сохранении изображения" : @"Изображение сохранено в фотогаллерее";
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    
    if (!error) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)onPreviewButtonClick:(id)sender {
    if (!self.isPreviewing) {
        self.isPreviewing = YES;
        //self.imageView.hidden = NO;
        //self.currentImageView.hidden = YES;
        self.title = @"Просмотр";
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
                        height = self.imageView.frame.size.height / 2;                    
                        break;
                    case 3:
                        if (i > 0) width = self.imageView.frame.size.width / 2;
                        else width = self.imageView.frame.size.width;
                        height = self.imageView.frame.size.height / 2;                                          
                        break;
                    case 4:
                        width = self.imageView.frame.size.width / 2;
                        height = self.imageView.frame.size.height / 2;
                        break;
                }
                iv.frame = CGRectMake(dx, dy, width, height);
                switch (self.imagesCount) {
                    case 1:
                        break;
                    case 2:
                        dy += height + 8;
                        break;
                    case 3:
                        if (!i)  dy += height + 8;
                        if (i > 0) dx += width + 8;
                        break;
                    case 4:
                        if (i == 1) dy += height + 8;
                        if (!i || i == 2) dx += width + 8;
                        else dx -= width - 8;
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

- (void)updateUI {
    self.title = [NSString stringWithFormat:@"%d / %d", self.currentImage + 1, self.imagesCount];
    NSString *text;
    if (self.currentImage < self.imagesCount - 1) {
        text = [NSString stringWithFormat:@"Далее %d/%d", self.currentImage + 2, self.imagesCount];
    }
    else {
        text = @"Сохранить";
    }
    [self.nextButton setTitle:text forState:UIControlStateNormal];
    self.nextItem.title = text;
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([actionSheet isEqual:self.addRageSheet]) {
        switch (buttonIndex) {
            case 0:
            {
                UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"trollface-hello-kitty.png"]];
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                    image.transform = CGAffineTransformMakeScale(0.5, 0.5);
                }
                image.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
                UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(viewDragged:)];
                [image addGestureRecognizer:gesture];
                UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(viewPinched:)];
                [image addGestureRecognizer:pinchGesture];
                [image setUserInteractionEnabled:YES];
                [self.currentImageView addSubview:image];
                break;
            }
        }        
    }
    else if ([actionSheet isEqual:self.addPhotoSheet]) {
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

- (void)viewDragged:(UIPanGestureRecognizer *)gesture {
    self.isGesture = YES;
    
    UIView *view = (UIView *)gesture.view;
	CGPoint translation = [gesture translationInView:view];
    
	// move label
	view.center = CGPointMake(view.center.x + translation.x, 
                               view.center.y + translation.y);
    
	// reset translation
	[gesture setTranslation:CGPointZero inView:view];
    
    self.isGesture = NO;
}

- (void)viewPinched:(UIPinchGestureRecognizer *)gesture {     
    self.isGesture = YES;
    UIView *view = (UIView *)gesture.view;
    CGAffineTransform transform = CGAffineTransformMakeScale(gesture.scale, gesture.scale);
    view.transform = transform;
    self.isGesture = NO;
}

#pragma mark - UIImagePickerViewControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self dismissModalViewControllerAnimated:YES];
    }
    else {
        [self.popover dismissPopoverAnimated:YES];
    }
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    self.currentImageView.image = image;
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
- (void)onTextFieldDidEndOnExit:(id)sender {
    UITextField *textField = (UITextField *)sender;
    [textField resignFirstResponder];
}

#pragma mark - UIResponder
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.isGesture) return;
    
    //self.mouseSwiped = NO;
    UITouch *touch = touches.anyObject;
    CGPoint touchLocation = [touch locationInView:self.currentImageView];
    self.lastPoint = touchLocation;
    
    //NSLog(@"%@ subviews count = %d", NSStringFromSelector(_cmd), self.currentImageView.subviews.count);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.isGesture) return;
    
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self.currentImageView];
    
    //if (CGPointEqualToPoint(self.lastPoint, touchLocation)) return;
    
    UIGraphicsBeginImageContext(self.currentImageView.frame.size);
    CGSize imageSize = self.currentImageView.image.size;
    CGSize imageViewSize = self.currentImageView.frame.size;
    int x = 0, y = 0;
    if (imageSize.width < imageViewSize.width) {
        x = (imageViewSize.width - imageSize.width) / 2;
    }
    if (imageSize.height < imageViewSize.height) {
        y = (imageViewSize.height - imageSize.height) / 2;
    }
    NSLog(@"x = %d, y = %d", x, y);
    [self.currentImageView.image drawInRect:CGRectMake(x, y, imageSize.width, imageSize.height)];
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

@end
