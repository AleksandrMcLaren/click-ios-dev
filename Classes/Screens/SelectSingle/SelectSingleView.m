//  Created by Дрягин Павел on 18.11.16.
//  Copyright © 2016 Click. All rights reserved.

#import "SelectSingleView.h"

@interface SelectSingleView()
{
	NSArray* users;
	NSMutableArray *sections;
}

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SelectSingleView

@synthesize delegate;
@synthesize searchBar;

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.title = @"Создание диалога";
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self
                                                                                          action:@selector(actionCancel)];
	self.tableView.tableFooterView = [[UIView alloc] init];
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
//users = 
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
	for (CKUser* user in users)
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
	CKUser *user = users_section[indexPath.row];
	cell.textLabel.text = user.login;
	return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	[self dismissViewControllerAnimated:YES completion:^{
		if (delegate != nil)
		{
			NSArray *dbusers_section = sections[indexPath.section];
			[delegate didSelectSingleUser:dbusers_section[indexPath.row]];
		}
	}];
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
