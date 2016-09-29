//
//  CKCountrySelectionController.m
//  click
//
//  Created by Igor Tetyuev on 10.03.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKCountrySelectionController.h"
#import "CKCountryCell.h"
#import "AppDelegate.h"
#import "UIColor+hex.h"

@implementation CKCountrySelectionController
{
    UISearchBar *_searchBar;
    UITableView *_tableView;
    NSArray *_data;
    CGFloat _keyboardHeight;
}
- (instancetype)init
{
    if (self = [super init])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameChanged:) name:UIKeyboardDidChangeFrameNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardDidHideNotification object:nil];
        
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrow_left_blue"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    }
    return self;
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)updateFrames
{
    [_tableView remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.left);
        make.top.equalTo(self.view.top);
        make.width.equalTo(self.view.width);
        make.bottom.equalTo(self.view.bottom).offset(-_keyboardHeight);
    }];
    if (_keyboardHeight > 0)[UIView animateWithDuration:0.4 animations:^{
        [self.view layoutIfNeeded];
        
    }];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    
    CGFloat keyboardHeight = [self keyboardHeightByKeyboardNotification:notification];
    _keyboardHeight = keyboardHeight;
    [self updateFrames];
}

- (void)keyboardFrameChanged:(NSNotification *)notification
{
    
    CGFloat keyboardHeight = [self keyboardHeightByKeyboardNotification:notification];
    _keyboardHeight = keyboardHeight;
    
    [self updateFrames];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    
//    CGFloat keyboardHeight = [self keyboardHeightByKeyboardNotification:notification];
    _keyboardHeight = 0;
    
    [self updateFrames];
}

-(CGFloat)keyboardHeightByKeyboardNotification:(NSNotification *)notification
{
    CGRect keyboardRect = [self.view.window convertRect:[[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue] toView:self.view];
    keyboardRect = CGRectIntersection(keyboardRect, self.view.bounds);
    return keyboardRect.size.height;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadData
{
    
    NSMutableString *query = [NSMutableString stringWithString:@"select * from countries where"];
    if (_searchBar.text.length)
    {
        [query appendFormat:@" myLow(name) like \"%%%@%%\" and ", [[_searchBar.text stringByReplacingOccurrencesOfString:@"\"" withString:@""] lowercaseString]];
    }
    [query appendString:@" phonecode>0 order by name"];
    
    
    CKDB *ckdb = [CKDB sharedInstance];
    
    [ckdb.queue inDatabase:^(FMDatabase *db) {
        FMResultSet *data = [db executeQuery:query];
        [[CKDB sharedInstance] configureDB:db];
        NSMutableArray *tmp = [NSMutableArray new];
        while ([data next])
        {
            [tmp addObject:[data resultDictionary]];
        }
        _data = tmp;
        [data close];
    }];
    [_tableView reloadData];
}

- (void)viewDidLoad
{
//    self.edgesForExtendedLayout = UIRectEdgeNone;
//    self.automaticallyAdjustsScrollViewInsets = NO;

    _searchBar = [[UISearchBar alloc] init];
    _searchBar.showsCancelButton = NO;
    _searchBar.translucent = YES;
    _searchBar.barTintColor = [UIColor colorFromHexString:@"#f5f4f3"];
    _searchBar.delegate = self;
    _searchBar.returnKeyType = UIReturnKeyDone;

    self.navigationItem.title = @"Страна";
    [self.view addSubview:_searchBar];
    CGFloat statusbarheight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    [_searchBar makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.left);
        make.top.equalTo(self.view.top).offset(self.navigationController.navigationBar.frame.size.height+statusbarheight);
        make.width.equalTo(self.view.width);
        make.height.equalTo(@44);
    }];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0);
    _tableView.contentOffset = CGPointMake(0, -44);
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view insertSubview:_tableView belowSubview:_searchBar];
    
    [_tableView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.left);
        make.top.equalTo(self.view.top);
        make.width.equalTo(self.view.width);
        make.bottom.equalTo(self.view.bottom);
    }];
    [self loadData];
}

- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self loadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKCountryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CKCountryCell"];
    if (!cell) cell = [CKCountryCell new];
    cell.title.text = _data[indexPath.row][@"name"];
    cell.countryBall.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@", _data[indexPath.row][@"iso"]]];
    cell.countryCode.text = [NSString stringWithFormat:@"+%@", _data[indexPath.row][@"phonecode"]];
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate countrySelectionController:self didSelectCountryWithId:[_data[indexPath.row][@"id"] integerValue] name:_data[indexPath.row][@"name"] code:_data[indexPath.row][@"phonecode"]];
}

@end
