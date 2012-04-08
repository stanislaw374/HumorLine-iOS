//
//  MainView.h
//  HumorLine
//
//  Created by Yazhenskikh Stanislaw on 11.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import <RestKit/RestKit.h>

@interface MainView : UIViewController <UITableViewDataSource, UITableViewDelegate, EGORefreshTableHeaderDelegate, RKObjectLoaderDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)onAddButtonClick:(id)sender;
- (IBAction)onTop30ButtonClick:(id)sender;
- (IBAction)onMapButtonClick:(id)sender;

@end
