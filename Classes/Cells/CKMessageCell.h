//
//  CKMessageCell.h
//  click
//
//  Created by Igor Tetyuev on 07.04.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKChatModel.h"

@protocol CKMessageCellDelegate <NSObject>

- (void)attachementButtonPressedWithModel:(CKMessageModel *)model attachNumber:(NSInteger)attachNumber;

@end

@class CKBalloon;
@interface CKMessageCell : UITableViewCell

@property (nonatomic, strong) CKMessageModel *message;
@property (nonatomic, strong) CKBalloon *balloon;
@property (nonatomic, strong) UIImageView *mask;
@property (nonatomic, strong) UILabel *text;
@property (nonatomic, strong) UILabel *time;
@property (nonatomic, assign) BOOL isFirst;
@property (nonatomic, strong) NSMutableArray *attachementButtons;

@property (nonatomic, assign) id<CKMessageCellDelegate>delegate;

@end
