//  Created by Дрягин Павел on 18.11.16.
//  Copyright © 2016 Click. All rights reserved.

#import "utilities.h"

@protocol SelectMultipleDelegate

- (void)didSelectMultipleUsers:(NSMutableArray *)users;

@end

@interface SelectMultipleView : UIViewController <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) IBOutlet id<SelectMultipleDelegate>delegate;

@end
