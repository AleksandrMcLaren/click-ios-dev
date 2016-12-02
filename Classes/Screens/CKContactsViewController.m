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
#import "CKContactWrapper.h"
#import "CKMessageServerConnection.h"


@implementation CKContactsViewController
{
    NSMutableArray *_contacts;
    NSArray *_phoneContacts;
    NSArray *_fullContacts;
    
    BOOL errorAdding;
    int errorHandling;
    BOOL existedPerson;
    BOOL deletedWrongPerson;
    
    NSArray *_sections;
    NSInteger chosenSection;
    
    UISearchBar *_searchBar;
    CGFloat _keyboardHeight;
    
    CKFriendProfileController *frPrC;
    NSArray *friendlist;
    NSArray *_userlist;
    NSArray *_contactsWithoutFriends;
    NSArray *searchResult;
    NSArray *_friendsAndContacts;
    NSString *searchString;
    BOOL fromContactsToSearch;
}

- (instancetype)init
{
    frPrC = [CKFriendProfileController new];
    if (self = [super initWithStyle:UITableViewStylePlain])
    {
        self.title = @"Контакты";
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add)];
        _phoneContacts = [[CKApplicationModel sharedInstance] phoneContacts];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameChanged:) name:UIKeyboardDidChangeFrameNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardDidHideNotification object:nil];
        
    }
    
    return self;
}

- (void)updateFrames
{
    [self.tableView remakeConstraints:^(MASConstraintMaker *make) {
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

- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self loadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    if ([_searchBar.text isEqual:@""]) fromContactsToSearch = false;
    searchResult = [NSArray new];
    [searchBar resignFirstResponder];
    [self.view endEditing:YES];
}


- (void)viewDidLoad
{
    fromContactsToSearch = false;
    searchString = [NSString new];
    searchString = @"";
    searchResult = [NSArray new];
    _contacts = [NSMutableArray array];
    frPrC.fromProfile = false;
    deletedWrongPerson = false;
    errorAdding = false;
    errorHandling = 0;
    existedPerson = false;
    
    self.tableView.backgroundColor = CKClickLightGrayColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor darkGrayColor];
    [self.refreshControl addTarget:self
                            action:@selector(reloadData)
                  forControlEvents:UIControlEventValueChanged];
    
    UIView *searchBarBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 45)];
    searchBarBackground.backgroundColor = CKClickLightGrayColor;
    UIView *separator = [UIView new];
    [searchBarBackground addSubview:separator];
    separator.backgroundColor = CKClickProfileGrayColor;
    [separator makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(searchBarBackground.width);
        make.height.equalTo(0.5);
        make.bottom.equalTo(searchBarBackground.bottom);
    }];
    
    _searchBar = [[UISearchBar alloc] init];
    _searchBar.showsCancelButton = YES;
    
    _searchBar.translucent = YES;
    _searchBar.delegate = self;
    _searchBar.returnKeyType = UIReturnKeyDone;
    _searchBar.backgroundImage = [CKContactsViewController imageFromColor:CKClickLightGrayColor];
    _searchBar.frame = CGRectMake(0, 0, self.view.bounds.size.width, 64);
    _searchBar.placeholder = @"Поиск";
    
    [searchBarBackground addSubview:_searchBar];
    [_searchBar makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(_searchBar.superview.width);
        make.height.equalTo(_searchBar.superview.height).offset(-1);
        make.top.equalTo(0);
        make.left.equalTo(0);
    }];
    _searchBar.text = searchString;
    self.tableView.tableHeaderView = searchBarBackground;
    
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    });
    [self loadContacts];
    [self reloadData];
}

- (void)loadData
{
    fromContactsToSearch = true;
    searchResult = [NSArray new];
    _userlist = [[CKApplicationModel sharedInstance] userlistMain];
    NSMutableArray *friendsAndContacts = [NSMutableArray new];
    [friendsAndContacts addObjectsFromArray:friendlist];
    [friendsAndContacts addObjectsFromArray:_contactsWithoutFriends];
    searchString = _searchBar.text;
    if (_searchBar.text.length < 5 && (_searchBar.text.length !=0))
    {
        NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"(name like[cd] %@) OR (surname like[cd] %@) ",[NSString stringWithFormat:@"*%@*", _searchBar.text],[NSString stringWithFormat:@"*%@*", _searchBar.text]];
        searchResult = [friendsAndContacts filteredArrayUsingPredicate:resultPredicate];
    }
    else if (_searchBar.text.length >= 5)
    {
        NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"(name like[cd] %@) OR (surname like[cd] %@) OR (login like[cd] %@) ",[NSString stringWithFormat:@"*%@*", _searchBar.text],[NSString stringWithFormat:@"*%@*", _searchBar.text], [NSString stringWithFormat:@"*%@*", _searchBar.text]];
        searchResult = [_userlist filteredArrayUsingPredicate:resultPredicate];
    }
    else
    {
        searchResult = nil;
    }
    [self reloadData];
}



