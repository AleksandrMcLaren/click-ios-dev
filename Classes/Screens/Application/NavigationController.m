//  Created by Дрягин Павел on 18.11.16.
//  Copyright © 2016 Click. All rights reserved.


#import "NavigationController.h"

@implementation NavigationController

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.navigationBar.translucent = NO;
	self.navigationBar.barTintColor = HEXCOLOR(0x7FBB00FF);
	self.navigationBar.tintColor = [UIColor whiteColor];
	self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
	return UIStatusBarStyleLightContent;
}

@end

