//  Created by Дрягин Павел on 18.11.16.
//  Copyright © 2016 Click. All rights reserved.

#import "SelectMultipleView.h"


@interface SelectMultipleView()
{
	NSArray* users;
	NSMutableArray *sections;
	NSMutableArray *selection;
}

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SelectMultipleView

@synthesize delegate;
@synthesize searchBar;

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.title = @"Select Multiple";
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self
																						  action:@selector(actionCancel)];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self
																						   action:@selector(actionDone)];
	self.tableView.tableFooterView = [[UIView alloc] init];
	selection = [[NSMutableArray alloc] init];
	[self loadUsers];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[self dismissKeyboard];
}

- (void)dismissKeyboard
{
	[self.view endEditing:YES];
}

#pragma mark - Realm methods

- (void)loadUsers
{
	NSString *text = searchBar.text;
//	users = 
    [self refreshTableView];
}

#pragma mark - Refresh methods

- (void)refreshTableView
{
	[self setObjects];
	[self.tableView reloadData];
}

- (void)setObjects
{
	if (sections != nil) [sections removeAllObjects];
	NSInteger sectionTitlesCount = [[[UILocalizedIndexedCollation currentCollation] sectionTitles] count];
	sections = [[NSMutableArray alloc] initWithCapacity:sectionTitlesCount];
	for (NSUInteger i=0; i<sectionTitlesCount; i++)
	{
		[sections addObject:[NSMutableArray array]];
	}
	for (CKUserModel *user in users)
	{
		NSInteger section = [[UILocalizedIndexedCollation currentCollation] sectionForObject:user collationStringSelector:@selector(fullname)];
		[sections[section] addObject:user];
	}
}

#pragma mark - User actions

- (void)actionCancel
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)actionDone
{
	if ([selection count] == 0) {
//        [ProgressHUD showError:@"Please select some users."]; return;
    }
	[self dismissViewControllerAnimated:YES completion:^{
		if (delegate != nil) [delegate didSelectMultipleUsers:selection];
	}];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	[self dismissKeyboard];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [sections[section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if ([sections[section] count] != 0)
	{
		return [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section];
	}
	else return nil;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
	return [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
	return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
	NSArray *users_section = sections[indexPath.section];
	CKUserModel *user = users_section[indexPath.row];
	cell.textLabel.text = user.login;
	cell.accessoryType = [selection containsObject:user.id] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	NSArray *dbusers_section = sections[indexPath.section];
	CKUserModel *user = dbusers_section[indexPath.row];
	if ([selection containsObject:user.id])
		[selection removeObject:user.id];
	else [selection addObject:user.id];
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	cell.accessoryType = [selection containsObject:user.id] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
	[self loadUsers];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar_
{
	[searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar_
{
	[searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar_
{
	searchBar.text = @"";
	[searchBar resignFirstResponder];
	[self loadUsers];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar_
{
	[searchBar resignFirstResponder];
}

@end
