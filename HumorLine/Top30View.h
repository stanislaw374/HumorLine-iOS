//
//  Top30View.h
//  HumorLine
//
//  Created by Yazhenskikh Stanislaw on 20.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import <RestKit/RestKit.h>
#import "Post.h"

@interface Top30View : UIViewController <UITableViewDataSource, UITableViewDelegate, EGORefreshTableHeaderDelegate, UIScrollViewDelegate, RKObjectLoaderDelegate, PostDelegate>
@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)onMapButtonClick:(id)sender;
- (IBAction)onAddButtonClick:(id)sender;
- (IBAction)onNewButtonClick:(id)sender;

@end
