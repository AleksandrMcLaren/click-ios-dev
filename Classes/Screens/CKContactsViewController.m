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
#import "CKChatsViewController.h"

@import MessageUI;

@interface CKContactsViewController () <MFMessageComposeViewControllerDelegate, UISearchBarDelegate>

@end

@implementation CKContactsViewController
{
    NSArray *_phoneContacts;
    NSArray *_fullContacts;
    
    BOOL errorAdding;
    int errorHandling;
    BOOL existedPerson;
    BOOL deletedWrongPerson;
    
    NSArray *_sections;
    
    UISearchBar *_searchBar;
    CGFloat _keyboardHeight;
}

- (instancetype)init
{
    if (self = [super initWithStyle:UITableViewStylePlain])
    {
        self.title = @"Контакты";
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add)];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardFrameChanged:)
                                                 name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateScreenState)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:[UIApplication sharedApplication]];
    deletedWrongPerson = false;
    errorAdding = false;
    errorHandling = 0;
    existedPerson = false;
    self.tableView.backgroundColor = CKClickLightGrayColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
//    self.refreshControl = [[UIRefreshControl alloc] init];
//    self.refreshControl.tintColor = [UIColor darkGrayColor];
//    [self.refreshControl addTarget:self
//                            action:@selector(reloadData)
//                  forControlEvents:UIControlEventValueChanged];
    
    _searchBar = [[UISearchBar alloc] init];
    _searchBar.showsCancelButton = NO;
    _searchBar.translucent = YES;
    _searchBar.barTintColor = [UIColor colorFromHexString:@"#f5f4f3"];
    _searchBar.delegate = self;
    _searchBar.returnKeyType = UIReturnKeyDone;
    _searchBar.backgroundImage = [CKChatsViewController imageFromColor:CKClickLightGrayColor];
    _searchBar.frame = CGRectMake(0, 0, self.view.bounds.size.width, 64);
    _searchBar.placeholder = @"Поиск";
    
    UIView *searchBarBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 45)];
    [searchBarBackground addSubview:_searchBar];
    
    [_searchBar makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(_searchBar.superview.width);
        make.height.equalTo(_searchBar.superview.height).offset(-1);
        make.top.equalTo(0);
        make.left.equalTo(0);
    }];
    
    self.tableView.tableHeaderView = searchBarBackground;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    
    __weak typeof(self) weakSelf = self;
    [[Users sharedInstance] addNewContactToFriends:^{
        
        if(weakSelf)
            [weakSelf reloadData];
    }];
}

- (void)keyboardFrameChanged:(NSNotification *)notification
{
    CGRect keyboardRect = [self.view.window convertRect:[[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue] toView:self.view];
    keyboardRect = CGRectIntersection(keyboardRect, self.view.bounds);
    CGFloat keyboardHeight = CGRectIntersection(keyboardRect, self.view.bounds).size.height;
    CGFloat bottomOffset = CGRectGetHeight(self.tabBarController.tabBar.frame);
    
    self.tableView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.superview.bounds.size.height - keyboardHeight + (keyboardHeight ? bottomOffset : 0));
}