- (void)reloadData
{
    _fullContacts = [[CKApplicationModel sharedInstance] fullContacts];
    NSMutableArray *unsortedFriends = [NSMutableArray new];
    NSMutableArray *array = [NSMutableArray new];
    NSArray *sortedFriends = [NSArray new];
    NSMutableArray *contactsWithoutFriends = [NSMutableArray new];
    BOOL theSameUser = NO;
    if (searchResult == nil || [_searchBar.text isEqual:@""]/*) && fromContactsToSearch == false*/)
    {
        unsortedFriends = [NSMutableArray new];
        [unsortedFriends addObjectsFromArray:[[CKApplicationModel sharedInstance] friends]];
        for (CKUserModel *i in _contacts)
        {
            theSameUser = NO;
            for (CKUserModel *u in unsortedFriends)
            {
                if ([u.id isEqual: i.id])
                {
                    theSameUser = YES;
                    break;
                }
            }
            if (theSameUser == NO)
            {
                [array addObject:i];
            }
        }
        [unsortedFriends addObjectsFromArray:array];
        
        for (CKUserModel *i in unsortedFriends)
        {
            NSString *phoneNumber = [NSString new];
            for (CKPhoneContact *p in _fullContacts)
            {
                phoneNumber = p.phoneNumber;
                if (phoneNumber.length == 11 && ([[phoneNumber substringToIndex:1]  isEqual: @"8"])) phoneNumber = [phoneNumber stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@"7"];
                if ([i.id isEqual:phoneNumber])
                {
                    i.name = p.name;
                    i.surname = p.surname;
                    break;
                }
            }
        }
        sortedFriends = [unsortedFriends sortedArrayUsingComparator:^NSComparisonResult(CKUserModel *obj1, CKUserModel *obj2) {
            NSString *str1 = obj1.surname.length?obj1.surname:obj1.name;
            NSString *str2 = obj2.surname.length?obj2.surname:obj2.name;
            return [str1 compare:str2 options: NSCaseInsensitiveSearch];
            
        }];
        friendlist = sortedFriends;
        contactsWithoutFriends = [NSMutableArray new];
        int count = 0;
        for (CKPhoneContact *phoneItem in _fullContacts)
        {
            NSString *phoneNumber = phoneNumber = phoneItem.phoneNumber;
            if (phoneNumber.length == 11 && ([[phoneNumber substringToIndex:1]  isEqual: @"8"])) phoneNumber = [phoneNumber stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@"7"];
            for (CKUserModel *i in sortedFriends)
            {
                count = 0;
                if ([phoneNumber isEqual: i.id])
                {
                    count++;
                    break;
                }
            }
            if (count == 0)
            {
                [contactsWithoutFriends addObject:phoneItem];
            }
        }
        _contactsWithoutFriends = [NSMutableArray new];
        _contactsWithoutFriends = contactsWithoutFriends;
        fromContactsToSearch = false;
    }
    else
    {
        unsortedFriends = [NSMutableArray new];
        for (int i = 0; i< searchResult.count; i++)
        {
            if ([searchResult[i] isKindOfClass:[CKUserModel class]])
            {
                [unsortedFriends addObject:searchResult[i]];
            }
            if ([searchResult[i] isKindOfClass:[CKPhoneContact class]])
            {
                [contactsWithoutFriends addObject:searchResult[i]];
            }
        }
        for (CKUserModel *i in unsortedFriends)
        {
            NSString *phoneNumber = [NSString new];
            for (CKPhoneContact *p in _fullContacts)
            {
                phoneNumber = p.phoneNumber;
                if (phoneNumber.length == 11 && ([[phoneNumber substringToIndex:1]  isEqual: @"8"])) phoneNumber = [phoneNumber stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@"7"];
                if ([i.id isEqual:phoneNumber])
                {
                    i.name = p.name;
                    i.surname = p.surname;
                    break;
                }
            }
        }
        sortedFriends = [unsortedFriends sortedArrayUsingComparator:^NSComparisonResult(CKUserModel *obj1, CKUserModel *obj2) {
            NSString *str1 = obj1.surname.length?obj1.surname:obj1.name;
            NSString *str2 = obj2.surname.length?obj2.surname:obj2.name;
            return [str1 compare:str2 options: NSCaseInsensitiveSearch];
            
        }];
        fromContactsToSearch = true;
    }
    NSMutableArray* sections = [NSMutableArray array];
    [sections addObject:@{@"title":@"friends", @"arr":sortedFriends}];
    
    for(CKPhoneContact *phoneItem in /*_phoneContacts*/ contactsWithoutFriends) {
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
    
    if (searchResult == nil || [_searchBar.text isEqual:@""] ) [self.refreshControl endRefreshing];
    [self.tableView reloadData];
    [[CKApplicationModel sharedInstance] updateFriends];
}

- (void)add
{
    errorAdding = false;
    existedPerson = false;
    
    CNContactStore *store = [[CNContactStore alloc] init];
    
    CNMutableContact *contact = [[CNMutableContact alloc] init];
    
    CNContactViewController *controller = [CNContactViewController viewControllerForNewContact:contact];
    
    controller.contactStore = store;
    controller.delegate = self;
    controller.title = @"";
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    
    [self presentViewController: navController animated:YES completion: nil];
}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section != 0) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else
    {
        frPrC.fromProfile = true;
        CKFriendProfileController *controller = [[CKFriendProfileController alloc] initWithUser:_sections[0][@"arr"][indexPath.row]];
        controller.wentFromTheMap = false;
        [self.navigationController pushViewController:controller animated:YES];
    }
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
        chosenSection = indexPath.section;
        cell.inviteButton.tag = indexPath.section;
        
        [cell.inviteButton addTarget:self
                              action: @selector(inviteContact:)
                    forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }
    return nil;
}

