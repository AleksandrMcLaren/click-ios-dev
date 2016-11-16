//
//  UIAlertController+CKSocketMessage.m
//  click
//
//  Created by Дрягин Павел on 15.10.16.
//  Copyright © 2016 Click. All rights reserved.
//

#import "UIAlertController+CKSocketMessage.h"

@implementation UIAlertController (CKSocketMessage)

+(instancetype) newWithSocketResult:(NSDictionary*)result {
    CKStatusCode messageStatus = S_UNDEFINED;
    NSString* title = @"Messme";
    NSString* message = @"Sorry, uncknown error";
    
    if (result) {
        messageStatus = [result socketMessageStatus];
        id messageResult =  [result socketMessageResult];
        NSString* messageAction =  [result socketMessageAction];
        
        title = messageAction;
        message = [NSString stringWithFormat:@"Error result:%@ status:%ld", messageResult, (long)messageStatus];
    }

    switch(messageStatus) {
        case S_ACTIVATION_CODE_ERROR:
            title = @"Проверка кода доступа";
            message = @"Убедитесь в правильности введенного кода доступа и повторите попытку";
            break;
        case S_UNDEFINED:
            message = @"Ошибка соединения с сервером, повыторите попытку позже";
        default:
            break;
    }
    
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:title
                                 message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okButton = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   //Handle your yes please button action here
                               }];
    
    [alert addAction:okButton];

    return alert;
}
@end
