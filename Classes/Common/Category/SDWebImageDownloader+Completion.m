//
//  SDWebImageDownloader+Completion.m
//
//  Created by Aleksandr.
//  Copyright © 2016. All rights reserved.
//

#import "SDWebImageDownloader+Completion.h"

@implementation SDWebImageDownloader (Completion)

- (void)imageWithURL:(NSString *)url
          completion:(void (^)(UIImage *image, BOOL isCache))completion
{
    [self imageWithURL:url
            completion:completion
               failure:nil];
}

- (void)imageWithURL:(NSString *)url
          completion:(void (^)(UIImage *image, BOOL isCache))completion
             failure:(void (^)(NSError *error))failure
{
    if(!url)
    {
        if(completion)
            completion(nil, NO);
        
        return;
    }
    
    [[SDImageCache sharedImageCache] queryDiskCacheForKey:url done:^(UIImage *image, SDImageCacheType cacheType) {
        
        if(image)
        {
            completion(image, YES);
        }
        else
        {
            [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:url]
                                                                  options:0
                                                                 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                                                     
                                                                 }
                                                                 completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                                                                    
                                                                    if(finished)
                                                                    {
                                                                        if(image)
                                                                        {
                                                                            if(completion)
                                                                                completion(image, NO);
                                                                            
                                                                            [[SDImageCache sharedImageCache] storeImage:image forKey:url];
                                                                        }
                                                                        else
                                                                        {
                                                                            if(failure)
                                                                                failure(error);
                                                                        }
                                                                    }
                                                                }];
        }
    }];
    
}

@end
