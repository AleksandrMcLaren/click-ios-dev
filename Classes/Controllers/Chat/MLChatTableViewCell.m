//
//  MLChatTableViewCell.m
//  click
//
//  Created by Aleksandr on 03/02/2017.
//  Copyright © 2017 Click. All rights reserved.
//

#import "MLChatTableViewCell.h"

@interface MLChatTableViewCell ()

@end

@implementation MLChatTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if(self)
    {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return self;
}

@end
