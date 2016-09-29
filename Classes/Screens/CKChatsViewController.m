//
//  CKChatsViewController.m
//  click
//
//  Created by Igor Tetyuev on 21.03.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKChatsViewController.h"
#import "CKDialogChatCell.h"
#import "CKGroupChatCell.h"
#import "CKDialogChatController.h"
#import "CKFriendSelectionController.h"
#import "CKNewGroupController.h"

@implementation CKChatsViewController
{
    NSArray *_broadcasts;
    NSArray *_groupchats;
    NSArray *_personalchats;
    UISearchBar *_searchBar;
    UIView *_noChatsView;
    UILabel *_noChatsLabel;
    UILabel *_createLabel;
    UIButton *_createChatButton;
    UIImageView *_logo;
}


- (instancetype)init
{
    if (self = [super init])
    {
        self.title = @"Сообщения";
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(newChat)];
        [[CKDialogsModel sharedInstance] addObserver:self forKeyPath:@"dialogs" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

+ (UIImage *)imageFromColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)newChat
{
    UIAlertController *chatPicker = [UIAlertController alertControllerWithTitle:nil
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Диалог"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *a){
                                                       CKFriendSelectionController *ctl = [CKFriendSelectionController new];
                                                       [self.navigationController pushViewController:ctl animated:YES];
                                                   }];
    [chatPicker addAction:action];
    action = [UIAlertAction actionWithTitle:@"Группу"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *a){
                                                       CKNewGroupController *ctl = [CKNewGroupController new];
                                                       [self.navigationController pushViewController:ctl animated:YES];

                                                   }];
    [chatPicker addAction:action];
    action = [UIAlertAction actionWithTitle:@"Рассылку"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *a){
                                                       CKNewGroupController *ctl = [CKNewGroupController new];
                                                       [self.navigationController pushViewController:ctl animated:YES];

                                                   }];
    [chatPicker addAction:action];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Отменить"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *a){
                                                             [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
                                                         }];
    [chatPicker addAction:cancelAction];
    
    [self presentViewController:chatPicker
                       animated:YES
                     completion:nil];
}

- (void)loadView
{
    self.view = [UIView new];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    _noChatsView = [UIView new];
    
    _noChatsView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bgwhite"]];

    _noChatsLabel = [UILabel labelWithText:@"У вас нет диалогов групп и рассылок"
                                     font:[UIFont systemFontOfSize:20.0]
                                textColor:[UIColor blackColor]
                            textAlignment:NSTextAlignmentCenter];
    _noChatsLabel.numberOfLines = 2;
    [_noChatsView addSubview:_noChatsLabel];
    
    _logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo-blue"]];
    _logo.contentMode = UIViewContentModeCenter;

    [_noChatsView addSubview:_logo];
    
    _createLabel = [UILabel labelWithText:@"Создайте диалог, группу или рассылку для участников из вашего списка Контактов" font:[UIFont systemFontOfSize: 18.0] textColor:[UIColor colorFromHexString:@"#67696b"] textAlignment:NSTextAlignmentCenter];
    _createLabel.numberOfLines = 3;
    [_noChatsView addSubview:_createLabel];
    
    _createChatButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_createChatButton setTitle:@"Создать" forState:UIControlStateNormal];
    [_createChatButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _createChatButton.titleLabel.font = CKButtonFont;
    _createChatButton.backgroundColor = CKClickBlueColor;
    _createChatButton.clipsToBounds = YES;
    _createChatButton.layer.cornerRadius = 4;
    [_createChatButton addTarget:self action:@selector(newChat) forControlEvents:UIControlEventTouchUpInside];
    [_noChatsView addSubview:_createChatButton];
        
    [self.view addSubview:_noChatsView];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.tableFooterView.backgroundColor = CKClickLightGrayColor;
    self.tableView.backgroundColor = CKClickLightGrayColor;
    UIView *searchBarBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 45)];
    searchBarBackground.backgroundColor = CKClickLightGrayColor;
    UIView *separator = [UIView new];
    [searchBarBackground addSubview:separator];
    separator.backgroundColor = CKClickProfileGrayColor;
    [separator makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(searchBarBackground.width);
        make.height.equalTo(0.5);
        make.bottom.equalTo(searchBarBackground.bottom);
    }];
    
    _searchBar = [[UISearchBar alloc] init];
    _searchBar.showsCancelButton = NO;
    _searchBar.translucent = YES;
    _searchBar.barTintColor = [UIColor colorFromHexString:@"#f5f4f3"];
    _searchBar.delegate = self;
    _searchBar.returnKeyType = UIReturnKeyDone;
    _searchBar.backgroundImage = [CKChatsViewController imageFromColor:CKClickLightGrayColor];
    _searchBar.frame = CGRectMake(0, 0, self.view.bounds.size.width, 64);
    _searchBar.placeholder = @"Поиск";
    
    [searchBarBackground addSubview:_searchBar];
    [_searchBar makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(_searchBar.superview.width);
        make.height.equalTo(_searchBar.superview.height).offset(-1);
        make.top.equalTo(0);
        make.left.equalTo(0);
    }];
    
    self.tableView.tableHeaderView = searchBarBackground;
}

