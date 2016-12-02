//
//  CKCommonGroupsView.h
//  click
//
//  Created by Anatoly Mityaev on 02.12.16.
//  Copyright © 2016 Click. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CKCommonGroupsView : UITableViewController< UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign) NSArray *commonGroups;

@end
