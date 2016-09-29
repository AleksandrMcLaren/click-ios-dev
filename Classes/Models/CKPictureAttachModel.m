//
//  CKPictureAttachModel.m
//  click
//
//  Created by Igor Tetyuev on 10.06.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKPictureAttachModel.h"
#import "CKCache.h"

@implementation CKPictureAttachModel {
    UIImage *_preview;
}

- (CKAttachType)type {
    return CKAttachTypeImage;
}

- (NSString *)contentType {
    return @"image/jpeg";
}

- (NSString *)filename {
    return [NSString stringWithFormat:@"%@", self.uuid];
}

- (NSData *)data {
    return UIImageJPEGRepresentation(self.image, 1.0);
}

- (void)setImage:(UIImage *)image {
    _image = image;
    CGFloat ratio = 400 / image.size.width;
    self.preview = [UIImage imageWithCGImage:image.CGImage
                                            scale:ratio
                                      orientation:image.imageOrientation];
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
    if (self = [super initWithDictionary:dict]) {
        self.url = [NSURL URLWithString:[NSString stringWithFormat:@"http://click.httpx.ru:8102/message/%@", dict[@"id"]]];
        NSData *imageData = [[CKCache sharedInstance] dataWithURLString:[NSString stringWithFormat:@"http://click.httpx.ru:8102/message/%@_small", dict[@"id"]]
                                                              completion:^(NSData *result, NSDictionary *userdata) {
                                                                  self.preview = [UIImage imageWithData:result];
                                                              } userData:dict];
        if (imageData) {
            self.preview = [UIImage imageWithData:imageData];
        }
    }
    return self;
}

+ (CKPictureAttachModel *) modelWithDictionary:(NSDictionary *)dict {
    return [[CKPictureAttachModel alloc] initWithDictionary:dict];
}

@end
