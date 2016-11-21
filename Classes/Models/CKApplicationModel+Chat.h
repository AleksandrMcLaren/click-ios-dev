//
//  CKApplicationModel+Chat.h
//  click
//
//  Created by Дрягин Павел on 20.11.16.
//  Copyright © 2016 Click. All rights reserved.
//

#import "CKApplicationModel.h"

@interface CKApplicationModel (Chat)

-(void)startPrivateChat:(id)user;
-(void)startMultipleChat:(NSArray *) userIds;
-(void)restartRecentChat:(id)user;
@end