- (void)reloadData
{
    NSMutableArray* sections = [NSMutableArray array];
    
    NSMutableArray *tmpFullContacts = [NSMutableArray new];
    [tmpFullContacts  addObjectsFromArray:[[Users sharedInstance] fullContacts]];
    NSMutableArray *unsortedFriends = [NSMutableArray new];
    [unsortedFriends addObjectsFromArray:[[Users sharedInstance] users]];
    
    if(_searchBar.text && _searchBar.text.length)
    {
        NSMutableArray *needsRemoveObjects = [[NSMutableArray alloc] init];
        NSString *text = [_searchBar.text lowercaseString];
        
        for (CKPhoneContact *p in tmpFullContacts)
        {
            NSString *fullText = [[NSString stringWithFormat:@"%@ %@", p.fullname, p.phoneNumber] lowercaseString];
            
            if([fullText rangeOfString:text].location == NSNotFound)
                [needsRemoveObjects addObject:p];
        }
        
        if(needsRemoveObjects.count)
        {
            [tmpFullContacts removeObjectsInArray:needsRemoveObjects];
            [needsRemoveObjects removeAllObjects];
        }
        
        for (CKUser *i in unsortedFriends)
        {
            NSString *fullText = [[NSString stringWithFormat:@"%@ %@ %@ %@", i.name, i.surname, i.login, i.id] lowercaseString];
            
            if([fullText rangeOfString:text].location == NSNotFound)
                [needsRemoveObjects addObject:i];
        }
        
        if(needsRemoveObjects.count)
        {
            [unsortedFriends removeObjectsInArray:needsRemoveObjects];
        }
    }
    
    _fullContacts = tmpFullContacts;
    NSMutableArray *tmpPhoneContacts = [_fullContacts mutableCopy];
    
    for (CKUser *i in unsortedFriends)
    {
        for (CKPhoneContact *p in _fullContacts)
        {
            if ([i.id isEqual:p.phoneNumber])
            {
                i.name = p.name;
                i.surname = p.surname;
                [tmpPhoneContacts removeObject:p];
                break;
            }
        }
    }

    NSArray *sortedFriends = [unsortedFriends sortedArrayUsingComparator:^NSComparisonResult(CKUser *obj1, CKUser *obj2) {
        NSString *str1 = obj1.surname.length?obj1.surname:obj1.name;
        NSString *str2 = obj2.surname.length?obj2.surname:obj2.name;
        return [str1 compare:str2 options: NSCaseInsensitiveSearch];
        
    }];
    
    [sections addObject:@{@"title":@"friends", @"arr":sortedFriends}];

    _phoneContacts = [tmpPhoneContacts sortedArrayUsingComparator:^NSComparisonResult(CKUser *obj1, CKUser *obj2) {
        NSString *str1 = obj1.surname.length?obj1.surname:obj1.name;
        NSString *str2 = obj2.surname.length?obj2.surname:obj2.name;
        return [str1 compare:str2 options: NSCaseInsensitiveSearch];
    }];
    
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
    
    [self.refreshControl endRefreshing];
    [self.tableView reloadData];
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
        CKUser *friend = (CKUser *)[arr objectAtIndex:indexPath.row];
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
        
        cell.inviteButton.tag = indexPath.section;
        [cell.inviteButton addTarget:self
                              action: @selector(inviteContact:)
                    forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }
    return nil;
}

- (void)updateScreenState
{
    __weak typeof(self) weakSelf = self;
    [[Users sharedInstance] addNewContactToFriends:^{
        
        if(weakSelf)
            [weakSelf reloadData];
    }];
}


-(void) viewWillDisappear:(BOOL)animated
{
    //[super viewWillDisappear:animated];
    [_searchBar resignFirstResponder];
}

- (void) inviteContact: (UIButton *) sender
{
    UIButton *button = (UIButton*)sender;
    NSInteger index = button.tag;
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    CKPhoneContact *contact = (CKPhoneContact *)[_sections[index][@"arr"] objectAtIndex:indexPath.row];
    if (![MFMessageComposeViewController canSendText]) {

        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Ошибка!"
                                                                       message:@"Сервисы сообщений не доступны!"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Понятно" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        [alert addAction:defaultAction];
    }
    else
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

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) contactViewController:(CNContactViewController *)viewController didCompleteWithContact:(CNContact *)contact
{
    //    NSString *firstName =  contact.givenName;
    //    NSString *lastName =  contact.familyName;
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
        else /*if (cleanedString.length == 11 && ([[cleanedString substringToIndex:1]  isEqual: @"8"] || [[cleanedString substringToIndex:1]  isEqual: @"7"]))*/
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
                //                NSArray *friends = [[CKApplicationModel sharedInstance] friends];
                //                for (CKUser *i in friends)
                //                {
                //                    if ([i.id isEqual:cleanedString])
                //                    {
                //                        errorAdding = true;
                //                        errorHandling = 2;
                //                        deletedWrongPerson = true;
                //                        break;
                //                    }
                //                }
                //                if (errorAdding !=true)
                //                {
                [[Users sharedInstance] checkUserProfile: cleanedString];
                deletedWrongPerson = true;
                //   }
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

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self reloadData];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar_
{
    [_searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar_
{
    [_searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar_
{
    _searchBar.text = @"";
    [_searchBar resignFirstResponder];
    [self reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar_
{
    [_searchBar resignFirstResponder];
}

@end
