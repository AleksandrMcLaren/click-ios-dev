//
//  MLChatMessageBarViewController.m
//  click
//
//  Created by Aleksandr on 02/02/2017.
//  Copyright © 2017 Click. All rights reserved.
//

#import "MLChatMessageBarViewController.h"

@interface MLChatMessageBarViewController () <UITextViewDelegate>

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, assign) CGFloat previousHeight;

@end

@implementation MLChatMessageBarViewController

- (instancetype)init
{
    self = [super init];
    
    if(self)
    {
        self.textView = [[UITextView alloc] init];
        self.textView.textColor = [UIColor blackColor];
      //  self.textView.scrollIndicatorInsets = UIEdgeInsetsMake(7, 7, 7, 7);
        self.textView.scrollsToTop = NO;
        self.textView.font = [UIFont systemFontOfSize:16.0];
        self.textView.text = @"";
        self.textView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        self.textView.layer.borderWidth = 1.0;
        self.textView.layer.cornerRadius = 4.0;
        self.textView.delegate = self;
        self.textView.scrollIndicatorInsets = UIEdgeInsetsMake(self.textView.layer.cornerRadius, 0.0f, self.textView.layer.cornerRadius, 0.0f);
//        self.textView.textContainerInset = UIEdgeInsetsMake(4.0f, 2.0f, 4.0f, 2.0f);
//        self.textView.contentInset = UIEdgeInsetsMake(1.0f, 0.0f, 1.0f, 0.0f);
        
        self.textView.contentMode = UIViewContentModeRedraw;
        self.textView.dataDetectorTypes = UIDataDetectorTypeNone;
        self.textView.keyboardAppearance = UIKeyboardAppearanceDefault;
        self.textView.keyboardType = UIKeyboardTypeDefault;
        self.textView.returnKeyType = UIReturnKeyDefault;
        self.textView.textAlignment = NSTextAlignmentNatural;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorFromHexString:@"#f8f8f8"];
    self.textView.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.textView];
    
    [self.view setNeedsUpdateConstraints];
}

- (void)updateViewConstraints
{
    [self.textView updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.left).offset(32);
        make.right.equalTo(self.view.right).offset(-64);
        make.top.equalTo(self.view.top).offset(8);
        make.bottom.equalTo(self.view.bottom).offset(-8);
    }];
    
    [super updateViewConstraints];
}

//- (void)layoutSubviews
//{
//    CGSize boundsSize = self.view.frame.size;
//    NSInteger top = 10;
//    NSInteger left = 50;
//    NSInteger right = 50;
//
//    self.textView.frame = CGRectMake(left, top, boundsSize.width - left - right, boundsSize.height - top * 2);
//}

//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//
//    [self layoutSubviews];
//    [self setNeedsHeight];
//}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
   // [self.delegate chatMessagePanelDidBeginEditingTextView:textView];
    
    if(textView.text.length)
        [self endEditing:NO];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSMutableString *updatedText = [[NSMutableString alloc] initWithString:textView.text];
    [updatedText replaceCharactersInRange:range withString:text];
    
    CGFloat needsHeight = [self heightTextViewText:updatedText] + 16.f;
    
    if(self.previousHeight != needsHeight)
    {
        [self.delegate chatMessageBarNeedsHeight:needsHeight];
        self.previousHeight = needsHeight;
        
//        if(self.view.frame.size.height < needsHeight)
//            textView.scrollEnabled = YES;
//        else
//            textView.scrollEnabled = NO;
    }
    
    
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    CGFloat needsHeight = [self heightTextViewText:textView.text] + 16.f;
    
    if(self.previousHeight != needsHeight)
    {
     //   [self.delegate chatMessageBarNeedsHeight:needsHeight];
        
//        if(self.view.frame.size.height < needsHeight)
//            textView.scrollEnabled = YES;
//        else
//            textView.scrollEnabled = NO;
    }
    
   // self.previousHeight = needsHeight;
    
//    if(textView.text.length)
//        [self endEditing:NO];
//    else
//        [self endEditing:YES];
    
   // [self.delegate chatMessagePanelTextViewDidChange:textView];
}


#pragma mark -

- (CGFloat)heightTextViewText:(NSString *)text
{
    CGFloat width = self.textView.bounds.size.width - 2.0 * self.textView.textContainer.lineFragmentPadding;
    
    NSDictionary *options = @{NSFontAttributeName:self.textView.font};
    CGRect boundingRect = [text boundingRectWithSize:CGSizeMake(width, NSIntegerMax)
                                             options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                          attributes:options context:nil];
    
    return self.textView.textContainerInset.top + boundingRect.size.height + self.textView.textContainerInset.bottom;
}

- (void)setNeedsHeight
{
    CGFloat needsHeight = [self needsHeightTextView:self.textView];
    self.previousHeight = needsHeight;
    //[self.delegate chatMessagePanelNeedsHeight:needsHeight animation:NO];
}

- (CGFloat)needsHeightTextView:(UITextView *)textView
{
    CGFloat width = textView.bounds.size.width - 2.0 * textView.textContainer.lineFragmentPadding - textView.textContainerInset.left - self.textView.textContainerInset.right;
    CGRect boundingRect = [textView.text boundingRectWithSize:CGSizeMake(width, NSIntegerMax)
                                                                options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                             attributes:@{NSFontAttributeName:textView.font}
                                                                context:nil];
    
    return textView.textContainerInset.top + boundingRect.size.height + textView.textContainerInset.bottom;
    
    
    CGSize size = [textView sizeThatFits:CGSizeMake(textView.contentSize.width, FLT_MAX)];

    return roundf(20 + size.height);
}

- (void)endEditing:(BOOL)endEditing
{
//    if(self.messageTextView.text.length)
//        self.buttonsViewController.type = DARChatButtonsEnterMessage;
//    else
//        self.buttonsViewController.type = DARChatButtonsDefault;
    
    CGFloat needsHeight = [self needsHeightTextView:self.textView];
    
    if(self.previousHeight != needsHeight)
    {
       // [self.delegate chatMessagePanelNeedsHeight:needsHeight animation:YES];
        self.previousHeight = needsHeight;
    }
}

#pragma mark - DARChatButtonsViewControllerDelegate

- (void)chatButtonsTappedMessage
{
    NSString *text = [self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (text.length == 0)
        return;

    [self.delegate chatMessagePanelTappedMessageButtonWithTextView:self.textView];
}

- (void)chatButtonsTappedPlus
{
    [self.delegate chatMessagePanelTappedPlusButton];
}

@end
