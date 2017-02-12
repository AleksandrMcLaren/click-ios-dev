//
//  MLChatAvaViewController.h
//  click
//
//  Created by Aleksandr on 06/02/2017.
//  Copyright © 2017 Click. All rights reserved.
//

#import "MLChatMessage.h"

@interface MLChatAvaViewController : UIViewController

@property (nonatomic, strong) MLChatMessage *message;

@property (nonatomic, readonly) CGFloat diameter;

@end
