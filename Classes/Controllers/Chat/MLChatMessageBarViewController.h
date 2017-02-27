//
//  MLChatMessageListViewController.h
//  click
//
//  Created by Aleksandr on 02/02/2017.
//  Copyright © 2017 Click. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MLChatMessageBarViewControllerDelegate;

@interface MLChatMessageBarViewController : UIViewController

@property (nonatomic, weak) id <MLChatMessageBarViewControllerDelegate> delegate;

@property (nonatomic, readonly) BOOL textEditing;

- (void)clearText;
- (void)endEditing;

@end


@protocol MLChatMessageBarViewControllerDelegate <NSObject>

@required
- (void)chatMessageBarViewControllerNeedsHeight:(CGFloat)height;
- (void)chatMessageBarViewControllerTappedSend:(NSString *)text;
- (void)chatMessageBarTappedAttachButton;

@end
