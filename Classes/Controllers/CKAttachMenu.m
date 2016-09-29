//
//  CKAttachMenu.m
//  click
//
//  Created by Igor Tetyuev on 09.06.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKAttachMenu.h"

@implementation CKAttachMenu

- (instancetype)init {
    if (self = [super init]) {
        self.cameraButton = [[CKAttachButton alloc] initWithImageNamed:@"attachcamera" title:@"Камера"];
        [self addSubview:self.cameraButton];
        self.photosButton = [[CKAttachButton alloc] initWithImageNamed:@"attachphotos" title:@"Альбом"];
        [self addSubview:self.photosButton];
        self.recordingButton = [[CKAttachButton alloc] initWithImageNamed:@"attachrecording" title:@"Голос"];
        [self addSubview:self.recordingButton];
        self.audioButton = [[CKAttachButton alloc] initWithImageNamed:@"attachaudio" title:@"Аудио"];
        [self addSubview:self.audioButton];
        self.cloudButton = [[CKAttachButton alloc] initWithImageNamed:@"attachcloud" title:@"iCloud"];
        [self addSubview:self.cloudButton];
        self.locationButton = [[CKAttachButton alloc] initWithImageNamed:@"attachlocation" title:@"Место"];
        [self addSubview:self.locationButton];
        self.contactButton = [[CKAttachButton alloc] initWithImageNamed:@"attachcontact" title:@"Контакт"];
        [self addSubview:self.contactButton];
        self.hideButton = [[CKAttachButton alloc] initWithImageNamed:@"attachhide" title:@""];
        [self addSubview:self.hideButton];
        [self setNeedsUpdateConstraints];
        self.backgroundColor = [UIColor colorFromHexString:@"#f8f8f8"];
    }
    return self;
}

- (void)updateConstraints {
    [super updateConstraints];
    [self.cameraButton remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.width.equalTo(self).multipliedBy(0.25);
        make.top.equalTo(self.top).offset(37);
    }];
    [self.photosButton remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.cameraButton.right);
        make.width.equalTo(self).multipliedBy(0.25);
        make.top.equalTo(self.top).offset(37);
    }];
    [self.recordingButton remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.photosButton.right);
        make.width.equalTo(self).multipliedBy(0.25);
        make.top.equalTo(self.top).offset(37);
    }];
    [self.audioButton remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.recordingButton.right);
        make.width.equalTo(self).multipliedBy(0.25);
        make.top.equalTo(self.top).offset(37);
    }];
    
    [self.cloudButton remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.width.equalTo(self).multipliedBy(0.25);
        make.bottom.equalTo(self.bottom).offset(-16);
    }];
    [self.locationButton remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.cloudButton.right);
        make.width.equalTo(self).multipliedBy(0.25);
        make.bottom.equalTo(self.bottom).offset(-16);
    }];
    [self.contactButton remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.locationButton.right);
        make.width.equalTo(self).multipliedBy(0.25);
        make.bottom.equalTo(self.bottom).offset(-16);
    }];
    [self.hideButton remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contactButton.right);
        make.width.equalTo(self).multipliedBy(0.25);
        make.bottom.equalTo(self.bottom).offset(-16);
    }];
}

@end
