//
//  CKCommonGroupsView.m
//  click
//
//  Created by Anatoly Mityaev on 02.12.16.
//  Copyright © 2016 Click. All rights reserved.
//

#import "CKCommonGroupsView.h"
#import "CKGroupChatCell.h"


@implementation CKCommonGroupsView
{
    NSArray *_groupchats;
}
- (instancetype)init
{
    if (self = [super init])
    {
        self.title = @"Общие группы";
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Назад" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
        //[[CKDialogsModel sharedInstance] addObserver:self forKeyPath:@"dialogs" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    NSMutableArray *groupchats = [NSMutableArray new];
    for (CKDialogListEntryModel *i in _commonGroups)
    {
        [groupchats addObject: i];
    }
    _groupchats = groupchats;
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_groupchats count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKDialogListEntryModel *model = [_groupchats objectAtIndex:indexPath.row];
    CKGroupChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CKGroupChatCell"];
    if (!cell) {
        cell = [CKGroupChatCell new];
    }
    cell.model = model;
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
