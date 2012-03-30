//
//  FaceView.h
//  HumorLine
//
//  Created by Yazhenskikh Stanislaw on 30.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FacePickerViewDelegate <NSObject>
- (void)facePickerDidPickFace:(UIImage *)face;
@end

@interface FacePickerView : UIViewController
@property (unsafe_unretained, nonatomic) id<FacePickerViewDelegate> delegate;
@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *scrollView;
@end

