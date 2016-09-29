//
//  CKVideoAttachModel.m
//  click
//
//  Created by Igor Tetyuev on 20.06.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKVideoAttachModel.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import "CKCache.h"

@implementation CKVideoAttachModel

- (CKAttachType)type {
    return CKAttachTypeVideo;
}

- (NSString *)contentType {
    return @"video/mp4";
}

- (NSString *)filename {
    return [NSString stringWithFormat:@"%@.m4v", self.uuid];
}

- (NSData *)data {
    return [NSData dataWithContentsOfURL:self.url];
}

- (void)setPreview:(UIImage *)preview {
    if (preview.size.width < 800) {
        [super setPreview:preview];
        return;
    }
    CGFloat ratio = 400 / preview.size.width;
    [super setPreview:[UIImage imageWithCGImage:preview.CGImage
                                          scale:ratio
                                    orientation:preview.imageOrientation]];
}

- (void) prepareForDisplay:(void(^)(NSString *path))completion {
    self.isBusy = YES;
    @weakify(self);
    [[CKCache sharedInstance] downloadFileWithURLString:self.url.absoluteString completion:^(NSData *result, NSDictionary *userdata) {
        @strongify(self);
        self.isBusy = NO;
        self.localPath = [[CKCache sharedInstance] cachedFilePathWithURLString:self.url.absoluteString];
        completion([[CKCache sharedInstance] cachedFilePathWithURLString:self.url.absoluteString]);
    } userData:nil];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        self.url = [NSURL URLWithString:[NSString stringWithFormat:@"http://click.httpx.ru:8102/message/%@.mp4", dict[@"id"]]];
        NSLog(@"%@", self.url.absoluteString);
        @weakify(self);
        NSData *imageData = [[CKCache sharedInstance] dataWithURLString:[NSString stringWithFormat:@"http://click.httpx.ru:8102/message/%@_small", dict[@"id"]]
                                                             completion:^(NSData *result, NSDictionary *userdata) {
                                                                 @strongify(self);
                                                                 self.preview = [UIImage imageWithData:result];
                                                             } userData:dict];
        if (imageData) {
            self.preview = [UIImage imageWithData:imageData];
        }
    }
    return self;
}

+ (CKVideoAttachModel *) modelWithDictionary:(NSDictionary *)dict {
    return [[CKVideoAttachModel alloc] initWithDictionary:dict];
}

@end
