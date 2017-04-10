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
#import "NoChatsView.h"
#import "utilities.h"
#import "NavigationController.h"
#import "ChatView.h"

@interface CKChatsViewController()<SWTableViewCellDelegate,SelectSingleDelegate,SelectMultipleDelegate>

@end

@implementation CKChatsViewController
{
    NSArray *_broadcasts;
    NSArray *_groupchats;
    NSArray *_personalchats;
    UISearchBar *_searchBar;
    UIView *_noChatsView;
    
    SWTableViewCell* lastCell;
}


- (instancetype)init
{
    if (self = [super init])
    {
        [self initialize];
    }
    return self;
}

-(void) initialize{
    self.title = @"Чаты";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(actionCompose)];
    
    [NotificationCenter addObserver:self selector:@selector(actionCleanup) name:NOTIFICATION_USER_LOGGED_OUT];
    [NotificationCenter addObserver:self selector:@selector(refreshTableView) name:NOTIFICATION_REFRESH_RECENTS];
    
    [[CKDialogsModel sharedInstance].dialogsDidChanged subscribeNext:^(NSArray *dialogs) {
        _tableView.hidden = dialogs.count == 0;
        _noChatsView.hidden = dialogs.count != 0;
        
        if (dialogs.count) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self loadRecents];
            });
        }
    }];
    
    [self loadRecents];
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


-(void)viewDidLoad{
    [super viewDidLoad];
    
    self.view.backgroundColor = CKClickLightGrayColor;
    
    _noChatsView = [[NoChatsView alloc] initWithFrame:self.view.frame];
    _noChatsView.hidden = YES;
    
    [self.view addSubview:_noChatsView];

    _searchBar = [[UISearchBar alloc] init];
    _searchBar.showsCancelButton = NO;
    _searchBar.translucent = YES;
    _searchBar.barTintColor = [UIColor colorFromHexString:@"#f5f4f3"];
    _searchBar.delegate = self;
    _searchBar.returnKeyType = UIReturnKeyDone;
    _searchBar.backgroundImage = [CKChatsViewController imageFromColor:CKClickLightGrayColor];
    _searchBar.frame = CGRectMake(0, 0, self.view.bounds.size.width, 64);
    _searchBar.placeholder = @"Поиск";
    
    UIView *searchBarBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 45)];
    [searchBarBackground addSubview:_searchBar];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableHeaderView = searchBarBackground;
    self.tableView.bounces = YES;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.backgroundColor = CKClickLightGrayColor;
    self.tableView.refreshControl = [[UIRefreshControl alloc] init];
    self.tableView.refreshControl.tintColor = [UIColor darkGrayColor];
    [self.tableView.refreshControl addTarget:self
                                      action:@selector(loadRecents)
                            forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:self.tableView];
    
    [self makeConstraints];
}

- (void)viewWillDisappear:(BOOL)animated {
    [_searchBar resignFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated {
    // при выходе из чата обновляем список пользователей
    // только для обновления user.statusDate для бара в даилоге
    [[Users sharedInstance] updateUserList];
     
    [self loadRecents];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
}

-(void)makeConstraints{
    CGFloat topOffset = CGRectGetHeight([UIApplication sharedApplication].statusBarFrame) + CGRectGetHeight(self.navigationController.navigationBar.frame);
    CGFloat bottomOffset = CGRectGetHeight(self.tabBarController.tabBar.frame);
   
    [_noChatsView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(0).offset(topOffset);
        make.bottom.equalTo(0).offset(-bottomOffset);
        make.left.right.equalTo(0);
    }];
    
    [_tableView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(0).offset(topOffset);
        make.bottom.equalTo(0).offset(-bottomOffset);
        make.left.right.equalTo(0);
    }];
    
    [_searchBar makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(_searchBar.superview.width);
        make.height.equalTo(_searchBar.superview.height).offset(-1);
        make.top.equalTo(0);
        make.left.equalTo(0);
    }];
}

#pragma mark - Cleanup methods

- (void)actionCleanup{
    [self refreshTableView];
}


#pragma mark - Realm methods

- (void)loadRecents
{
    NSMutableArray *broadcasts = [NSMutableArray new];
    NSMutableArray *groupchats = [NSMutableArray new];
    NSMutableArray *personalchats = [NSMutableArray new];
    for (CKDialogModel *i in [[CKDialogsModel sharedInstance] dialogs])
    {
        if(_searchBar.text && _searchBar.text.length)
        {
            NSString *text = [_searchBar.text lowercaseString];
            NSString *fullText = [[NSString stringWithFormat:@"%@ %@ %@", i.userName, i.userSurname, i.userLogin] lowercaseString];
            
            if([fullText rangeOfString:text].location == NSNotFound)
                continue;
        }
        
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
    
    [self refreshTableView];
    [self.tableView.refreshControl endRefreshing];
}

#pragma mark - Refresh methods

- (void)refreshTableView
{
    [self.tableView reloadData];
    [self refreshTabCounter];
    //[self.tableView setContentOffset:CGPointMake(0, 44)];
}

- (void)refreshTabCounter
{
    NSInteger total = 0;
    
//    for (DBRecent *dbrecent in dbrecents)
//        total += dbrecent.counter;
    
    UITabBarItem *item = self.tabBarController.tabBar.items[0];
    item.badgeValue = (total != 0) ? [NSString stringWithFormat:@"%ld", (long) total] : nil;
    
    UIUserNotificationSettings *currentUserNotificationSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
    if (currentUserNotificationSettings.types & UIUserNotificationTypeBadge)
        [UIApplication sharedApplication].applicationIconBadgeNumber = total;
}


#pragma mark - User actions

- (void)startChat:(CKChatModel *)chat{
    ChatView *chatView = [[ChatView alloc] initWithChat:chat];
    chatView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatView animated:YES];
}


