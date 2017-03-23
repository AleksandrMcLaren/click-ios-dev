//
//  SDWebImageDownloader+Completion.h
//
//  Created by Aleksandr.
//  Copyright © 2016. All rights reserved.
//

#import "SDWebImageDownloader.h"
#import <SDWebImage/SDImageCache.h>

@interface SDWebImageDownloader (Сompletion)

- (void)imageWithURL:(NSString *)url
            completion:(void (^)(UIImage *image, BOOL isCache))completion;

- (void)imageWithURL:(NSString *)url
            completion:(void (^)(UIImage *image, BOOL isCache))completion
            failure:(void (^)(NSError *error))failure;

@end
