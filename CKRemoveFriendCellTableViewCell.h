//
//  CKRemoveFriendCellTableViewCell.h
//  click
//
//  Created by Anatoly Mityaev on 29.11.16.
//  Copyright © 2016 Click. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CKRemoveFriendCellTableViewCell : UITableViewCell

@property (nonatomic, readonly) UIButton *removeButton;
@property (nonatomic, assign) BOOL addesToABlackList;

@end