- (void) loadContacts
{
    fromContactsToSearch = false;
    NSArray *arr = [[CKApplicationModel sharedInstance] fullContacts];
    NSArray *userlist = [[CKApplicationModel sharedInstance] userlistMain];
    NSMutableArray *userlistIDOnly = [NSMutableArray new];
    NSMutableArray *temporary = [NSMutableArray new];
    CKUserModel *user = [CKUserModel new];
    BOOL sameUser = NO;
    for (CKPhoneContact *i in arr)
    {
        NSString *phoneNumber = [NSString new];
        phoneNumber = i.phoneNumber;
        if (phoneNumber.length == 11 && ([[phoneNumber substringToIndex:1]  isEqual: @"8"])) phoneNumber = [phoneNumber stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@"7"];
        sameUser = NO;
        for (CKUserModel *p in userlist) {
            user = p;
            if ([user.id isEqual: phoneNumber])
            {
                sameUser = YES;
                break;
            }
        }
        if (sameUser == YES)
        {
            [temporary addObject:user];
            [userlistIDOnly addObject:user.id];
        }
    }
    _contacts = temporary;
    [[CKMessageServerConnection sharedInstance] setNewFriend:userlistIDOnly];
}


- (void)viewWillAppear:(BOOL)animated
{
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        UIView *searchBarBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 45)];
        searchBarBackground.backgroundColor = CKClickLightGrayColor;
        UIView *separator = [UIView new];
        [searchBarBackground addSubview:separator];
        separator.backgroundColor = CKClickProfileGrayColor;
        [separator makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(searchBarBackground.width);
            make.height.equalTo(0.5);
            make.bottom.equalTo(searchBarBackground.bottom);
        }];
        
        _searchBar = [[UISearchBar alloc] init];
        _searchBar.showsCancelButton = YES;
        
        _searchBar.translucent = YES;
        _searchBar.delegate = self;
        _searchBar.returnKeyType = UIReturnKeyDone;
        _searchBar.backgroundImage = [CKContactsViewController imageFromColor:CKClickLightGrayColor];
        _searchBar.frame = CGRectMake(0, 0, self.view.bounds.size.width, 64);
        _searchBar.placeholder = @"Поиск";
        
        [searchBarBackground addSubview:_searchBar];
        [_searchBar makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(_searchBar.superview.width);
            make.height.equalTo(_searchBar.superview.height).offset(-1);
            make.top.equalTo(0);
            make.left.equalTo(0);
        }];
        
        self.tableView.tableHeaderView = searchBarBackground;
        _searchBar.text = searchString;
        if (fromContactsToSearch == true) [self loadData];
    });
    if (frPrC.fromProfile == true)
    {
        [self loadContacts];
        [[CKApplicationModel sharedInstance] updateFriends];
    }
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    [[CKApplicationModel sharedInstance] addNewContactToFriends];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateScreenState)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:[UIApplication sharedApplication]];
    [[CKApplicationModel sharedInstance] updateUsers];
}

- (void)updateScreenState
{
    [[CKApplicationModel sharedInstance] addNewContactToFriends];
}

