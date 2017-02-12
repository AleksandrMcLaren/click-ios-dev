//
//  MLChatStatusViewController.m
//  click
//
//  Created by Александр on 11.02.17.
//  Copyright © 2017 Click. All rights reserved.
//

#import "MLChatStatusViewController.h"
#import "MLChatLib.h"

@interface MLChatStatusViewController ()

@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;

@end


@implementation MLChatStatusViewController

- (instancetype)init
{
    self = [super init];
    
    if(self)
    {
        self.timeLabel = [[UILabel alloc] init];
        self.timeLabel.font = [UIFont italicSystemFontOfSize:12];
        
        self.imageView = [[UIImageView alloc] init];
        
        self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.view addSubview:self.timeLabel];
    [self.view addSubview:self.imageView];
    [self.view addGestureRecognizer:self.tapRecognizer];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
 
    CGSize boundsSize = self.view.bounds.size;
    CGSize timeSize = self.timeLabel.frame.size;
    CGSize imageSize = (self.imageView.image ? self.imageView.image.size : CGSizeZero);
    CGFloat allWidth = timeSize.width + imageSize.width;
    CGFloat xTime = (boundsSize.width - allWidth) / 2;
    
    self.timeLabel.frame = CGRectMake(xTime, (boundsSize.height - timeSize.height) / 2, timeSize.width, timeSize.height);
    
    CGFloat xImage = xTime + timeSize.width;
    CGFloat yImage = self.timeLabel.frame.origin.y + timeSize.height - imageSize.height - 1;
    self.imageView.frame = CGRectMake(xImage, yImage, imageSize.width, imageSize.height);
}

- (void)setMessage:(MLChatMessage *)message
{
    _message = message;
    
    [self updateTime];
    [self reloadStatus];
    [self.view setNeedsLayout];
}

- (void)updateTime
{
    self.timeLabel.text = [[MLChatLib formatterDate_HH_mm] stringFromDate:self.message.date];
    [self.timeLabel sizeToFit];
    
    if(self.message.isOwner)
        self.timeLabel.textColor = [UIColor colorWithHue:0.63 saturation:0.24 brightness:0.34 alpha:1.00];
    else
        self.timeLabel.textColor = [UIColor grayColor];
}

#pragma mark - Status

- (void)reloadStatus
{
    if(!self.message.isOwner)
    {
        self.imageView.image = nil;
        self.imageView.hidden = YES;
        self.tapRecognizer.enabled = NO;
        
        return;
    }
    
    self.imageView.hidden = NO;
    
    switch (self.message.status)
    {
        case MLChatMessageStatusSent:
            [self addPossibleResend];
            break;
        case MLChatMessageStatusDelivered:
            self.imageView.image = [MLChatStatusViewController imageDelivered];
            self.tapRecognizer.enabled = NO;
            break;
        case MLChatMessageStatusRead:
            self.imageView.image = [MLChatStatusViewController imageRead];
            self.tapRecognizer.enabled = NO;
            break;
        default:
            self.imageView.image = nil;
            self.tapRecognizer.enabled = NO;
            break;
    }
    
    if(self.message.status != MLChatMessageStatusRead)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateStatus:)
                                                     name:mlchat_message_update_status(self.message.ident)
                                                   object:nil];
    }
}

- (void)addPossibleResend
{
    NSDate *currentTime = [NSDate date];
    NSTimeInterval seconds = [currentTime timeIntervalSinceDate:self.message.date];
    
    if(seconds < 5)
        return;
    
    self.imageView.image = [MLChatStatusViewController imageResent];
    self.tapRecognizer.enabled = YES;
}

-(void)updateStatus:(NSNotification *)notification
{
    NSNumber *status = notification.object;
    
    if(status)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.message.status = status.integerValue;
            [self reloadStatus];
            [self.view setNeedsLayout];
        });
    }
}

#pragma mark - Actions

- (void)tapped
{
    [[NSNotificationCenter defaultCenter] postNotificationName:mlchat_message_needs_resend
                                                        object:self.message
                                                      userInfo:nil];
}

#pragma mark - Images

+ (UIImage *)imageDelivered
{
    static dispatch_once_t once;
    static UIImage *_image;
    dispatch_once(&once, ^{
        _image = [UIImage imageNamed:@"tick_black"];
    });
    
    return _image;
}

+ (UIImage *)imageRead
{
    static dispatch_once_t once;
    static UIImage *_image;
    dispatch_once(&once, ^{
        _image = [UIImage imageNamed:@"tick_black_multiple"];
    });
    
    return _image;
}

+ (UIImage *)imageResent
{
    static dispatch_once_t once;
    static UIImage *_image;
    dispatch_once(&once, ^{
        _image = [UIImage imageNamed:@"arrows_circle_strike_black"];
    });
    
    return _image;
}

@end
