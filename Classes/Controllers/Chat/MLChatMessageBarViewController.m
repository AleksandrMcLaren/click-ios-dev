//
//  MLChatMessageBarViewController.m
//  click
//
//  Created by Aleksandr on 02/02/2017.
//  Copyright © 2017 Click. All rights reserved.
//

#import "MLChatMessageBarViewController.h"

@interface MLChatMessageBarViewController () <UITextViewDelegate>

@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) UIButton *photoButton;
@property (nonatomic, strong) UIButton *attachButton;
@property (nonatomic, strong) UIButton *keyboardButton;

@property (nonatomic) CGFloat previousHeight;
@property (nonatomic) CGFloat maxHeight;

@end

@implementation MLChatMessageBarViewController

- (instancetype)init
{
    self = [super init];
    
    if(self)
    {
        self.lineView = [[UIView alloc] init];
        
        self.textView = [[UITextView alloc] init];
        self.textView.textColor = [UIColor blackColor];
        self.textView.scrollsToTop = NO;
        self.textView.font = [UIFont systemFontOfSize:16.0];
        self.textView.text = @"";
        self.textView.layer.borderWidth = 0.54;
        self.textView.layer.cornerRadius = 5.0;
        self.textView.delegate = self;

        self.textView.contentMode = UIViewContentModeRedraw;
        self.textView.dataDetectorTypes = UIDataDetectorTypeNone;
        self.textView.keyboardAppearance = UIKeyboardAppearanceDefault;
        self.textView.keyboardType = UIKeyboardTypeDefault;
        self.textView.returnKeyType = UIReturnKeyDefault;
        self.textView.textAlignment = NSTextAlignmentNatural;
        self.textView.textContainerInset = UIEdgeInsetsMake(6, self.textView.textContainerInset.left, 6, self.textView.textContainerInset.right);
        
        self.maxHeight = self.textView.font.lineHeight * 4 + self.textView.textContainerInset.top + self.textView.textContainerInset.bottom + 14;
        
        self.sendButton = [[UIButton alloc] init];
        [self.sendButton setImage:[UIImage imageNamed:@"plane"]
                         forState:UIControlStateNormal];
        [self.sendButton addTarget:self
                            action:@selector(sendTapped)
                  forControlEvents:UIControlEventTouchUpInside];
        
        self.photoButton = [[UIButton alloc] init];
        [self.photoButton setImage:[UIImage imageNamed:@"menu_cam_gray"]
                         forState:UIControlStateNormal];
        [self.photoButton addTarget:self
                            action:@selector(photoTapped)
                  forControlEvents:UIControlEventTouchUpInside];
        
        self.attachButton = [[UIButton alloc] init];
        [self.attachButton setImage:[UIImage imageNamed:@"menu_menu_gray"]
                          forState:UIControlStateNormal];
        [self.attachButton addTarget:self
                             action:@selector(attachTapped)
                   forControlEvents:UIControlEventTouchUpInside];
        
        self.keyboardButton = [[UIButton alloc] init];
        [self.keyboardButton setImage:[UIImage imageNamed:@"menu_keypad_gray"]
                           forState:UIControlStateNormal];
        [self.keyboardButton addTarget:self
                              action:@selector(keyboardTapped)
                    forControlEvents:UIControlEventTouchUpInside];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithHue:0.00 saturation:0.00 brightness:0.97 alpha:1.00];
    self.lineView.backgroundColor = [UIColor colorWithHue:0.00 saturation:0.00 brightness:0.66 alpha:1.00];
    
    self.textView.backgroundColor = [UIColor whiteColor];
    self.textView.layer.borderColor = [UIColor colorWithHue:0.67 saturation:0.02 brightness:0.80 alpha:1.00].CGColor;
    
    [self.view addSubview:self.lineView];
    [self.view addSubview:self.textView];
    [self.view addSubview:self.sendButton];
    [self.view addSubview:self.photoButton];
    [self.view addSubview:self.attachButton];
    [self.view addSubview:self.keyboardButton];
    
    self.keyboardButton.hidden = YES;
    [self updateSendButton];
    
    [self.view setNeedsUpdateConstraints];
}

