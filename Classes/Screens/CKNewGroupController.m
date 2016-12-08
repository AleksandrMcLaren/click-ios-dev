//
//  CKNewGroupController.m
//  click
//
//  Created by Igor Tetyuev on 27.04.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKNewGroupController.h"
#import "CKPictureCaptureManager.h"
#import "CKFriendCell.h"
#import "CKFriendSelectionController.h"

@interface CKNewGroupController()<CKFriendsSelectionDelegate>

@property (nonatomic, strong) CKGroupHeaderView *header;

@end

@implementation CKNewGroupController
{
    CKPictureCaptureManager *_pictureCapture;
    NSMutableArray *_users;
}

- (instancetype)init
{
    if (self = [super initWithStyle:UITableViewStylePlain])
    {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Отменить" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Далее" style:UIBarButtonItemStyleDone target:self action:@selector(cancel)];
        self.title = @"Новая группа";
        _pictureCapture = [CKPictureCaptureManager new];
        _pictureCapture.controller = self;
        _users = [NSMutableArray arrayWithObject:[[Users sharedInstance] currentUser]];
    }
    return self;
}

- (void)cancel
{
}

- (void)viewDidLoad
{
    _header = [CKGroupHeaderView new];
    _header.frame = CGRectMake(0, 0, self.view.bounds.size.width, 112);
    self.tableView.tableHeaderView = _header;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.backgroundColor = CKClickLightGrayColor;
    _header.name.delegate = self;
    _header.descriptionText.delegate = self;
    if([self.tableView respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)])
    {
        self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
    [_header.avatar addTarget:self action:@selector(takePhoto) forControlEvents:UIControlEventTouchUpInside];
}

- (void)takePhoto
{
    __weak CKNewGroupController *myself = self;
    [_pictureCapture captureWithCallback:^(UIImage* image, UIImage *preview, NSURL *path){
        // image captured
        NSLog(@"image: %@", image);
        [myself.header.avatar setTitle:nil forState:UIControlStateNormal];
        [myself.header.avatar setBackgroundImage:image forState:UIControlStateNormal];
    }
    ];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    switch (textField.tag)
    {
        case 0:
            break;
        case 1:
            break;
        case 2:
            break;
        default:
            break;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"Эта группа создана вами dd.MM.yyyy в hh:mm"];
    
    NSString *stringFromDate = [formatter stringFromDate:[NSDate date]];
    
    UILabel *header = [UILabel labelWithText:stringFromDate font:[UIFont systemFontOfSize:16.0] textColor:[UIColor colorFromHexString:@"#8e8e93"] textAlignment:NSTextAlignmentCenter];
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _users.count+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"AddUserCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AddUserCell"];
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"circleplus"]];
            cell.separatorInset = UIEdgeInsetsZero;
            cell.layoutMargins = UIEdgeInsetsZero;
            cell.preservesSuperviewLayoutMargins = NO;
            cell.textLabel.textColor = [UIColor darkGrayColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.textLabel.text = @"Добавить контакт";
        return cell;
    }
    CKFriendCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CKFriendCell"];
    
    if (!cell) {
        cell = [CKFriendCell new];
    }
    CKUser *friend = (CKUser *)[_users objectAtIndex:indexPath.row-1];
    cell.isLast = [_users count]-2 == indexPath.row;
    cell.friend = friend;
    cell.isSelectable = NO;
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        NSMutableArray *exclude = [NSMutableArray arrayWithObject:[[Users sharedInstance] currentUser]];
        [exclude addObjectsFromArray:_users];
        CKFriendSelectionController *ctl = [[CKFriendSelectionController alloc] initWithExcludedFriends:exclude];
        ctl.delegate = self;
        ctl.multiselect = YES;
        [self.navigationController pushViewController:ctl animated:YES];
    }
}

- (void)didSelectFriends:(NSSet *)friends
{
    [_users addObjectsFromArray:[friends allObjects]];
    [self.navigationController popViewControllerAnimated:YES];
    [self.tableView reloadData];
}

@end
