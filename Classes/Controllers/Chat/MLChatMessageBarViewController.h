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

- (void)endEditing:(BOOL)endEditing;
- (void)setNeedsHeight;

@end


@protocol MLChatMessageBarViewControllerDelegate <NSObject>

@required
- (void)chatMessageBarNeedsHeight:(CGFloat)height;

- (void)chatMessagePanelDidBeginEditingTextView:(UITextView *)textView;
- (void)chatMessagePanelTextViewDidChange:(UITextView *)textView;
- (void)chatMessagePanelTappedMessageButtonWithTextView:(UITextView *)textView;
- (void)chatMessagePanelTappedPlusButton;

@end
