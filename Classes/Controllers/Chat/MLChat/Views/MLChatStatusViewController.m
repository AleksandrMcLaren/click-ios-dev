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

@end


@implementation MLChatStatusViewController

- (instancetype)init
{
    self = [super init];
    
    if(self)
    {
        self.timeLabel = [[UILabel alloc] init];
        self.timeLabel.font = [UIFont systemFontOfSize:12];
        
        self.imageView = [[UIImageView alloc] init];
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
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
 
    CGSize boundsSize = self.view.bounds.size;
    CGSize timeSize = self.timeLabel.frame.size;
    CGSize imageSize = (self.imageView.image ? self.imageView.image.size : CGSizeMake(12, 12));
    
    if(!self.message.isOwner)
        imageSize = CGSizeZero;

    CGFloat allWidth = timeSize.width + imageSize.width;
    CGFloat xTime = (boundsSize.width - allWidth) / 2;
    
    self.timeLabel.frame = CGRectMake(xTime, (boundsSize.height - timeSize.height) / 2, timeSize.width, timeSize.height);
    
    CGFloat xImage = xTime + timeSize.width;
    CGFloat yImage = self.timeLabel.frame.origin.y + timeSize.height - imageSize.height;
    self.imageView.frame = CGRectMake(xImage, yImage, imageSize.width, imageSize.height);
}

- (void)setMessage:(MLChatMessage *)message
{
    _message = message;
    
    __weak typeof(self) _weakSelf = self;
    self.message.updatedStatus = ^(){
        
        if(_weakSelf)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_weakSelf reloadStatus];
                [_weakSelf.view setNeedsLayout];
            });
        }
    };
    
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

        return;
    }
    
    self.imageView.hidden = NO;
    
    switch (self.message.status)
    {
        case MLChatMessageStatusSent:
            self.imageView.image = [MLChatStatusViewController imageSent];
            break;
        case MLChatMessageStatusDelivered:
            self.imageView.image = [MLChatStatusViewController imageDelivered];
            break;
        case MLChatMessageStatusRead:
            self.imageView.image = [MLChatStatusViewController imageRead];
            break;
        case MLChatMessageStatusNotSent:
            self.imageView.image = [MLChatStatusViewController imageResent];
            break;
        default:
            self.imageView.image = nil;
            break;
    }
}

#pragma mark - Images

+ (UIImage *)imageSent
{
    static dispatch_once_t once;
    static UIImage *_image;
    dispatch_once(&once, ^{
        _image = [UIImage imageNamed:@"status_tick_gray"];
    });
    
    return _image;
}

+ (UIImage *)imageDelivered
{
    static dispatch_once_t once;
    static UIImage *_image;
    dispatch_once(&once, ^{
        _image = [UIImage imageNamed:@"status_tick_multiple_gray"];
    });
    
    return _image;
}

+ (UIImage *)imageRead
{
    static dispatch_once_t once;
    static UIImage *_image;
    dispatch_once(&once, ^{
        _image = [UIImage imageNamed:@"status_tick_multiple_blue"];
    });
    
    return _image;
}

+ (UIImage *)imageResent
{
    static dispatch_once_t once;
    static UIImage *_image;
    dispatch_once(&once, ^{
        _image = [UIImage imageNamed:@"status_send_strike_gray"];
    });
    
    return _image;
}

@end
