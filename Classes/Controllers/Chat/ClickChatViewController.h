//
//  ClickChatViewController.h
//  click
//
//  Created by Александр on 16.03.17.
//  Copyright © 2017 Click. All rights reserved.
//

#import "MLChatViewController.h"
#import "CKChatModel.h"

@interface ClickChatViewController : MLChatViewController

- (id)initWithChat:(CKChatModel *)chat;

@end