- (void)updateViewConstraints
{
    self.lineView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 0.5);
    
    CGFloat buttonWidth = 50.f;
    CGFloat buttonHeight = 45;
    CGFloat top = 7.f;
    
    [self.textView updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.left).offset(buttonWidth);
        make.right.equalTo(self.view.right).offset(-buttonWidth);
        make.top.equalTo(self.view.top).offset(top);
        make.bottom.equalTo(self.view.bottom).offset(-top);
    }];
    
    [self.sendButton makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(buttonWidth);
        make.height.equalTo(buttonHeight);
        make.bottom.equalTo(self.view.bottom);
        make.right.equalTo(self.view.right);
    }];
    
    [self.photoButton makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(buttonWidth);
        make.height.equalTo(buttonHeight);
        make.bottom.equalTo(self.view.bottom);
        make.right.equalTo(self.view.right);
    }];
    
    [self.attachButton makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(buttonWidth);
        make.height.equalTo(buttonHeight);
        make.bottom.equalTo(self.view.bottom);
        make.left.equalTo(self.view.left);
    }];
    
    [self.keyboardButton makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(buttonWidth);
        make.height.equalTo(buttonHeight);
        make.bottom.equalTo(self.view.bottom);
        make.left.equalTo(self.view.left);
    }];
    
    [super updateViewConstraints];
}

- (void)updateSendButton
{
    if(self.textView.text.length)
        self.sendButton.hidden = NO;
    else
        self.sendButton.hidden = YES;
    
    self.photoButton.hidden = !self.sendButton.hidden;
}

- (BOOL)textEditing
{
    return self.textView.isFirstResponder;
}

- (void)endEditing
{
    [self showAttachButton:YES];
}

- (void)showAttachButton:(BOOL)show
{
    self.attachButton.hidden = !show;
    self.keyboardButton.hidden = show;
}

- (void)clearText
{
    self.textView.text = @"";
    [self updateHeightIfNeeded:self.textView.text];
    [self updateSendButton];
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [self showAttachButton:YES];
    
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSMutableString *updatedText = [[NSMutableString alloc] initWithString:textView.text];
    [updatedText replaceCharactersInRange:range withString:text];
    
    [self updateHeightIfNeeded:updatedText];
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self updateSendButton];
}

#pragma mark - Calculate height

- (void)updateHeightIfNeeded:(NSString *)text
{
    CGFloat needsHeight = [self heightTextViewText:text] + 14.f;
    
    if(self.previousHeight != needsHeight)
    {
        if(needsHeight <= self.maxHeight)
        {
            [self.delegate chatMessageBarViewControllerNeedsHeight:needsHeight];
          //  self.textView.scrollEnabled = NO;
        }
        else
        {
          //  self.textView.scrollEnabled = YES;
        }
        
        self.previousHeight = needsHeight;
    }
}

- (CGFloat)heightTextViewText:(NSString *)text
{
    CGFloat width = self.textView.bounds.size.width - 2.0 * self.textView.textContainer.lineFragmentPadding;
    
    NSDictionary *options = @{NSFontAttributeName:self.textView.font};
    CGRect boundingRect = [text boundingRectWithSize:CGSizeMake(width, NSIntegerMax)
                                             options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                          attributes:options
                                             context:nil];

    return self.textView.textContainerInset.top + boundingRect.size.height + self.textView.textContainerInset.bottom + 1;
}


#pragma mark - Actions

- (void)sendTapped
{
    NSString *text = [self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (text.length == 0)
        return;

    [self.delegate chatMessageBarViewControllerTappedSend:text];
}

- (void)photoTapped
{
    
}

- (void)attachTapped
{
    [self showAttachButton:NO];
    [self.delegate chatMessageBarTappedAttachButton];
    [self.textView resignFirstResponder];
}

- (void)keyboardTapped
{
    [self showAttachButton:YES];
    [self.textView becomeFirstResponder];
}

@end
