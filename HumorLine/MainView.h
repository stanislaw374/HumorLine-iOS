//
//  MainView.h
//  HumorLine
//
//  Created by Yazhenskikh Stanislaw on 11.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "Vkontakte.h"
#import <RestKit/RestKit.h>

@interface MainView : UIViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, EGORefreshTableHeaderDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, VkontakteDelegate, RKObjectLoaderDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *menuButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *menu;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *menuMaximized;

- (IBAction)onAddButtonClick:(id)sender;
- (IBAction)onLoginButtonClick:(id)sender;
- (IBAction)onTop30ButtonClick:(id)sender;
- (IBAction)onMapButtonClick:(id)sender;
- (IBAction)onTrololoButtonClick:(id)sender;
- (IBAction)onPhotoButtonClick:(id)sender;
- (IBAction)onVideoButtonClick:(id)sender;
- (IBAction)onTextButtonClick:(id)sender;
- (IBAction)onMenuButtonClick:(id)sender;

@end
