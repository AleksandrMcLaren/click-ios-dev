//
//  CKContactsViewController.h
//  click
//
//  Created by Igor Tetyuev on 21.03.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
@import Contacts;
@import ContactsUI;

@interface CKContactsViewController : UITableViewController<CNContactViewControllerDelegate, UIApplicationDelegate>


@end
