//  Created by Дрягин Павел on 18.11.16.
//  Copyright © 2016 Click. All rights reserved.

#import "utilities.h"

@protocol SelectSingleDelegate

- (void)didSelectSingleUser:(CKUserModel *)user;

@end

@interface SelectSingleView : UIViewController <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) IBOutlet id<SelectSingleDelegate>delegate;

@end

