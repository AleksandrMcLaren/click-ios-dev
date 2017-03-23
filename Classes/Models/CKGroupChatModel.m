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

- (void)loadMessagesWithSuccess:(void (^)(NSArray *messages))success
{
    [[CKMessageServerConnection sharedInstance] getDialogWithId:self.dialog.dialogId page:1 pageSize:INSERT_MESSAGES callback:^(NSDictionary *result) {
        [self recivedMesages:result[@"result"]
                      success:^(NSArray *messages) {
                          
                          if(success)
                              success(messages);
                      }];
    }];
}
    
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
