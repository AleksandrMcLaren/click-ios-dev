//  Created by Дрягин Павел
//  Copyright © 2016 Click. All rights reserved.



#import <Foundation/Foundation.h>

#import "CKApplicationModel.h"


@interface CallHistory : NSObject


+ (void)createItem:(NSString *)userId recipientId:(NSString *)recipientId text:(NSString *)text details:(id<SINCallDetails>)details;

+ (void)deleteItem:(NSString *)objectId;

@end

