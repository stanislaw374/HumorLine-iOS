//
//  TrololoView.m
//  HumorLine
//
//  Created by Yazhenskikh Stanislaw on 13.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TrololoView.h"
#import "Picture.h"

@interface TrololoView()
@property (nonatomic) int currentImage;
@property (nonatomic, strong) UIActionSheet *addRageSheet;
@property (nonatomic, strong) UIActionSheet *addPhotoSheet;
@property (nonatomic, unsafe_unretained) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, strong) UIPopoverController *popover;
@property (nonatomic, strong) NSMutableArray *imageViews;
@property (nonatomic, strong) UIImageView *currentImageView;
@property (nonatomic) BOOL isPreviewing;
- (void)updateUI;
- (void)viewDragged:(UIPanGestureRecognizer *)gesture;
- (void)viewPinched:(UIPinchGestureRecognizer *)gesture;
- (void)onTextFieldDidEndOnExit:(id)sender;
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

- (UIPanGestureRecognizer *)panGestureRecognizer {
    return [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(viewDragged:)];
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
    textField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    textField.placeholder = @"Текст";
    textField.font = [UIFont boldSystemFontOfSize:32];
    textField.textColor = [UIColor whiteColor];
    [textField addGestureRecognizer:self.panGestureRecognizer];
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Комикс добавлен" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
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
        
            int dx = 0, dy = 0;
            for (int i = 0; i < self.imagesCount; i++) 
            {
                UIImageView *iv = [self.imageViews objectAtIndex:i];
                iv.hidden = NO;
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
        //self.imageView.hidden = YES;
        //self.currentImageView.hidden = NO;
        [self updateUI];
        for (UIImageView *iv in self.imageViews) {
            iv.frame = self.imageView.frame;
            iv.hidden = YES;
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
    if ([self.addRageSheet isEqual:actionSheet]) {
        switch (buttonIndex) {
            case 0:
            {
                UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"trollface-hello-kitty.png"]];
                image.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
                [image addGestureRecognizer:self.panGestureRecognizer];
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
    //NSLog(@"%@", NSStringFromSelector(_cmd));
    
    UIView *view = (UIView *)gesture.view;
	CGPoint translation = [gesture translationInView:view];
    
	// move label
	view.center = CGPointMake(view.center.x + translation.x, 
                               view.center.y + translation.y);
    
	// reset translation
	[gesture setTranslation:CGPointZero inView:view];
}

- (void)viewPinched:(UIPinchGestureRecognizer *)gesture {
    //NSLog(@"%@", NSStringFromSelector(_cmd));
    
    UIView *view = (UIView *)gesture.view;
    CGAffineTransform transform = CGAffineTransformMakeScale(gesture.scale, gesture.scale);
    view.transform = transform;
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

#pragma mark -

- (void)onTextFieldDidEndOnExit:(id)sender {
    UITextField *textField = (UITextField *)sender;
    [textField resignFirstResponder];
}

@end
