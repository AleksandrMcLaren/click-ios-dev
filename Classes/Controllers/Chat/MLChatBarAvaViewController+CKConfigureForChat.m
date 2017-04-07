//
//  MLChatBarAvaViewController+CKConfigureForChat.m
//  click
//
//  Created by Aleksandr on 07/04/2017.
//  Copyright © 2017 Click. All rights reserved.
//

#import "MLChatBarAvaViewController+CKConfigureForChat.h"
#import "MLChatLib.h"
#import "Users.h"

@implementation MLChatBarAvaViewController (CKConfigureForChat)

- (void)configureForChat:(CKChatModel *)chat
{
    NSString *avatarUrl = nil;
    
    if(chat.dialog.userAvatarId && chat.dialog.userAvatarId.length)
        avatarUrl = [NSString stringWithFormat:@"%@%@", CK_URL_AVATAR, chat.dialog.userAvatarId];
    
    NSString *name = ((chat.dialog.userName && chat.dialog.userName.length) ? chat.dialog.userName : chat.dialog.userLogin);
    NSString *date = nil;
    NSString *onlineText = @"В сети";
    
    CKUser *user = [[Users sharedInstance] userWithId:chat.dialog.userId];
    
    if(user && user.statusDate)
    {
        date = [NSString stringWithFormat:@"%@ в %@", [[MLChatLib formatterDate_yyyy_MM_dd] stringFromDate:user.statusDate], [[MLChatLib formatterDate_HH_mm] stringFromDate:user.statusDate]];
    }
    
    CGSize nameSize = [name boundingRectWithSize:CGSizeMake(180, CGFLOAT_MAX)
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]}
                                         context:nil].size;
    CGFloat allWidth = 40 + 7 + nameSize.width;
    CGFloat minWidth = 0;
    
    if(user.status == 1)
    {   // в сети
        CGSize textSize = [onlineText boundingRectWithSize:CGSizeMake(180, CGFLOAT_MAX)
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10]}
                                                   context:nil].size;
        minWidth = 40 + 7 + textSize.width;
    }
    else
    {
        if(date)
        {   // не в сети
            minWidth = 135.f;
        }
        else
        {   // никогда не был в сети
            minWidth = 40 + 7 + 20;
        }
    }
    
    if(allWidth < minWidth)
        allWidth = minWidth;

    self.view.frame = CGRectMake(0, 0, allWidth, 40);
    self.avatarUrl = avatarUrl;
    self.titleText = name;
    
    if(user.status == 1)
    {
        self.online = YES;
        self.subtitleText = onlineText;
    }
    else
    {
        self.online = NO;
        self.subtitleText = date;
    }
}

@end
