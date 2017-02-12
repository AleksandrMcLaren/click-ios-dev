//
//  MLChatCellContentViewController.h
//  click
//
//  Created by Aleksandr on 07/02/2017.
//  Copyright © 2017 Click. All rights reserved.
//

#import "MLChatMessage.h"

@protocol MLChatCellContentViewControllerDelegate;

@interface MLChatCellContentViewController : UIViewController

@property (nonatomic, weak) id<MLChatCellContentViewControllerDelegate> delegate;
@property (nonatomic, strong) MLChatMessage *message;

@property (nonatomic, readonly) CGFloat maxWidth;

@end


@protocol MLChatCellContentViewControllerDelegate <NSObject>

@required
- (void)chatCellContentViewControllerNeedsSize:(CGSize)size;

@end



