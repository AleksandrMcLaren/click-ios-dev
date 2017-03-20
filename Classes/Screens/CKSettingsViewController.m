//
//  CKSettingsViewController.m
//  click
//
//  Created by Igor Tetyuev on 21.03.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKSettingsViewController.h"
#import "CKUserProfileController.h"

@interface CKSettingsViewController ()

@property (nonatomic, strong) CKUserProfileController * profileVC;

@end

@implementation CKSettingsViewController

- (instancetype)init
{
    if (self = [super init])
    {
        self.profileVC = [[CKUserProfileController alloc] init];
        self.title = @"Профиль";
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addChildViewController:self.profileVC];
    [self.view addSubview:self.profileVC.view];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.profileVC.profile = [CKUser currentUser];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGSize boundsSize = self.view.bounds.size;
    self.profileVC.view.frame = CGRectMake(0, 0, boundsSize.width, boundsSize.height - 50);
}

@end
