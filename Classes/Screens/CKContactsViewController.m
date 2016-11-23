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
    
    CKFriendProfileController *frPrC;
}

- (instancetype)init
{
    frPrC = [CKFriendProfileController new];
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
    [self reloadData];
}


- (void)reloadData
{
    _contacts = [NSMutableArray array];
    _fullContacts = [[CKApplicationModel sharedInstance] fullContacts];
    //    NSMutableArray *fc = [NSMutableArray new];
    //    [fc addObjectsFromArray:_fullContacts];
    
    // fill with friends
    NSMutableArray *unsortedFriends = [NSMutableArray new];
    [unsortedFriends addObjectsFromArray:[[CKApplicationModel sharedInstance] friends]];
    
    for (CKUserModel *i in unsortedFriends)
    {
        NSString *phoneNumber = [NSString new];
        //        CKUserModel *friend = i;
        for (CKPhoneContact *p in _fullContacts)
        {
            phoneNumber = p.phoneNumber;
            if (phoneNumber.length == 11 && ([[phoneNumber substringToIndex:1]  isEqual: @"8"])) phoneNumber = [phoneNumber stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@"7"];
            //            CKPhoneContact *contact = p;
            if ([i.id isEqual:phoneNumber])
            {
                //i.name = [i. name stringByReplacingCharactersInRange:NSMakeRange(0, i.name.length) withString:p.name];
                i.name = p.name;
                i.surname = p.surname;
                break;
            }
        }
    }
    NSArray *sortedFriends = [unsortedFriends sortedArrayUsingComparator:^NSComparisonResult(CKUserModel *obj1, CKUserModel *obj2) {
        NSString *str1 = obj1.surname.length?obj1.surname:obj1.name;
        NSString *str2 = obj2.surname.length?obj2.surname:obj2.name;
        return [str1 compare:str2 options: NSCaseInsensitiveSearch];
        
    }];
    NSMutableArray *contactsWithoutFriends = [NSMutableArray new];
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
        //        NSString *str = _sections[1][@"arr"][indexPath.row];
        //        CKPhoneContact *contact = (CKPhoneContact *)[_sections[1][@"arr"] objectAtIndex:indexPath.row];
        //        _chosenContact = contact;
        //
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
        //cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //cell.userInteractionEnabled = false;
        if (!cell) {
            cell = [CKAddressBookCell new];
        }
        CKPhoneContact *contact = (CKPhoneContact *)[arr objectAtIndex:indexPath.row];
        NSAttributedString *s = [NSMutableAttributedString withName:contact.name surname:contact.surname size:16.0];
        cell.textLabel.attributedText = s;
        //cell.delegate = self;
        //_chosenContact = contact;
        chosenSection = indexPath.section;
        //NSArray * arr = [NSArray arrayWithObject:@1];
        cell.inviteButton.tag = indexPath.section;
        
        [cell.inviteButton addTarget:self
                              action: @selector(inviteContact:)
                    forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }
    return nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    if (frPrC.fromProfile == true)
    {
        [[CKApplicationModel sharedInstance] updateFriends];
    }
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    [[CKApplicationModel sharedInstance] addNewContactToFriends];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateScreenState)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:[UIApplication sharedApplication]];
}

- (void)updateScreenState
{
    [[CKApplicationModel sharedInstance] addNewContactToFriends];
}

- (void)viewDidAppear:(BOOL)animated
{
    [[CKApplicationModel sharedInstance] addNewContactToFriends];
    if (frPrC.fromProfile == true)
    {
        [self reloadData];
    }
    frPrC.fromProfile = false;
}

-(void) viewWillDisappear:(BOOL)animated
{
    //[super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) inviteContact: (UIButton *) sender
{
    BOOL accessToSMS = true;
    
    UIButton *button = (UIButton*)sender; // convert sender to UIButton
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
        
        // Configure the fields of the interface.
        composeVC.recipients = @[contact.phoneNumber];
        composeVC.body = @"Я пользуюсь отличной программой для общения'Click'. Присоединяйся, друг!";
        
        // Present the view controller modally.
        [self presentViewController:composeVC animated:YES completion:nil];
    }
}
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result {
    // Check the result or perform other tasks.    // Dismiss the message compose view controller.
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
        //        for (CNLabeledValue<CNPhoneNumber*>* labeledValue in contact.phoneNumbers)
        //        {
        //            if ([labeledValue.label isEqualToString:CNLabelPhoneNumberMobile])
        //            {
        //                phone = labeledValue.value.stringValue;
        //                break;
        //            }
        //        }
        NSString *cleanedString = [[phone componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]] componentsJoinedByString:@""];
        /*
         The digits are a private variable. For getting a phone number:
         
         CNLabeledValue<CNPhoneNumber*>* labeledValue = contact.phoneNumbers[0];
         NSString *phone = labeledValue.value.stringValue;
         E.g. to get a mobile number:
         
         // get mobile
         NSString *phone = nil;
         for (CNLabeledValue<CNPhoneNumber*>* labeledValue in contact.phoneNumbers)
         {
         if ([labeledValue.label isEqualToString:CNLabelPhoneNumberMobile])
         {
         phoneNumber = labeledValue.value.stringValue;
         break;
         }
         }
         */
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
                //                for (CKUserModel *i in friends)
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
                [[CKApplicationModel sharedInstance] checkUserProfile: cleanedString];
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

//- (void)applicationDidEnterBackground:(UIApplication *)application
//{
//    UIApplicationState state = [application applicationState];
//    if (state == UIApplicationStateInactive) {
//        NSLog(@"Sent to background by locking screen");
//    } else if (state == UIApplicationStateBackground) {
//        NSLog(@"Sent to background by home button/switching to other app");
//    }
//}



@end
