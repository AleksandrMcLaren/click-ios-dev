//
//  MLChatMenuAttachViewController.m
//  click
//
//  Created by Александр on 26.02.17.
//  Copyright © 2017 Click. All rights reserved.
//

#import "MLChatMenuAttachViewController.h"
#import "MLChatMenuButtonViewConrtoller.h"

@interface MLChatMenuAttachViewController ()

@property (nonatomic, strong) UIView *lineTopView;
@property (nonatomic, strong) UIView *lineBottomView;
@property (nonatomic, strong) UIButton *timerButton;
@property (nonatomic, strong) UIButton *geoButton;
@property (nonatomic, strong) NSMutableArray *buttons;

@end

@implementation MLChatMenuAttachViewController

- (instancetype)init
{
    self = [super init];
    
    if(self)
    {
        self.lineTopView = [[UIView alloc] init];
        self.lineBottomView = [[UIView alloc] init];
        
        self.timerButton = [[UIButton alloc] init];
        [self.timerButton addTarget:self action:@selector(timerTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.timerButton setImage:[UIImage imageNamed:@"timer"] forState:UIControlStateNormal];
        [self.timerButton setImage:[UIImage imageNamed:@"timer_active"] forState:UIControlStateSelected];
        
        self.geoButton = [[UIButton alloc] init];
        [self.geoButton addTarget:self action:@selector(geoTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.geoButton setImage:[UIImage imageNamed:@"geo"] forState:UIControlStateNormal];
        [self.geoButton setImage:[UIImage imageNamed:@"geo_active"] forState:UIControlStateSelected];
        
        [self createButtons];
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    self.view.backgroundColor = [UIColor colorWithHue:0.00 saturation:0.00 brightness:0.97 alpha:1.00];
    self.lineTopView.backgroundColor = [UIColor colorWithHue:0.00 saturation:0.00 brightness:0.60 alpha:0.4];
    self.lineBottomView.backgroundColor = self.lineTopView.backgroundColor;
    
    [self.view addSubview:self.lineTopView];
    [self.view addSubview:self.timerButton];
    [self.view addSubview:self.geoButton];
    [self.view addSubview:self.lineBottomView];
    
    for(UIViewController *vc in self.buttons)
    {
        [self.view addSubview:vc.view];
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGSize boundsSize = self.view.bounds.size;
    
    self.lineTopView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 1);
    self.lineBottomView.frame = CGRectMake(0, 35, self.view.bounds.size.width, 1);
    
    CGFloat topButtonWidth = 40.f;
    CGFloat topButtonIndent = 50.f;
    CGFloat left = (boundsSize.width - topButtonWidth * 2 - topButtonIndent) / 2;
    self.timerButton.frame = CGRectMake(left, 0, topButtonWidth, topButtonWidth);
    self.geoButton.frame = CGRectMake(left + topButtonWidth + topButtonIndent, 0, topButtonWidth, topButtonWidth);
    
    
    
/*
 CGFloat btnTopIndent = 12.f;
 CGFloat btnIndent = 10.f;
 CGFloat y = self.lineBottomView.frame.origin.y + self.lineBottomView.frame.size.height + btnTopIndent;
    CGFloat btnWidth = (boundsSize.width - btnIndent * 5) / 4;
    CGFloat btnHeigth = (boundsSize.height - y - btnTopIndent * 2) / 2;
  */
    
    CGFloat btnIndent = 15.f;
    CGFloat btnWidth = (boundsSize.width - btnIndent * 5) / 4;
    CGFloat btnHeigth = btnWidth + 20;
    CGFloat btnTopIndent = ((boundsSize.height - self.lineBottomView.frame.origin.y + self.lineBottomView.frame.size.height) - btnHeigth * 2) / 3;
    CGFloat x = btnIndent;
    CGFloat y = self.lineBottomView.frame.origin.y + self.lineBottomView.frame.size.height + btnTopIndent;
    
    for(NSInteger i = 0; i < self.buttons.count; i++)
    {
        MLChatMenuButtonViewConrtoller *btn = self.buttons[i];
        btn.view.frame = CGRectMake(x, y, btnWidth, btnHeigth);
        
        x = x + btnWidth + btnIndent;
        
        if(i == 3)
        {
            x = btnIndent;
            y = y + btnHeigth + btnTopIndent;
        }
    }
}

#pragma mark - 

- (void)createButtons
{
    self.buttons = [[NSMutableArray alloc] init];
    
    for(NSInteger i = 0; i < 8; i++)
    {
        MLChatMenuButtonViewConrtoller *btn = [[MLChatMenuButtonViewConrtoller alloc] init];
        
        switch (i) {
            case 0:
                btn.imageName = @"camera";
                btn.titleText = @"Камера";
                break;
            case 1:
                btn.imageName = @"album";
                btn.titleText = @"Альбом";
                break;
            case 2:
                btn.imageName = @"voice";
                btn.titleText = @"Голос";
                break;
            case 3:
                btn.imageName = @"audio";
                btn.titleText = @"Аудио";
                break;
            case 4:
                btn.imageName = @"icloud";
                btn.titleText = @"iCloud";
                break;
            case 5:
                btn.imageName = @"location";
                btn.titleText = @"Место";
                break;
            case 6:
                btn.imageName = @"contact";
                btn.titleText = @"Контакт";
                break;
            case 7:
                btn.imageName = @"keyboard";
                break;
            default:
                break;
        }
        
        [self.buttons addObject:btn];
    }
}

#pragma mark - Actions

- (void)timerTapped
{
    self.timerButton.selected = !self.timerButton.selected;
}

- (void)geoTapped
{
    self.geoButton.selected = !self.geoButton.selected;
}

@end
