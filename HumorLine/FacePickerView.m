//
//  FaceView.m
//  HumorLine
//
//  Created by Yazhenskikh Stanislaw on 30.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FacePickerView.h"
#import "Trollface.h"

@interface FacePickerView()
- (void)initUI;
- (void)onCancelButtonClick;
- (void)onFaceButtonClick:(UIButton *)sender;
@end

@implementation FacePickerView
@synthesize scrollView;
@synthesize delegate = _delegate;

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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self initUI];
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)initUI {
    NSArray *faces = [Trollface all];
    int w = 60, h = 60;
    int sx = 8, sy = 8;
    int row = 0, column = 0;
    for (int i = 0; i < faces.count; i++) {
        UIImage *face = [faces objectAtIndex:i];
        UIButton *faceButton = [[UIButton alloc] initWithFrame:CGRectMake(column * (w + sx), row * (h + sy), w, h)];
        [faceButton setImage:face forState:UIControlStateNormal];
        [faceButton addTarget:self action:@selector(onFaceButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:faceButton];
        
        if (++column == 4) {
            row++;
            column = 0;
        }
    }
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, row * (h + sy));
}

- (void)onCancelButtonClick {
    [self.presentingViewController dismissModalViewControllerAnimated:YES];
}

- (void)onFaceButtonClick:(UIButton *)sender {
    [self.presentingViewController dismissModalViewControllerAnimated:YES];
    
    UIImage *face = sender.currentImage;
    if ([self.delegate respondsToSelector:@selector(facePickerDidPickFace:)]) {
        [self.delegate performSelector:@selector(facePickerDidPickFace:) withObject:face];
    }
}

@end