- (void)updateViewConstraints
{
    [super updateViewConstraints];
    
    [_tableView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [_noChatsView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [_noChatsLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_noChatsView.top).offset(15.0*2 + self.topLayoutGuide.length);
        make.left.equalTo(_noChatsView.left).offset(15.0*2);
        make.right.equalTo(_noChatsView.right).offset(-15.0*2);
        
    }];
    
    [_logo remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_noChatsLabel.bottom).offset(15.0);
        make.height.greaterThanOrEqualTo(167).priorityHigh();
        make.centerX.equalTo(_noChatsView.centerX);
    }];
    
    [_createLabel remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_logo.bottom).offset(10.0);
        make.bottom.lessThanOrEqualTo(_createChatButton.top).offset(-25).with.priorityLow();
        make.left.equalTo(_noChatsView.left).offset(15);
        make.right.equalTo(_noChatsView.right).offset(-15);
    }];
    
    [_createChatButton remakeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@44);
        make.bottom.equalTo(self.view.bottom).offset(-15 - self.bottomLayoutGuide.length);
        make.left.equalTo(_noChatsView.left).offset(15);
        make.right.equalTo(_noChatsView.right).offset(-15);
    }];
    _noChatsView.hidden = YES;
}

- (void)viewDidLayoutSubviews
{
    NSLog(@"%@", _logo);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"dialogs"])
    {
        [self reloadData];
    }
}

- (void)reloadData
{
    NSMutableArray *broadcasts = [NSMutableArray new];
    NSMutableArray *groupchats = [NSMutableArray new];
    NSMutableArray *personalchats = [NSMutableArray new];
    for (CKDialogListEntryModel *i in [[CKDialogsModel sharedInstance] dialogs])
    {
        switch (i.type)
        {
            case 0:
                [personalchats addObject:i];
                break;
            case 1:
                [groupchats addObject:i];
                break;
            case 2:
                [personalchats addObject:i];
                break;
            default:
                break;
        }
    }
    _broadcasts = broadcasts;
    _groupchats = groupchats;
    _personalchats = personalchats;
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return [_broadcasts count];
            break;
        case 1:
            return [_groupchats count];
            break;
        case 2:
            return [_personalchats count];
            break;
        default:
            break;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case 0:
        {
            CKDialogListEntryModel *model = [_broadcasts objectAtIndex:indexPath.row];
            CKGroupChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CKGroupChatCell"];
            if (!cell)
            {
                cell = [CKGroupChatCell new];
            }
            cell.model = model;
            return cell;
        }
        case 1:
        {
            CKDialogListEntryModel *model = [_groupchats objectAtIndex:indexPath.row];
            CKGroupChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CKGroupChatCell"];
            if (!cell)
            {
                cell = [CKGroupChatCell new];
            }
            cell.model = model;
            return cell;
        }
            break;
        case 2:
        {
            CKDialogListEntryModel *model = [_personalchats objectAtIndex:indexPath.row];
            CKDialogChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CKDialogChatCell"];
            if (!cell)
            {
                cell = [CKDialogChatCell new];
            }
            cell.model = model;
            return cell;
        }
            break;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case 0:
        case 1:
            break;
        case 2:
        {
            CKDialogListEntryModel *model = [_personalchats objectAtIndex:indexPath.row];
            CKDialogChatController *ctl = [[CKDialogChatController alloc] initWithUserId:model.userId];
            [self.navigationController pushViewController:ctl animated:YES];
        }
            break;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [_searchBar resignFirstResponder];    
}

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
}

@end