- (void)actionCompose
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"Диалог" style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction *action) { [self actionSelectSingle]; }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"Группу" style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction *action) { [self actionSelectMultiple]; }];
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"Рассылку" style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction *action) { [self actionSelectMultiple]; }];
    UIAlertAction *action4 = [UIAlertAction actionWithTitle:@"Отмена" style:UIAlertActionStyleCancel
                                                    handler:^(UIAlertAction *action) {
//                                                        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
                                                    }];
    
    [alert addAction:action1]; [alert addAction:action2]; [alert addAction:action3]; [alert addAction:action4];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)actionSelectSingle

{
    SelectSingleView *selectSingleView = [[SelectSingleView alloc] init];
    selectSingleView.delegate = self;
    [self.navigationController pushViewController:selectSingleView animated:YES];
}

- (void)actionSelectMultiple
{
    SelectMultipleView *selectMultipleView = [[SelectMultipleView alloc] init];
    selectMultipleView.delegate = self;
    [self.navigationController pushViewController:selectMultipleView animated:YES];
}

- (void)actionArchive:(NSIndexPath*) indexPath
{
//    DBRecent *dbrecent = dbrecents[index];
//    NSString *recentId = dbrecent.objectId;
//    [self archiveRecent:dbrecent];
//    [self refreshTabCounter];
//    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
//    [self performSelector:@selector(delayedArchive:) withObject:recentId afterDelay:0.25];
}

- (void)delayedArchive:(NSIndexPath*) indexPath
{
    [self.tableView reloadData];
//    [Recent archiveItem:recentId];
}


- (void)actionDelete:(NSIndexPath*) indexPath
{
    [self refreshTabCounter];
    [self deleteDialog:indexPath];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
   
}

-(void)deleteDialog:(NSIndexPath*) indexPath{
    NSMutableArray* array;
    switch (indexPath.section)
    {
        case 0:
        case 1:
            break;
        case 2:
        {
            array = _personalchats.mutableCopy;
            if (array.count > indexPath.row) {
                CKDialogModel* dialog = [self dialogWithIndexPath:indexPath];
                [array removeObjectAtIndex:indexPath.row];
                [self performSelector:@selector(delayedDelete:) withObject:dialog afterDelay:0.25];
                 _personalchats = array;
            }
                   }
            break;
    }
}

- (void)delayedDelete:(CKDialogModel*) dialog
{
    [[CKDialogsModel sharedInstance] deleteDialog:dialog];
}

#pragma mark - SelectSingleDelegate

- (void)didSelectSingleUser:(id)user
{
    [[CKApplicationModel sharedInstance] startPrivateChat:user];
}

#pragma mark - SelectMultipleDelegate

- (void)didSelectMultipleUsers:(NSArray *)userIds
{
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64.0;
}

#pragma mark - Table view data source

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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKChatListCell* cell;
    switch (indexPath.section)
    {
        case 0:
        {
            CKDialogModel *model = [_broadcasts objectAtIndex:indexPath.row];
            cell = [tableView dequeueReusableCellWithIdentifier:@"CKGroupChatCell"];
            if (!cell)
            {
                cell = [CKGroupChatCell new];
            }
            cell.model = model;
        }
        case 1:
        {
            CKDialogModel *model = [_groupchats objectAtIndex:indexPath.row];
            cell = [tableView dequeueReusableCellWithIdentifier:@"CKGroupChatCell"];
            if (!cell)
            {
                cell = [CKGroupChatCell new];
            }
            cell.model = model;
        }
            break;
        case 2:
        {
            CKDialogModel *model = [_personalchats objectAtIndex:indexPath.row];
            cell = [tableView dequeueReusableCellWithIdentifier:@"CKDialogChatCell"];
            if (!cell)
            {
                cell = [CKDialogChatCell new];
            }
            cell.model = model;
        }
            break;
    }
    cell.delegate = self;
    return cell;
}

#pragma mark - SWTableViewCellDelegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index
{
    [cell hideUtilityButtonsAnimated:YES];
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    [cell hideUtilityButtonsAnimated:YES];
    if (index == 0) [self actionArchive:indexPath];
    if (index == 1) [self actionDelete:indexPath];
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell scrollingToState:(SWCellState)state
{
    if (state == kCellStateRight) lastCell = cell;
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    return YES;
}

- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state
{
    return YES;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ((lastCell == nil) || [lastCell isUtilityButtonsHidden])
    {
        CKDialogModel* dialog = [self dialogWithIndexPath:indexPath];
        [[CKApplicationModel sharedInstance] restartRecentChat:dialog];
    }
    else
        [lastCell hideUtilityButtonsAnimated:YES];
}

-(CKDialogModel*)dialogWithIndexPath:(NSIndexPath *)indexPath{
    CKDialogModel* result;
    switch (indexPath.section)
    {
        case 0:
        case 1:
            break;
        case 2:
        {
            result = [_personalchats objectAtIndex:indexPath.row];
        }
            break;
    }
    return result;
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self loadRecents];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar_
{
    [_searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar_
{
    [_searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar_
{
    _searchBar.text = @"";
    [_searchBar resignFirstResponder];
    [self loadRecents];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar_
{
    [_searchBar resignFirstResponder];
}


@end
