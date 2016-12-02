//
//  CKAddressBookCell.h
//  click
//
//  Created by Igor Tetyuev on 29.03.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CKAddressBookCellDelegate;

@interface CKAddressBookCell : UITableViewCell

@property (nonatomic, readonly) UIButton *inviteButton;
@property (nonatomic, weak) id<CKAddressBookCellDelegate> delegate;
- (void)invite;

@end

@protocol CKAddressBookCellDelegate <NSObject>

- (void) inviteContact: (UIButton *) sender;

@end
