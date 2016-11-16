//
//  CKCitySelectionController.m
//  click
//
//  Created by Igor Tetyuev on 10.03.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKCitySelectionController.h"
#import "AppDelegate.h"
#import "UIColor+hex.h"
#import "CKUserServerConnection.h"

@implementation CKCitySelectionController
{
    UISearchBar *_searchBar;
    UITableView *_tableView;
    NSArray *_data;
    CGFloat _keyboardHeight;
    UIActivityIndicatorView* _activityIndicatorView;
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

- (BOOL)hasData
{
    CKDB *ckdb = [CKDB sharedInstance];

    NSMutableString *query = [NSMutableString stringWithFormat:@"SELECT COUNT(c.id) as countryid FROM countries a JOIN regions b ON b.countryid=a.id JOIN cities c ON c.regionid=b.id WHERE a.id=%ld", (long)self.countryId];
    
    __block NSInteger count = NO;
    [ckdb.queue inDatabase:^(FMDatabase *db) {
        count = [db intForQuery:query];

    }];
    return count>0;
}

- (void)loadData
{
    [_activityIndicatorView stopAnimating];
    
    NSMutableString *query = [NSMutableString stringWithFormat:@"select c.id as id, c.name as name, b.name as regionname FROM countries a JOIN regions b ON b.countryid=a.id JOIN cities c ON c.regionid=b.id WHERE a.id=%ld ", (long)self.countryId];
    if (_searchBar.text.length)
    {
        [query appendFormat:@"and myLow(c.name) like \"%%%@%%\"", [[_searchBar.text stringByReplacingOccurrencesOfString:@"\"" withString:@""] lowercaseString]];
    }
    [query appendString:@" order by c.name"];
    NSLog(@"%@", query);
    
    CKDB *ckdb = [CKDB sharedInstance];
    
    [ckdb.queue inDatabase:^(FMDatabase *db) {
        [[CKDB sharedInstance] configureDB:db];
        FMResultSet *data = [db executeQuery:query];
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
    _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityIndicatorView.hidesWhenStopped = YES;
    
    _searchBar = [[UISearchBar alloc] init];
    _searchBar.showsCancelButton = NO;
    _searchBar.translucent = YES;
    _searchBar.barTintColor = [UIColor colorFromHexString:@"#f5f4f3"];
    _searchBar.delegate = self;
    _searchBar.returnKeyType = UIReturnKeyDone;

    self.navigationItem.title = @"Город";
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
    
    [_tableView addSubview:_activityIndicatorView];
    
    [_activityIndicatorView makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.equalTo(_tableView.contentSize.height/2);
        make.centerX.equalTo(_tableView.centerX);
        make.centerY.equalTo(CGRectGetMidY(_tableView.bounds));
    }];
    
    
    [_activityIndicatorView startAnimating];
    
    
    if ([self hasData]) {
        [self loadData];
    } else{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[CKUserServerConnection sharedInstance] getRegionsInCountry:self.countryId callback:^(NSDictionary *result) {
                // load regions to database
                
                if ([result[@"status"] integerValue] == 1005) return;
                
                CKDB *ckdb = [CKDB sharedInstance];
                
                [ckdb.queue inDatabase:^(FMDatabase *db) {
                    NSArray *cities = result[@"result"];
                    for (NSDictionary *i in cities)
                    {
                        NSMutableString *query = [NSMutableString new];
                        [query appendFormat:@"INSERT INTO regions (id, name, countryid) VALUES "];
                        [query appendFormat:@"(%ld, \"%@\", %ld);\n", [i[@"regionid"] integerValue], i[@"regionname"], [i[@"countryid"] integerValue]];
                        [db executeUpdate:query];
                    }
                }];
                
                [[CKUserServerConnection sharedInstance] getCitiesInCountry:self.countryId mask:@"" locale:@"ru" callback:^(NSDictionary *result) {
                    // load cities to database
                    
                    if ([result[@"status"] integerValue] == 1005) return;
                    
                    CKDB *ckdb = [CKDB sharedInstance];
                    
                    [ckdb.queue inDatabase:^(FMDatabase *db) {
                        NSArray *cities = result[@"result"];
                        for (NSDictionary *i in cities)
                        {
                            NSMutableString *query = [NSMutableString new];
                            [query appendFormat:@"INSERT INTO cities (id, name, regionid, latitude, longitude) VALUES "];
                            [query appendFormat:@"(%ld, \"%@\", %ld, %f, %f);\n", [i[@"cityid"] integerValue], i[@"cityname"], [i[@"regionid"] integerValue], [i[@"lat"] doubleValue], [i[@"lng"] doubleValue]];
                            [db executeUpdate:query];
                        }
                    }];
                    
                    [self loadData];
                }];
                
            }];

        });
       
    }
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    cell.textLabel.text = _data[indexPath.row][@"name"];
    cell.detailTextLabel.text = _data[indexPath.row][@"regionname"];
    cell.detailTextLabel.textColor = [UIColor colorFromHexString:@"#67696b"];
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate citySelectionController:self didSelectCityWithId:[_data[indexPath.row][@"id"] integerValue] name:_data[indexPath.row][@"name"]];
}

@end
