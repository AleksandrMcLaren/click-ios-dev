//
//  CKAvatarView.m
//  click
//
//  Created by Igor Tetyuev on 01.04.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKAvatarView.h"
#import "CKCache.h"

@implementation CKAvatarView
{
    UIImageView *_avatar;
    UILabel *_letterAvatar;
    NSInteger _iteration;
    CGFloat _lastdim;
    NSString *_filename;
    NSString *_fallbackName;
}

- (void)setAvatarFile:(NSString *)filename fallbackName:(NSString *)fallbackName;
{
    _filename = filename;
    _fallbackName = fallbackName;
    self.fallbackColor = CKClickBlueColor;
    
    if (!_filename) {
        _avatar.image = nil;
    }
    if (!_fallbackName)
    {
        _letterAvatar.text = nil;
        return;
    }
    
    if (_filename.length)
    {
        NSData *avatarData = [[CKCache sharedInstance] dataWithURLString:[NSString stringWithFormat:@"%@%@", CK_URL_AVATAR, _filename]
                                                              completion:^(NSData *result, NSDictionary *userdata) {
                                                                  if (_iteration != [userdata[@"iteration"] integerValue]) return;
                                                                  if (!result)
                                                                  {
                                                                      _avatar.hidden = YES;
                                                                      _letterAvatar.hidden = NO;
                                                                  } else
                                                                  {
                                                                      _avatar.hidden = NO;
                                                                      _letterAvatar.hidden = YES;
                                                                      UIImage *img = [UIImage imageWithData:result];
                                                                      _avatar.image = img;
                                                                  }
                                                              } userData:@{@"iteration":@(_iteration)}];
        if (avatarData)
        {
            _avatar.image = [UIImage imageWithData:avatarData];
            _avatar.hidden = NO;
            _letterAvatar.hidden = YES;
        }
    } else
    {
        _avatar.hidden = YES;
        _letterAvatar.hidden = NO;
        
    }
    if (_fallbackName.length) _letterAvatar.text = [_fallbackName substringToIndex:1];
}

- (instancetype)init
{
    if (self = [super init])
    {
        self.clipsToBounds = YES;
        self.layer.borderColor = [CKClickProfileGrayColor CGColor];
        self.layer.borderWidth = 0.5;
        
        _letterAvatar = [UILabel labelWithText:@"A" font:[UIFont systemFontOfSize:24.0] textColor:CKClickLightGrayColor textAlignment:NSTextAlignmentCenter];
        _letterAvatar.hidden = YES;
        _letterAvatar.backgroundColor = [UIColor clearColor];
        [self addSubview:_letterAvatar];
        
        _avatar = [UIImageView new];
        _avatar.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_avatar];
    }
    return self;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:self.fallbackColor];
}

- (void)setFallbackColor:(UIColor *)fallbackColor
{
    _fallbackColor = fallbackColor;
    self.backgroundColor = fallbackColor;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _avatar.frame = self.bounds;
    _letterAvatar.frame = self.bounds;
    CGFloat dim = fmin(self.bounds.size.height, self.bounds.size.width);
    if (dim!=_lastdim)
    {
        _letterAvatar.font = [UIFont systemFontOfSize:dim/2];
        self.layer.cornerRadius = dim/2;
    }
    _lastdim = dim;
}

@end
