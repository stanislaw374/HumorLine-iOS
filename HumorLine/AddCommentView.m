//
//  AddCommentView.m
//  HumorLine
//
//  Created by Yazhenskikh Stanislaw on 12.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AddCommentView.h"
//#import "MainMenu.h"
#import "Constants.h"
#import "UIImageView+WebCache.h"
#import "Comment.h"
#import "AppDelegate.h"
#import "Image.h"
#import <MediaPlayer/MediaPlayer.h>

static NSString *kTEXTVIEW_PLACEHOLDER = @"Введите комментарий";

@interface AddCommentView()
//@property (nonatomic, strong) MainMenu *mainMenu;
@property (nonatomic, strong) MPMoviePlayerController *player;
@end

@implementation AddCommentView
//@synthesize imageView = _imageView;
@synthesize textView = _textView;
@synthesize lblWordsCount = _lblWordsCount;
@synthesize contentView = _contentView;
//@synthesize mainMenu = _mainMenu;
//@synthesize currentPicture = _currentPicture;
@synthesize post = _post;
@synthesize player = _player;

//- (MainMenu *)mainMenu {
//    if (!_mainMenu) {
//        _mainMenu = [[MainMenu alloc] initWithViewController:self];
//    }
//    return _mainMenu;
//}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //self.title = @"Добавить коммент";
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
    //[self.mainMenu addLoginButton];
    
    switch (self.post.type) {
        case kPostTypePhoto:
        {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:self.post.image.image];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView.frame = CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height);        
            imageView.autoresizingMask = self.contentView.autoresizingMask;
            //NSLog(@"imageView frame = %@", NSStringFromCGRect(imageView.frame));
            [self.contentView addSubview:imageView];
            break;
        }
        case kPostTypeVideo:
        {
            self.player = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:self.post.videoURL]];
            self.player.shouldAutoplay = NO;
            self.player.scalingMode = MPMovieScalingModeAspectFit;
            self.player.view.frame = CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height);
            self.player.view.autoresizingMask = self.contentView.autoresizingMask;            
            [self.contentView addSubview:self.player.view];
            break;
        }
        case kPostTypeText:
        {
            UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height)];
            lbl.numberOfLines = 0;
            lbl.lineBreakMode = UILineBreakModeWordWrap;
            lbl.text = self.post.text;
            lbl.autoresizingMask = self.contentView.autoresizingMask;
            lbl.backgroundColor = [UIColor clearColor];
            lbl.textAlignment = UITextAlignmentCenter;
            lbl.font = [UIFont boldSystemFontOfSize:24];
            lbl.textColor = [UIColor whiteColor];
            [self.contentView addSubview:lbl];
            break;
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //[self.imageView setImageWithURL:kIMAGEURL];
    //[self.imageView setImageWithURL:self.currentPicture.url];
}

- (void)viewDidUnload
{
    //[self setImageView:nil];
    [self setTextView:nil];
    [self setLblWordsCount:nil];
    [self setContentView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)onAddButtonClick:(id)sender {
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    Comment *newComment = [NSEntityDescription insertNewObjectForEntityForName:@"Comment" inManagedObjectContext:appDelegate.managedObjectContext];
    newComment.date = [NSDate date];
    newComment.text = self.textView.text;
    
    [self.post addCommentsObject:newComment];
    
    NSError *error;
    [appDelegate.managedObjectContext save:&error];
    if (error) {
        NSLog(@"Error saving : %@", error.localizedDescription);
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Ваш комментарий добавлен" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    
    [self.presentingViewController dismissModalViewControllerAnimated:YES];
}

- (IBAction)onCancelButtonClick:(id)sender {
    [self.presentingViewController dismissModalViewControllerAnimated:YES];
}

#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:kTEXTVIEW_PLACEHOLDER]) {
        textView.text = @"";
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    //NSLog(@"%@", NSStringFromSelector(_cmd));
    
    int count = textView.text.length;
    self.lblWordsCount.text = [NSString stringWithFormat:@"%d / 300", count];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    else return YES;
}

@end
