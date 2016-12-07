//
//  CKGroupChatModel.m
//  click
//
//  Created by Igor Tetyuev on 23.04.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKGroupChatModel.h"
#import "utilities.h"

@implementation CKGroupChatModel

-(void)loadMessages{
    [[CKMessageServerConnection sharedInstance] getDialogWithId:self.dialog.dialogId page:1 pageSize:INSERT_MESSAGES callback:^(NSDictionary *result) {
        for (NSDictionary *message in result[@"result"]){
            [self saveMessage:message];
        }
    }];
}
    
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
