//
//  CKImageCache.h
//  click
//
//  Created by Igor Tetyuev on 21.03.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CKCacheDownloadCompletion)(NSData* result, NSDictionary *userdata);

@interface CKCache : NSObject

+ (instancetype)sharedInstance;

- (void)putData:(NSData *)data withURLString:(NSString *)urlstring;
- (void)putImage:(UIImage *)image withURLString:(NSString *)urlstring;
- (BOOL)hasDataWithURLString:(NSString *)urlstring;
- (NSData *)dataWithURLString:(NSString *)urlstring;
- (UIImage *)imageWithURLString:(NSString *)urlstring;
- (void)downloadFileWithURLString:(NSString *)urlstring completion:(CKCacheDownloadCompletion) completion userData:(NSDictionary *)userdata;
- (NSString *)cachedFilePathWithURLString:(NSString *)urlstring;
- (NSData *)dataWithURLString:(NSString *)urlstring completion:(CKCacheDownloadCompletion) completion userData:(NSDictionary *)userdata;

@end
