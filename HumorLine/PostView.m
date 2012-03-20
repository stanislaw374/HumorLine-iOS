//
//  PostView.m
//  HumorLine
//
//  Created by Yazhenskikh Stanislaw on 19.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PostView.h"
#import "Image.h"
#import <MediaPlayer/MediaPlayer.h>

@interface PostView()
@property (nonatomic, strong) MPMoviePlayerController *player;
@end

@implementation PostView
@synthesize post = _post;
@synthesize player = _player;

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
    
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    switch (self.post.type) {
        case kPostTypePhoto:
        {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:self.post.image.image];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
            //imageView.userInteractionEnabled = NO;
            imageView.autoresizingMask = self.view.autoresizingMask;
            //NSLog(@"imageView frame = %@", NSStringFromCGRect(imageView.frame));
            [self.view addSubview:imageView];
            break;
        }
        case kPostTypeVideo:
        {
            self.player = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:self.post.videoURL]];
            self.player.shouldAutoplay = NO;
            self.player.scalingMode = MPMovieScalingModeAspectFit;
            self.player.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
            self.player.view.autoresizingMask = self.view.autoresizingMask;
            
            [self.view addSubview:self.player.view];
            break;
        }
        case kPostTypeText:
        {
            UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
            lbl.numberOfLines = 0;
            lbl.lineBreakMode = UILineBreakModeWordWrap;
            lbl.text = self.post.text;
            lbl.autoresizingMask = self.view.autoresizingMask;
            lbl.backgroundColor = [UIColor clearColor];
            lbl.textAlignment = UITextAlignmentCenter;
            lbl.font = [UIFont boldSystemFontOfSize:24];
            lbl.textColor = [UIColor whiteColor];
            [self.view addSubview:lbl];
            break;
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSLog(@"%@", NSStringFromSelector(_cmd));
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

@end
