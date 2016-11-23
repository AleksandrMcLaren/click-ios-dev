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
@import MessageUI;
#import "CKAddressBookCell.h"

@interface CKContactsViewController : UITableViewController<CNContactViewControllerDelegate, UIApplicationDelegate, CKAddressBookCellDelegate, MFMessageComposeViewControllerDelegate>

@property (nonatomic, strong) CKPhoneContact *chosenContact;


@end
