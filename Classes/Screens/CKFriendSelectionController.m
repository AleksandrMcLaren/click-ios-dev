//
//  CKFriendSelectionController.m
//  click
//
//  Created by Igor Tetyuev on 20.04.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKFriendSelectionController.h"
#import "CKFriendCell.h"

@implementation CKFriendSelectionController
{
    NSArray *_contacts;
    NSArray *_excludeList;
    NSMutableSet *_selection;
}

- (instancetype)init
{
    if (self = [super initWithStyle:UITableViewStylePlain])
    {
        self.title = @"Контакты";
        _selection = [NSMutableSet new];
    }
    return self;
}

- (instancetype)initWithExcludedFriends:(NSArray *)excludeList
{
    if (self = [self init])
    {
        _excludeList = excludeList;
    }
    return self;
}

- (void)done
{
    if (self.multiselect)
    {
        [self.delegate didSelectFriends:_selection];
    }
}

- (void)viewDidLoad
{
    self.tableView.backgroundColor = CKClickLightGrayColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self reloadData];
}

- (void)reloadData
{
    _contacts = [NSMutableArray array];
    
    // fill with friends
    NSMutableArray *sortedFriends = [[[CKApplicationModel sharedInstance] friends] sortedArrayUsingComparator:^NSComparisonResult(CKUserModel *obj1, CKUserModel *obj2) {
        NSString *str1 = obj1.surname.length?obj1.surname:obj1.name;
        NSString *str2 = obj2.surname.length?obj2.surname:obj2.name;
        return [str1 compare:str2 options: NSCaseInsensitiveSearch];
        
    }].mutableCopy;
    if (_excludeList) [sortedFriends removeObjectsInArray:_excludeList];
    
    _contacts = sortedFriends;
    
    [self.tableView reloadData];
}

- (void)setMultiselect:(BOOL)multiselect
{
    _multiselect = multiselect;
    if (_multiselect)
    {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    } else
    {
        self.navigationItem.rightBarButtonItem = nil;
    }
    if (!self.isViewLoaded) return;
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _contacts.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) return 0;
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CKFriendCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CKFriendCell"];
    
    if (!cell) {
        cell = [CKFriendCell new];
    }
    CKUserModel *friend = (CKUserModel *)[_contacts objectAtIndex:indexPath.row];
    cell.isLast = [_contacts count]-1 == indexPath.row;
    cell.friend = friend;
    cell.isSelectable = self.multiselect;
    cell.isSelected = [_selection containsObject:friend];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKUserModel *friend = (CKUserModel *)[_contacts objectAtIndex:indexPath.row];
    if (!self.multiselect)
    {
        [self.delegate didSelectFriend:friend];
        return;
    }
    if ([_selection containsObject:friend]) [_selection removeObject:friend]; else [_selection addObject:friend];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

@end