- (void)viewDidAppear:(BOOL)animated
{
    [[CKApplicationModel sharedInstance] addNewContactToFriends];
    if (frPrC.fromProfile == true && fromContactsToSearch == false)
    {
        
        [self reloadData];
    }
    frPrC.fromProfile = false;
}


-(void) viewWillDisappear:(BOOL)animated
{
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    });
}


- (void) inviteContact: (UIButton *) sender
{
    BOOL accessToSMS = true;
    
    UIButton *button = (UIButton*)sender;
    NSInteger index = button.tag;
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    CKPhoneContact *contact = (CKPhoneContact *)[_sections[index][@"arr"] objectAtIndex:indexPath.row];
    _chosenContact = contact;
    if (![MFMessageComposeViewController canSendText]) {
        accessToSMS = false;
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Ошибка!"
                                                                       message:@"Сервисы сообщений не доступны!"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Понятно" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
    }
    if (accessToSMS == true)
    {
        MFMessageComposeViewController* composeVC = [[MFMessageComposeViewController alloc] init];
        composeVC.messageComposeDelegate = self;
        
        composeVC.recipients = @[contact.phoneNumber];
        composeVC.body = @"Я пользуюсь отличной программой для общения'Click'. Присоединяйся, друг!";
        
        [self presentViewController:composeVC animated:YES completion:nil];
    }
}
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result {
    fromContactsToSearch = false;
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void) contactViewController:(CNContactViewController *)viewController didCompleteWithContact:(CNContact *)contact
{
    fromContactsToSearch = false;
    @try {
        deletedWrongPerson = false;
        errorAdding = true;
        CNLabeledValue<CNPhoneNumber*>* labeledValue = contact.phoneNumbers[0];
        NSString *phone = labeledValue.value.stringValue;

        NSString *cleanedString = [[phone componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]] componentsJoinedByString:@""];

        if (contact == nil)
        {
            deletedWrongPerson = true;
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else
        {
            if (cleanedString.length == 11 && ([[cleanedString substringToIndex:1]  isEqual: @"8"])) cleanedString = [cleanedString stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@"7"];
            errorAdding = false;
            for (CKPhoneContact *i in _phoneContacts)
            {
                if ([i.phoneNumber isEqual:cleanedString])
                {
                    errorAdding = true;
                    errorHandling = 2;
                    deletedWrongPerson = true;
                    break;
                }
            }
            if (errorAdding !=true)
            {
                [[CKApplicationModel sharedInstance] checkUserProfile: cleanedString withCallback:^(id model) {
                    
                }];
                deletedWrongPerson = true;
            }
            
        }
        [self dismissViewControllerAnimated:YES completion:nil];
        if (errorAdding == true)
        {
            [[CKContactWrapper sharedInstance] deleteContact:contact completionBlock:^(bool isSuccess, NSError * _Nullable error) {
                if (!isSuccess)
                {
                    NSLog(@"Delete contact failed with error : %@", error.localizedDescription);
                }
            }];
            switch (errorHandling) {
                case 1:
                {
                    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Ошибка добавления!"
                                                                                   message:@"Введенный номер некорректен!"
                                                                            preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Понятно" style:UIAlertActionStyleDefault
                                                                          handler:^(UIAlertAction * action) {}];
                    
                    [alert addAction:defaultAction];
                    [self presentViewController:alert animated:YES completion:nil];
                }
                    break;
                case 2:
                {
                    
                    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Ошибка добавления!"
                                                                                   message:@"Пользователь с таким номером уже есть в ваших контактах!"
                                                                            preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Понятно" style:UIAlertActionStyleDefault
                                                                          handler:^(UIAlertAction * action) {}];
                    
                    [alert addAction:defaultAction];
                    [self presentViewController:alert animated:YES completion:nil];
                }
                    break;
                default:
                    break;
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception.reason);
    }
    @finally {
        if (deletedWrongPerson == false && errorAdding == true)
        {
            [self dismissViewControllerAnimated:YES completion:nil];
            [[CKContactWrapper sharedInstance] deleteContact:contact completionBlock:^(bool isSuccess, NSError * _Nullable error) {
                if (!isSuccess)
                {
                    NSLog(@"Delete contact failed with error : %@", error.localizedDescription);
                }
            }];
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Ошибка добавления!"
                                                                           message:@"Номер не задан!"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Понятно" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
    if (deletedWrongPerson == false && errorAdding == true)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
        [[CKContactWrapper sharedInstance] deleteContact:contact completionBlock:^(bool isSuccess, NSError * _Nullable error) {
            if (!isSuccess)
            {
                NSLog(@"Delete contact failed with error : %@", error.localizedDescription);
            }
        }];
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Ошибка добавления!"
                                                                       message:@"Номер не задан!"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Понятно" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
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



@end
