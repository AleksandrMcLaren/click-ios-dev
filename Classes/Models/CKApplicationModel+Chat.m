//
//  CKApplicationModel+Chat.m
//  click
//
//  Created by Дрягин Павел on 20.11.16.
//  Copyright © 2016 Click. All rights reserved.
//

#import "CKApplicationModel+Chat.h"
#import "CKDialogChatController.h"

@implementation CKApplicationModel (Chat)

-(void)startPrivateChat:(id)user{
    
    //    ChatView *chatView = [[ChatView alloc] initWith:dictionary];
    //    chatView.hidesBottomBarWhenPushed = YES;
    //    [self.navigationController pushViewController:chatView animated:YES];
    if ([user isKindOfClass:[CKDialogListEntryModel class]]) {
        CKDialogListEntryModel *model = (CKDialogListEntryModel*) user;
        
        CKDialogChatController *ctl = [[CKDialogChatController alloc] initWithUserId:model.userId];
        [self.mainController.currentController.navigationController pushViewController:ctl animated:YES];
    }
    

}


-(void)startMultipleChat:(NSArray *) userIds{
    
}

-(void)restartRecentChat:(id)user{
}

@end
