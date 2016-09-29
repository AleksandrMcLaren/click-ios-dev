//
//  CKImageCache.m
//  click
//
//  Created by Igor Tetyuev on 21.03.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKCache.h"
#import "CKHTTPRequest.h"

#define TTL 30

@interface CKCache()

@end

@implementation CKCache
{
    NSMutableArray *_items;
}

- (instancetype)init
{
    if (self = [super init])
    {
        NSError *error = nil;
        NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[CKCache cachePath] error:&error];
        _items = [NSMutableArray new];
        
        NSDate *now = [NSDate date];
        NSDateComponents *minusAge = [NSDateComponents new];
        minusAge.day = -TTL;
        NSDate *oldDate = [[NSCalendar currentCalendar] dateByAddingComponents:minusAge
                                                                         toDate:now
                                                                        options:0];
        
        for (NSString *i in files)
        {
            NSString *path = [[CKCache cachePath] stringByAppendingPathComponent:i];
            NSDictionary* attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
            if (attrs)
            {
                NSDate *date = (NSDate*)[attrs objectForKey: NSFileCreationDate];
                if ([date earlierDate:oldDate] == date)
                {
                    [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
                    continue;
                }
            }
            NSLog(@"indexing: %@", i);
            [_items addObject:i];
            NSLog(@"%@", _items);
        }
    }
    return self;
}

+ (instancetype)sharedInstance
{
    static CKCache *instance;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        instance = [CKCache new];
    });
    
    return instance;
}


+ (NSString *)cachePath
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"cache"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSError *dirCreationError = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:path
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&dirCreationError];
        if (dirCreationError != nil) {
            NSLog(@"Ошибка создания папки для кэша");
            assert(0);
        }
    }
    return path;
}

- (NSString *)cachedFilePathWithURLString:(NSString *)urlstring {
    return [[CKCache cachePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%lu.%@", (unsigned long)[urlstring hash], urlstring.pathExtension]];
}

- (BOOL)hasDataWithURLString:(NSString *)urlstring
{
    NSLog(@"checking %@", [self cachedFilePathWithURLString:urlstring]);
    return [_items containsObject:[NSString stringWithFormat:@"%lu.%@", (unsigned long)[urlstring hash], urlstring.pathExtension]];
}

- (void)putData:(NSData *)data withURLString:(NSString *)urlstring
{
    NSString *path = [self cachedFilePathWithURLString:urlstring];
    NSLog(@"path: %@", path);
    [data writeToFile:path atomically:YES];
    NSLog(@"writing %@", [NSString stringWithFormat:@"%lu.%@", (unsigned long)[urlstring hash], urlstring.pathExtension]);
    [_items addObject:[NSString stringWithFormat:@"%lu.%@", (unsigned long)[urlstring hash], urlstring.pathExtension]];
}

- (void)putImage:(UIImage *)image withURLString:(NSString *)urlstring
{
    NSData *data = UIImagePNGRepresentation(image);
    [self putData:data withURLString:urlstring];
}

- (NSData *)dataWithURLString:(NSString *)urlstring
{
    NSString *path = [self cachedFilePathWithURLString:urlstring];
    NSData *data = [NSData dataWithContentsOfFile:path];
    return data;
}

- (UIImage *)imageWithURLString:(NSString *)urlstring
{
    NSData *data = [self dataWithURLString:urlstring];
    return [UIImage imageWithData:data];
}

- (void)downloadFileWithURLString:(NSString *)urlstring completion:(CKCacheDownloadCompletion) completion userData:(NSDictionary *)userdata {
    if ([self hasDataWithURLString:urlstring]) {
        completion(nil, userdata);
        return;
    }
    [self dataWithURLString:urlstring completion:^(NSData *result, NSDictionary *userdata) {
        [result writeToFile:[self cachedFilePathWithURLString:urlstring] atomically:YES];
        completion(nil, userdata);
    } userData:userdata];
}

- (NSData *)dataWithURLString:(NSString *)urlstring completion:(CKCacheDownloadCompletion) completion userData:(NSDictionary *)userdata
{
    if ([self hasDataWithURLString:urlstring])
    {
        return [self dataWithURLString:urlstring];
    }
    CKHTTPRequest *req = [CKHTTPRequest requestToGetUrl:urlstring
                                                 params:nil
                                              onSuccess:^(CKHTTPResponse *response) {
                                                  [self putData:response.data withURLString:urlstring];
                                                  completion(response.data, userdata);
                                              } onError:^(CKHTTPError *error) {
                                                  completion(nil, userdata);
                                              }];
//    CKHTTPRequest *req = [CKHTTPRequest requestWithUrl:urlstring
//                                                method:GET
//                                                  body:nil
//                                          extraHeaders:@{}
//                                           contentType:nil
//                                             onSuccess:^(CKHTTPResponse *resp) {
//                                                 [self putData:resp.data withURLString:urlstring];
//                                                 completion(resp.data, userdata);
//                                             }
//                                               onError:^(CKHTTPError *e) {
//
//                                
//                                                   completion(nil, userdata);
//                                               }];
    [req start];
    return nil;
}


@end
