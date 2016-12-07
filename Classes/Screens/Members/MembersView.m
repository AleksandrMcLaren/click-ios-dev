//  Created by Дрягин Павел
//  Copyright © 2016 Click. All rights reserved.



#import "MembersView.h"
#import "ProfileView.h"


@interface MembersView()
{
	NSArray *members;
	NSMutableArray *dbusers;
}
@end


@implementation MembersView


- (id)initWith:(NSArray *)members_

{
	self = [super init];
	members = members_;
	return self;
}


- (void)viewDidLoad

{
	[super viewDidLoad];
	self.title = @"Members";
	
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
	[self.navigationItem setBackBarButtonItem:backButton];
	
	dbusers = [[NSMutableArray alloc] init];
	
	[self loadUsers];
}

#pragma mark - Backend actions


- (void)loadUsers

{
	[dbusers removeAllObjects];
	
//	for (CKUser *dbuser in [[DBUser allObjects] sortedResultsUsingProperty:FUSER_FULLNAME ascending:YES])
//	{
//		if ([members containsObject:dbuser.id])
//			[dbusers addObject:dbuser];
//	}
	
	[self.tableView reloadData];
}

#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView

{
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section

{
	return [dbusers count];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section

{
	return [self titleForHeaderMembers];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath

{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
	
	CKUser *dbuser = dbusers[indexPath.row];
	cell.textLabel.text = dbuser.fullname;
	
	return cell;
}

#pragma mark - Table view delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath

{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	CKUser *dbuser = dbusers[indexPath.row];
//	if ([dbuser.objectId isEqualToString:[CKUser currentId]] == NO)
//	{
//		ProfileView *profileView = [[ProfileView alloc] initWith:dbuser.objectId Chat:YES];
//		[self.navigationController pushViewController:profileView animated:YES];
//	}
//	else [ProgressHUD showSuccess:@"This is you."];
}

#pragma mark - Helper methods


- (NSString *)titleForHeaderMembers

{
	NSString *text = ([dbusers count] > 1) ? @"MEMBERS" : @"MEMBER";
	return [NSString stringWithFormat:@"%ld %@", (long) [dbusers count], text];
}

@end

