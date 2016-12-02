//
//  CKSettingsViewController.m
//  click
//
//  Created by Igor Tetyuev on 21.03.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKSettingsViewController.h"
#import "CKUserServerConnection.h"

@implementation CKSettingsViewController

- (instancetype)init
{
    if (self = [super initWithStyle:UITableViewStylePlain])
    {
        self.title = @"Настройки";
    }
    return self;
}

- (void) viewDidLoad
{
    self.content = @[ @"Мой профиль", @"Настройки приложения",@"Уведомления",@"Сообщения",@"Приватность и безопасность",@"Поддержка и информация", @"Выйти из аккаунта"];
    self.tableView.tableFooterView = [UIView new];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return self.content.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [cell.textLabel setText:[self.content objectAtIndex:indexPath.row]];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case 0:
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            break;
        case 1:
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            break;
        case 2:
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            break;
        case 3:
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            break;
        case 4:
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            break;
        case 5:
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            break;
        case 6:
            [self exit];
            break;
    }
}

- (void) exit
{
    //[[CKApplicationModel sharedInstance] logOut];
}


@end
