//
//  MLChatAvaViewController.m
//  click
//
//  Created by Aleksandr on 06/02/2017.
//  Copyright © 2017 Click. All rights reserved.
//

#import "MLChatAvaViewController.h"
#import "MLChatLib.h"

@interface MLChatAvaViewController ()

@property (nonatomic, strong) UIImageView *imView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) NSString *currentImageUrl;

@end


@implementation MLChatAvaViewController

- (instancetype)init
{
    self = [super init];
    
    if(self)
    {
        self.imView = [[UIImageView alloc] init];
        self.imView.contentMode = UIViewContentModeScaleAspectFill;
        self.imView.layer.masksToBounds = YES;
        self.imView.hidden = YES;
        
        self.nameLabel = [[UILabel alloc] init];
        self.nameLabel.font = [UIFont systemFontOfSize:18.0];
        self.nameLabel.textColor = [UIColor whiteColor];
        self.nameLabel.hidden = YES;
        
        self.diameter = 30;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.layer.masksToBounds = YES;

    [self.view addSubview:self.nameLabel];
    [self.view addSubview:self.imView];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.view.layer.cornerRadius = self.view.bounds.size.width / 2;
    
    self.imView.frame = self.view.bounds;
    
    if(!self.nameLabel.hidden)
    {
        CGSize boundsSize = self.view.bounds.size;
        CGSize textSize = [MLChatLib textSizeLabel:self.nameLabel withWidth:boundsSize.width];
        self.nameLabel.frame = CGRectMake((boundsSize.width - textSize.width) / 2, (boundsSize.height - textSize.height) / 2, textSize.width, textSize.height);
    }
}

- (void)setMessage:(MLChatMessage *)message
{
    _message = message;

    if(self.message.avatarUrl && self.message.avatarUrl.length)
    {
        [self loadImage];
        [self hideNameLabel];
    }
    else
    {
        [self unloadImage];
        [self showNameLabel];
    }
}

- (void)setDiameter:(CGFloat)diameter
{
    _diameter = diameter;
}

#pragma mark - 

- (void)showNameLabel
{
    if(self.message.userLogin && self.message.userLogin.length)
        self.nameLabel.text = [[self.message.userLogin substringToIndex:1] uppercaseString];
    else
        self.nameLabel.text = nil;

    self.view.backgroundColor = [MLChatAvaViewController getColorForAvatar:self.nameLabel.text];
    
    self.nameLabel.hidden = NO;
    [self.view setNeedsLayout];
}

- (void)hideNameLabel
{
    self.view.backgroundColor = [UIColor clearColor];
    self.nameLabel.hidden = YES;
    [self.view setNeedsLayout];
}

- (void)loadImage
{
    self.imView.hidden = NO;
    
    if(self.currentImageUrl && [self.currentImageUrl isEqualToString:self.message.avatarUrl])
    {
        return;
    }
    
    self.currentImageUrl = self.message.avatarUrl;
    
    __weak typeof(self) _weakSelf = self;
    [[SDWebImageDownloader sharedDownloader] imageWithURL:self.message.avatarUrl
                                               completion:^(UIImage *image, BOOL isCache) {
                                                   
                                                   if(_weakSelf)
                                                   {
                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                           
                                                           if(isCache)
                                                           {
                                                               _weakSelf.imView.image = image;
                                                           }
                                                           else
                                                           {
                                                               [UIView transitionWithView:_weakSelf.imView
                                                                                 duration:0.2f
                                                                                  options:UIViewAnimationOptionTransitionCrossDissolve
                                                                               animations:^{
                                                                                   _weakSelf.imView.image = image;
                                                                               } completion:nil];
                                                           }
                                                       });
                                                   }
                                                   
                                               } failure:^(NSError *error) {
                                                   
                                                   if(_weakSelf)
                                                   {
                                                       self.currentImageUrl = nil;
                                                       
                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                           [_weakSelf showNameLabel];
                                                       });
                                                   }
                                               }];

}

- (void)unloadImage
{
    self.imView.image = nil;
    self.imView.hidden = YES;
    self.currentImageUrl = nil;
}

