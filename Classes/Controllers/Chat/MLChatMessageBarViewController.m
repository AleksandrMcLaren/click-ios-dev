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
        self.textView.layer.borderColor = [UIColor colorWithRed:0.84 green:0.84 blue:0.85 alpha:1.00].CGColor;
        self.textView.layer.borderWidth = 1.0;
        self.textView.layer.cornerRadius = 4.0;
        self.textView.delegate = self;

        self.textView.contentMode = UIViewContentModeRedraw;
        self.textView.dataDetectorTypes = UIDataDetectorTypeNone;
        self.textView.keyboardAppearance = UIKeyboardAppearanceDefault;
        self.textView.keyboardType = UIKeyboardTypeDefault;
        self.textView.returnKeyType = UIReturnKeyDefault;
        self.textView.textAlignment = NSTextAlignmentNatural;
        
        self.maxHeight = self.textView.font.lineHeight * 4 + self.textView.textContainerInset.top + self.textView.textContainerInset.bottom + 16;
        
        self.sendButton = [[UIButton alloc] init];
        [self.sendButton setImage:[UIImage imageNamed:@"plane"]
                         forState:UIControlStateNormal];
        [self.sendButton addTarget:self
                            action:@selector(sendTapped)
                  forControlEvents:UIControlEventTouchUpInside];
        
        self.photoButton = [[UIButton alloc] init];
        [self.photoButton setImage:[UIImage imageNamed:@"tab_camera"]
                         forState:UIControlStateNormal];
        [self.photoButton addTarget:self
                            action:@selector(photoTapped)
                  forControlEvents:UIControlEventTouchUpInside];
        
        self.attachButton = [[UIButton alloc] init];
        [self.attachButton setImage:[UIImage imageNamed:@"tab_clip"]
                          forState:UIControlStateNormal];
        [self.attachButton addTarget:self
                             action:@selector(attachTapped)
                   forControlEvents:UIControlEventTouchUpInside];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorFromHexString:@"#f8f8f8"];
    self.lineView.backgroundColor = [UIColor colorWithRed:0.82 green:0.85 blue:0.86 alpha:1.00];
    self.textView.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.lineView];
    [self.view addSubview:self.textView];
    [self.view addSubview:self.sendButton];
    [self.view addSubview:self.photoButton];
    [self.view addSubview:self.attachButton];
    
    [self updateSendButton];
    [self.view setNeedsUpdateConstraints];
}

- (void)updateViewConstraints
{
    self.lineView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 1);
    
    CGFloat buttonWidth = 50.f;
    CGFloat buttonHeight = 32.f;
    
    [self.textView updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.left).offset(buttonWidth);
        make.right.equalTo(self.view.right).offset(-buttonWidth);
        make.top.equalTo(self.view.top).offset(8);
        make.bottom.equalTo(self.view.bottom).offset(-8);
    }];
    
    [self.sendButton makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(buttonWidth);
        make.height.equalTo(buttonHeight);
        make.bottom.equalTo(self.view.bottom).offset(-8);
        make.right.equalTo(self.view.right);
    }];
    
    [self.photoButton makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(buttonWidth);
        make.height.equalTo(buttonHeight);
        make.bottom.equalTo(self.view.bottom).offset(-8);
        make.right.equalTo(self.view.right);
    }];
    
    [self.attachButton makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(buttonWidth);
        make.height.equalTo(buttonHeight);
        make.bottom.equalTo(self.view.bottom).offset(-8);
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

#pragma mark - UITextViewDelegate

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
    CGFloat needsHeight = [self heightTextViewText:text] + 16.f;
    
    if(self.previousHeight != needsHeight)
    {
        if(needsHeight <= self.maxHeight)
        {
            [self.delegate chatMessageBarViewControllerNeedsHeight:needsHeight];
            // textView.scrollEnabled = NO;
        }
        else
        {
            // textView.scrollEnabled = YES;
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
                                          attributes:options context:nil];
    
    return self.textView.textContainerInset.top + boundingRect.size.height + self.textView.textContainerInset.bottom;
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
    
}

- (void)chatButtonsTappedPlus
{
    [self.delegate chatMessagePanelTappedPlusButton];
}

- (void)clearText
{
    self.textView.text = @"";
    [self updateHeightIfNeeded:self.textView.text];
}

@end
