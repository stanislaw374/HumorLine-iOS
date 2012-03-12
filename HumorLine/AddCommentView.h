//
//  AddCommentView.h
//  HumorLine
//
//  Created by Yazhenskikh Stanislaw on 12.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddCommentView : UIViewController <UITextViewDelegate>
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *imageView;
@property (unsafe_unretained, nonatomic) IBOutlet UITextView *textView;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *lblWordsCount;
- (IBAction)onAddButtonClick:(id)sender;
- (IBAction)onCancelButtonClick:(id)sender;

@end