#pragma mark -

+ (UIColor *)getColorForAvatar:(NSString *)name
{
    __block UIColor *color = nil;
    NSString *str = name;
    str = [str  uppercaseString];
    
    typedef void (^CaseBlock)();
    
    // Squint and this looks like a proper switch!
    NSDictionary *d = @{
                        @"A":
                            ^{
                                color = [UIColor colorWithRed:230/255.0f green:54/255.0f blue:180/255.0f alpha:1.0];
                            },
                        @"B":
                            ^{
                                color = [UIColor colorWithRed:250/255.0f green:55/255.0f blue:122/255.0f alpha:1.0];
                            },
                        @"C":
                            ^{
                                color =  [UIColor colorWithRed:255/255.0f green:112/255.0f blue:102/255.0f alpha:1.0];
                            },
                        @"D":
                            ^{
                                color =  [UIColor colorWithRed:255/255.0f green:123/255.0f blue:82/255.0f alpha:1.0];
                            },
                        @"E":
                            ^{
                                color =  [UIColor colorWithRed:254/255.0f green:200/255.0f blue:7/255.0f alpha:1.0];
                            },
                        @"F":
                            ^{
                                color =  [UIColor colorWithRed:96/255.0f green:219/255.0f blue:100/255.0f alpha:1.0];
                            },
                        @"G":
                            ^{
                                color =  [UIColor colorWithRed:194/255.0f green:35/255.0f blue:137/255.0f alpha:1.0];
                            },
                        @"H":
                            ^{
                                color =  [UIColor colorWithRed:232/255.0f green:30/255.0f blue:99/255.0f alpha:1.0];
                            },
                        @"I":
                            ^{
                                color =  [UIColor colorWithRed:243/255.0f green:67/255.0f blue:54/255.0f alpha:1.0];
                            },
                        @"J":
                            ^{
                                color =  [UIColor colorWithRed:254/255.0f green:87/255.0f blue:34/255.0f alpha:1.0];
                            },
                        @"K":
                            ^{
                                color =  [UIColor colorWithRed:254/255.0f green:151/255.0f blue:0/255.0f alpha:1.0];
                            },
                        @"L":
                            ^{
                                color =  [UIColor colorWithRed:76/255.0f green:174/255.0f blue:80/255.0f alpha:1.0];
                            },
                        @"M":
                            ^{
                                color =  [UIColor colorWithRed:124/255.0f green:21/255.0f blue:104/255.0f alpha:1.0];
                            },
                        @"N":
                            ^{
                                color =  [UIColor colorWithRed:135/255.0f green:14/255.0f blue:79/255.0f alpha:1.0];
                            },
                        @"O":
                            ^{
                                color =  [UIColor colorWithRed:182/255.0f green:28/255.0f blue:28/255.0f alpha:1.0];
                            },
                        @"P":
                            ^{
                                color =  [UIColor colorWithRed:190/255.0f green:54/255.0f blue:12/255.0f alpha:1.0];
                            },
                        @"Q":
                            ^{
                                color =  [UIColor colorWithRed:299/255.0f green:81/255.0f blue:0/255.0f alpha:1.0];
                            },
                        @"R":
                            ^{
                                color =  [UIColor colorWithRed:27/255.0f green:94/255.0f blue:32/255.0f alpha:1.0];
                            },
                        @"S":
                            ^{
                                color =  [UIColor colorWithRed:0/255.0f green:181/255.0f blue:164/255.0f alpha:1.0];
                            },
                        @"T":
                            ^{
                                color =  [UIColor colorWithRed:0/255.0f green:197/255.0f blue:222/255.0f alpha:1.0];
                            },
                        @"U":
                            ^{
                                color =  [UIColor colorWithRed:78/255.0f green:99/255.0f blue:219/255.0f alpha:1.0];
                            },
                        @"V":
                            ^{
                                color =  [UIColor colorWithRed:144/255.0f green:76/255.0f blue:228/255.0f alpha:1.0];
                            },
                        @"W":
                            ^{
                                color =  [UIColor colorWithRed:210/255.0f green:53/255.0f blue:237/255.0f alpha:1.0];
                            },
                        @"X":
                            ^{
                                color =  [UIColor colorWithRed:121/255.0f green:157/255.0f blue:173/255.0f alpha:1.0];
                            },
                        @"Y":
                            ^{
                                color =  [UIColor colorWithRed:176/255.0f green:124/255.0f blue:105/255.0f alpha:1.0];
                            },
                        @"Z":
                            ^{
                                color =  [UIColor colorWithRed:0/255.0f green:149/255.0f blue:135/255.0f alpha:1.0];
                            },
                        @"0":
                            ^{
                                color =  [UIColor colorWithRed:0/255.0f green:172/255.0f blue:194/255.0f alpha:1.0];
                            },
                        @"1":
                            ^{
                                color =  [UIColor colorWithRed:63/255.0f green:81/255.0f blue:180/255.0f alpha:1.0];
                            },
                        @"2":
                            ^{
                                color =  [UIColor colorWithRed:109/255.0f green:60/255.0f blue:178/255.0f alpha:1.0];
                            },
                        @"3":
                            ^{
                                color =  [UIColor colorWithRed:155/255.0f green:39/255.0f blue:175/255.0f alpha:1.0];
                            },
                        @"4":
                            ^{
                                color =  [UIColor colorWithRed:96/255.0f green:125/255.0f blue:138/255.0f alpha:1.0];
                            },
                        @"5":
                            ^{
                                color =  [UIColor colorWithRed:121/255.0f green:85/255.0f blue:72/255.0f alpha:1.0];
                            },
                        @"6":
                            ^{
                                color =  [UIColor colorWithRed:0/255.0f green:77/255.0f blue:64/255.0f alpha:1.0];
                            },
                        @"7":
                            ^{
                                color =  [UIColor colorWithRed:0/255.0f green:96/255.0f blue:100/255.0f alpha:1.0];
                            },
                        @"8":
                            ^{
                                color =  [UIColor colorWithRed:21/255.0f green:31/255.0f blue:124/255.0f alpha:1.0];
                            },
                        @"9":
                            ^{
                                color =  [UIColor colorWithRed:70/255.0f green:32/255.0f blue:127/255.0f alpha:1.0];
                            },
                        @"А":
                            ^{
                                color =  [UIColor colorWithRed:230/255.0f green:54/255.0f blue:180/255.0f alpha:1.0];
                            },
                        @"Б":
                            ^{
                                color =  [UIColor colorWithRed:250/255.0f green:55/255.0f blue:122/255.0f alpha:1.0];
                            },
                        @"В":
                            ^{
                                color =  [UIColor colorWithRed:255/255.0f green:112/255.0f blue:102/255.0f alpha:1.0];
                            },
                        @"Г":
                            ^{
                                color =  [UIColor colorWithRed:255/255.0f green:123/255.0f blue:82/255.0f alpha:1.0];
                            },
                        @"Д":
                            ^{
                                color =  [UIColor colorWithRed:254/255.0f green:200/255.0f blue:7/255.0f alpha:1.0];
                            },
                        @"Е":
                            ^{
                                color =  [UIColor colorWithRed:96/255.0f green:219/255.0f blue:100/255.0f alpha:1.0];
                            },
                        @"Ё":
                            ^{
                                color =  [UIColor colorWithRed:194/255.0f green:35/255.0f blue:137/255.0f alpha:1.0];
                            },
                        @"Ж":
                            ^{
                                color =  [UIColor colorWithRed:232/255.0f green:30/255.0f blue:99/255.0f alpha:1.0];
                            },
                        @"З":
                            ^{
                                color =  [UIColor colorWithRed:243/255.0f green:67/255.0f blue:54/255.0f alpha:1.0];
                            },
                        @"И":
                            ^{
                                color =  [UIColor colorWithRed:254/255.0f green:87/255.0f blue:34/255.0f alpha:1.0];
                            },
                        @"Й":
                            ^{
                                color =  [UIColor colorWithRed:254/255.0f green:151/255.0f blue:0/255.0f alpha:1.0];
                            },
                        @"К":
                            ^{
                                color =  [UIColor colorWithRed:76/255.0f green:174/255.0f blue:80/255.0f alpha:1.0];
                            },
                        @"Л":
                            ^{
                                color =  [UIColor colorWithRed:124/255.0f green:21/255.0f blue:104/255.0f alpha:1.0];
                            },
                        @"М":
                            ^{
                                color =  [UIColor colorWithRed:135/255.0f green:14/255.0f blue:79/255.0f alpha:1.0];
                            },
                        @"Н":
                            ^{
                                color =  [UIColor colorWithRed:182/255.0f green:28/255.0f blue:28/255.0f alpha:1.0];
                            },
                        @"О":
                            ^{
                                color =  [UIColor colorWithRed:190/255.0f green:54/255.0f blue:12/255.0f alpha:1.0];
                            },
                        @"П":
                            ^{
                                color =  [UIColor colorWithRed:299/255.0f green:81/255.0f blue:0/255.0f alpha:1.0];
                            },
                        @"Р":
                            ^{
                                color =  [UIColor colorWithRed:27/255.0f green:94/255.0f blue:32/255.0f alpha:1.0];
                            },
                        @"С":
                            ^{
                                color =  [UIColor colorWithRed:0/255.0f green:181/255.0f blue:164/255.0f alpha:1.0];
                            },
                        @"Т":
                            ^{
                                color =  [UIColor colorWithRed:0/255.0f green:197/255.0f blue:222/255.0f alpha:1.0];
                            },
                        @"У":
                            ^{
                                color =  [UIColor colorWithRed:78/255.0f green:99/255.0f blue:219/255.0f alpha:1.0];
                            },
                        @"Ф":
                            ^{
                                color =  [UIColor colorWithRed:144/255.0f green:76/255.0f blue:228/255.0f alpha:1.0];
                            },
                        @"Х":
                            ^{
                                color =  [UIColor colorWithRed:210/255.0f green:53/255.0f blue:237/255.0f alpha:1.0];
                            },
                        @"Ц":
                            ^{
                                color =  [UIColor colorWithRed:121/255.0f green:157/255.0f blue:173/255.0f alpha:1.0];
                            },
                        @"Ч":
                            ^{
                                color =  [UIColor colorWithRed:176/255.0f green:124/255.0f blue:105/255.0f alpha:1.0];
                            },
                        @"Ш":
                            ^{
                                color =  [UIColor colorWithRed:0/255.0f green:149/255.0f blue:135/255.0f alpha:1.0];
                            },
                        @"Щ":
                            ^{
                                color =  [UIColor colorWithRed:0/255.0f green:172/255.0f blue:194/255.0f alpha:1.0];
                            },
                        @"Ъ":
                            ^{
                                color =  [UIColor colorWithRed:63/255.0f green:81/255.0f blue:180/255.0f alpha:1.0];
                            },
                        @"Ы":
                            ^{
                                color =  [UIColor colorWithRed:109/255.0f green:60/255.0f blue:178/255.0f alpha:1.0];
                            },
                        @"Ь":
                            ^{
                                color =  [UIColor colorWithRed:155/255.0f green:39/255.0f blue:175/255.0f alpha:1.0];
                            },
                        @"Э":
                            ^{
                                color =  [UIColor colorWithRed:96/255.0f green:125/255.0f blue:138/255.0f alpha:1.0];
                            },
                        @"Ю":
                            ^{
                                color =  [UIColor colorWithRed:121/255.0f green:85/255.0f blue:72/255.0f alpha:1.0];
                            },
                        @"Я":
                            ^{
                                color =  [UIColor colorWithRed:0/255.0f green:77/255.0f blue:64/255.0f alpha:1.0];
                            }
                        };
    
    CaseBlock c = d[str];
    
    if (c) c(); else {
        return [UIColor orangeColor];
    }
    
    return [color colorWithAlphaComponent:0.6];
}

@end
