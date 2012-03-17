//
//  MainView.h
//  HumorLine
//
//  Created by Yazhenskikh Stanislaw on 11.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"

@interface MainView : UIViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, EGORefreshTableHeaderDelegate>
@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;

@end
