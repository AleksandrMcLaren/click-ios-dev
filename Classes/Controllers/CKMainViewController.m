//
//  CKMainViewController.m
//  click
//
//  Created by Igor Tetyuev on 09.03.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKMainViewController.h"
#import "CKWelcomeViewController.h"
#import "CKLoginViewController.h"
#import "CKHistoryRestoreController.h"
#import "CKUserProfileController.h"
#import "CKChatsViewController.h"
#import "CKContactsViewController.h"
#import "CKMapViewController.h"
#import "CKBlogViewController.h"
#import "CKSettingsViewController.h"
#import "CKLoginCodeViewController.h"

@implementation CKMainViewController
{
    UIViewController *_currentController;
    UITabBarController *_tabBarController;
    CKChatsViewController *_chatsViewController;
}

- (void)replaceCurrentController:(UIViewController *)newController
{
    if (_currentController)
    {
        [_currentController removeFromParentViewController];
        [_currentController.view removeFromSuperview];
        _currentController = nil;
    }
    _currentController = newController;
    [self.view addSubview:_currentController.view];
    [_currentController.view makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(self.view);
        make.left.equalTo(@0);
        make.top.equalTo(@0);
    }];
    [self addChildViewController:_currentController];
}

- (void) showWelcomeScreen
{
    [self replaceCurrentController:[CKWelcomeViewController new]];
}

- (void) showLoginScreen
{
    CKLoginViewController *rootController = [CKLoginViewController new];
    UINavigationController *loginNavigation = [[UINavigationController alloc] initWithRootViewController:rootController];
    [self replaceCurrentController:loginNavigation];
}

- (void) showAuthenticationScreen
{
    if ([_currentController isKindOfClass:[UINavigationController class]])  {
        UINavigationController* navigationController = (UINavigationController*)_currentController;
        if (![navigationController.topViewController isKindOfClass:[CKLoginCodeViewController class]]) {
            CKLoginCodeViewController *ctl = [CKLoginCodeViewController new];
            [(UINavigationController *)_currentController pushViewController:ctl animated:YES];
        }
    }
}

- (id<CKDialogsControllerProtocol>)dialogsController
{
    return _chatsViewController;
}

- (void) showMainScreen
{
    _tabBarController = [UITabBarController new];
    NSArray *items = @[
                       @[@"Чаты", @"tab_messages_active", [CKChatsViewController class]],
                       @[@"Контакты", @"tab_contacts_active", [CKContactsViewController class]],
                       @[@"Карта", @"tab_map_active", [CKMapViewController class]],
                       @[@"Эфир", @"tab_air_active", [CKBlogViewController class]],
                       @[@"Настройки", @"tab_settings_active", [CKSettingsViewController class]]
                       ];
    NSInteger *n = 0;
    for (NSArray *i in items)
    {
        UIViewController *rootController = [(Class)i[2] new];
        if (n==0)
        {
            _chatsViewController = (CKChatsViewController *)rootController;
        }
        n++;
        UINavigationController *ctl = [[UINavigationController alloc] initWithRootViewController:rootController];
        ctl.tabBarItem.image = [UIImage imageNamed:i[1]];
        ctl.tabBarItem.title = i[0];
        [_tabBarController addChildViewController:ctl];
    }
    [self replaceCurrentController:_tabBarController];
}

- (void) showRestoreHistory
{
    CKHistoryRestoreController *controller = [CKHistoryRestoreController new];
    [self replaceCurrentController:controller];
}

- (void) showCreateProfile
{
    CKUserProfileController *controller = [CKUserProfileController new];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
    [self replaceCurrentController:nav];
}

-(void)showAlertWithAction:(NSString*) action result:(NSInteger) result status:(NSInteger) status completion:(void (^ __nullable)(void))completion{
//TODO: создать отдельно конвертер собщения ошибки из входных параметров, пока локально
    NSString* title = action;
    NSString* message = [NSString stringWithFormat:@"Error result:%ld status:%ld", result, (long)status];
    if ([action isEqualToString:@"getUserState"]) {
        title = @"Настройка MessMe";
        message = @"Убедитесь в правильности введенного номера телефона и повторите попытку";
    }
    [self showAlertWithTitle:title message:message completion:completion];
}

-(void)showAlertWithTitle:(NSString*) title message:(NSString*) message completion:(void (^ __nullable)(void))completion{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:title
                                 message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okButton = [UIAlertAction
                                actionWithTitle:@"OK"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    //Handle your yes please button action here
                                }];

    [alert addAction:okButton];
    
    [_currentController presentViewController:alert animated:YES completion:completion];
}

@end
