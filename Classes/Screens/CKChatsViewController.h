//
//  CKChatsViewController.h
//  click
//
//  Created by Igor Tetyuev on 21.03.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectSingleView.h"
#import "SelectMultipleView.h"

@interface CKChatsViewController : UIViewController< UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

+ (UIImage *)imageFromColor:(UIColor *)color;

@end
