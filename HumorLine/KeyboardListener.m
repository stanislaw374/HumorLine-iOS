//
//  KeyboardNotifications.m
//  buhg
//
//  Created by Yazhenskikh Stanislaw on 20.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "KeyboardListener.h"

//static NSMutableArray *_scrollViews = nil;
static UIScrollView *_scrollView = nil;
static UIView *_activeView = nil;

@implementation KeyboardListener
//@synthesize activeView = _activeView;
//@synthesize scrollView = _scrollView;

+ (void)initialize {
    //_scrollViews = [[NSMutableArray alloc] init];
    [self registerForKeyboardNotifications];
}

+ (void)setScrollView:(UIScrollView *)scrollView {
    __unsafe_unretained UIScrollView *weakScrollView = scrollView;
    //[_scrollViews addObject:weakScrollView];
    _scrollView = weakScrollView;
}

+ (void)unsetScrollView {
    _scrollView = nil;
}

+ (void)setActiveView:(UIView *)view {
    __unsafe_unretained UIView *weakView = view;
    _activeView = weakView;
}

+ (void)unsetActiveView {
    _activeView = nil;
}

//-(id)init {
//    return [self initWithScrollView:nil];
//}

//-(id)initWithScrollView:(UIScrollView *)scrollView {
//    self = [super init];
//    if (self) {
//        self.scrollView = scrollView;
//        [self registerForKeyboardNotifications];
//    }
//    return self;
//}

+ (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

+ (void)unregisterForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// Called when the UIKeyboardDidShowNotification is sent.
+ (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    
    //for (UIScrollView *scrollView in _scrollViews) {
        _scrollView.contentInset = contentInsets;
        _scrollView.scrollIndicatorInsets = contentInsets;
        
        // If active text field is hidden by keyboard, scroll it so it's visible
        // Your application might not need or want this behavior.
        CGRect aRect = _scrollView.frame;
        aRect.size.height -= kbSize.height;
        if (!CGRectContainsRect(aRect, _activeView.frame)) { //!CGRectContainsPoint(aRect, self.activeControl.frame.origin
            CGPoint scrollPoint = CGPointMake(0.0, _activeView.frame.origin.y + _activeView.frame.size.height - kbSize.height);
            [_scrollView setContentOffset:scrollPoint animated:YES];
        }
    //}
}

// Called when the UIKeyboardWillHideNotification is sent
+ (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    _scrollView.contentInset = contentInsets;
    _scrollView.scrollIndicatorInsets = contentInsets;
}

//- (void)dealloc {
//    [self unregisterForKeyboardNotifications];
//}

@end
