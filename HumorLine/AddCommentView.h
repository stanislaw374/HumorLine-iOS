//
//  AddCommentView.h
//  HumorLine
//
//  Created by Yazhenskikh Stanislaw on 12.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"

@interface AddCommentView : UIViewController <UITextViewDelegate>
@property (unsafe_unretained, nonatomic) Post *post;
@property (unsafe_unretained, nonatomic) IBOutlet UITextView *textView;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *lblWordsCount;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *contentView;
- (IBAction)onAddButtonClick:(id)sender;
- (IBAction)onCancelButtonClick:(id)sender;

@end
