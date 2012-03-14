//
//  AddCommentView.m
//  HumorLine
//
//  Created by Yazhenskikh Stanislaw on 12.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AddCommentView.h"
#import "MainMenu.h"
#import "Constants.h"
#import "UIImageView+WebCache.h"

@interface AddCommentView()
@property (nonatomic, strong) MainMenu *mainMenu;
@end

@implementation AddCommentView
@synthesize imageView = _imageView;
@synthesize textView = _textView;
@synthesize lblWordsCount = _lblWordsCount;
@synthesize mainMenu = _mainMenu;
@synthesize currentPicture = _currentPicture;

- (MainMenu *)mainMenu {
    if (!_mainMenu) {
        _mainMenu = [[MainMenu alloc] initWithViewController:self];
    }
    return _mainMenu;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Добавить коммент";
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
    [self.mainMenu addLoginButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //[self.imageView setImageWithURL:kIMAGEURL];
    [self.imageView setImageWithURL:self.currentPicture.url];
}

- (void)viewDidUnload
{
    [self setImageView:nil];
    [self setTextView:nil];
    [self setLblWordsCount:nil];
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
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Ваш комментарий добавлен" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onCancelButtonClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextViewDelegate
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
