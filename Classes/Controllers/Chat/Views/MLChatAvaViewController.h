//
//  MLChatAvaViewController.h
//  click
//
//  Created by Aleksandr on 06/02/2017.
//  Copyright © 2017 Click. All rights reserved.
//

#import "MLChatMessage.h"

@interface MLChatAvaViewController : UIViewController

@property (nonatomic, readonly) CGFloat diameter;

- (void)setImageUrl:(NSString *)imageUrl name:(NSString *)name;

@end
