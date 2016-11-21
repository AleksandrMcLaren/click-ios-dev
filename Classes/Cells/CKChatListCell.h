//
//  CKChatListCell.h
//  click
//
//  Created by Igor Tetyuev on 03.04.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKAvatarView.h"
#import "SWTableViewCell.h"


@interface CKChatListCell : SWTableViewCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@property (nonatomic, readonly) CKAvatarView *avatar;
@property (nonatomic, readonly) UILabel *title;
@property (nonatomic, readonly) UILabel *subtitle;
@property (nonatomic, readonly) UILabel *activity;
@property (nonatomic, readonly) UILabel *unreadCount;

@property (nonatomic, strong) CKDialogListEntryModel *model;
@property (nonatomic, assign) BOOL isArchive;

- (NSString *)letterNameWithName:(NSString *)name surname:(NSString *)surname login:(NSString *)login;


@end
