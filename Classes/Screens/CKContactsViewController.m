//
//  CKContactsViewController.m
//  click
//
//  Created by Igor Tetyuev on 21.03.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKContactsViewController.h"
#import "CKFriendCell.h"
#import "CKAddressBookCell.h"
#import "CKCache.h"
#import "CKFriendProfileController.h"

@implementation CKContactsViewController
{
    NSMutableArray *_contacts;
    NSArray *_phoneContacts;
    
    NSArray *_sections;
}

- (instancetype)init
{
    if (self = [super initWithStyle:UITableViewStylePlain])
    {
        self.title = @"Контакты";
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add)];
        _phoneContacts = [[CKApplicationModel sharedInstance] phoneContacts];
    }
    return self;
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
    NSArray *sortedFriends = [[[CKApplicationModel sharedInstance] friends] sortedArrayUsingComparator:^NSComparisonResult(CKUserModel *obj1, CKUserModel *obj2) {
        NSString *str1 = obj1.surname.length?obj1.surname:obj1.name;
        NSString *str2 = obj2.surname.length?obj2.surname:obj2.name;
        return [str1 compare:str2 options: NSCaseInsensitiveSearch];

    }];
    
    NSMutableArray* sections = [NSMutableArray array];

    [sections addObject:@{@"title":@"friends", @"arr":sortedFriends}];

    for(CKPhoneContact *phoneItem in _phoneContacts) {
        NSString *username = phoneItem.fullname;
        NSString *surname = phoneItem.surname;
        if (!surname.length) surname = username;
        NSString* firstLetter = [[surname substringToIndex:1] uppercaseString];
        NSDictionary* section = nil;
        for(NSDictionary *sect in sections) {
            NSString* title = sect[@"title"];
            if([title isEqualToString:firstLetter]) {
                section = sect;
                break;
            }
        }
        if(!section) {
            section = [NSMutableDictionary dictionaryWithDictionary:@{@"title":firstLetter, @"arr":[NSMutableArray arrayWithObject:phoneItem]}];
            [sections addObject:section];
        } else {
            NSMutableArray* arr = [section objectForKey:@"arr"];
            [arr addObject:phoneItem];
            section = @{@"title":firstLetter, @"arr": arr};
        }
    }
    NSError* error = nil;
    NSRegularExpression* rusRegexp = [NSRegularExpression regularExpressionWithPattern:@"[А-Яа-я]" options:0 error:&error];
    if(error) {
        NSLog(@"ERROR %@", error);
    }
    NSRegularExpression* engRegexp = [NSRegularExpression regularExpressionWithPattern:@"[A-Za-z]" options:0 error:&error];
    if(error) {
        NSLog(@"ERROR %@", error);
    }
    _sections = [sections sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSString* left = [obj1 objectForKey:@"title"];
        if ([left isEqualToString:@"friends"])
        {
            return NSOrderedAscending;
        }
        NSString* right = [obj2 objectForKey:@"title"];
        NSTextCheckingResult* leftRus = [rusRegexp firstMatchInString:left options:0 range:NSMakeRange(0, 1)];
        NSTextCheckingResult* rightEng = [engRegexp firstMatchInString:right options:0 range:NSMakeRange(0, 1)];
        if(leftRus && rightEng) {
            return -1;
        } else {
            return [left compare:right];
        }
    }];
    NSLog(@"%@", sections);

    [self.tableView reloadData];
}

- (void)add
{
    
}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    CKFriendProfileController *controller = [[CKFriendProfileController alloc] initWithUser:_sections[0][@"arr"][indexPath.row]];
    [self.navigationController pushViewController:controller animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_sections[section][@"arr"] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return _sections[section][@"title"];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *back = [UIView new];
    back.backgroundColor = [UIColor clearColor];
    UILabel *l = [UILabel labelWithText:_sections[section][@"title"] font:[UIFont boldSystemFontOfSize:16.0] textColor:[UIColor colorFromHexString:@"#808080"] textAlignment:NSTextAlignmentLeft];
    [back addSubview:l];
    [l makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(back.left).offset(16);
        make.top.equalTo(back.top);
        make.bottom.equalTo(back.bottom);
    }];
    return back;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) return 0;
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary* section = [_sections objectAtIndex:indexPath.section];
    NSArray* arr = [section mutableArrayValueForKey:@"arr"];
    if(indexPath.section == 0) {
        CKFriendCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CKFriendCell"];

        if (!cell) {
            cell = [CKFriendCell new];
        }
        CKUserModel *friend = (CKUserModel *)[arr objectAtIndex:indexPath.row];
        cell.isLast = [arr count]-1 == indexPath.row;
        cell.friend = friend;
        return cell;
    } else {
        CKAddressBookCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CKAddressBookCell" ];
        if (!cell) {
            cell = [CKAddressBookCell new];
        }
        CKPhoneContact *contact = (CKPhoneContact *)[arr objectAtIndex:indexPath.row];
        NSAttributedString *s = [NSMutableAttributedString withName:contact.name surname:contact.surname size:16.0];
        cell.textLabel.attributedText = s;
        return cell;
    }
    return nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void) invite:(UIButton *)invite
{
    
}

@end
