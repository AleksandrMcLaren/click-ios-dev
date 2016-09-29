//
//  CKCloudAttachModel.m
//  click
//
//  Created by Igor Tetyuev on 10.06.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKCloudAttachModel.h"

@implementation CKCloudAttachModel {
    NSString *_filename;
}

- (CKAttachType)type {
    return CKAttachTypeFile;
}

- (NSString *)contentType {
    return @"application/octet-stream";
}

- (NSString *)filename {
    if (_filename) return _filename;
    return [_url lastPathComponent];
}

- (NSString *)description {
    return self.filename;
}

- (NSData *)data {
//    [self.url startAccessingSecurityScopedResource];
//    NSFileCoordinator *coordinator = [[NSFileCoordinator alloc] init];
//    NSError *error;
//    __block NSData *fileData;
//    
//    [coordinator coordinateReadingItemAtURL:self.url options:NSFileCoordinatorReadingForUploading error:&error byAccessor:^(NSURL *newURL) {
//        // File name for use in writing the file out later
//        NSString *fileName = [newURL lastPathComponent];
//        NSString *fileExtension = [newURL pathExtension];
//        
//        // iWork files will be in the form 'Filename.pages.zip'
//        if([fileExtension isEqualToString:@"zip"]) {
//            if([[[newURL URLByDeletingPathExtension] pathExtension] isEqualToString:@"pages"] ||
//               [[[newURL URLByDeletingPathExtension] pathExtension] isEqualToString:@"numbers"] ||
//               [[[newURL URLByDeletingPathExtension] pathExtension] isEqualToString:@"key"] ) {
//                // Remove .zip if it is an iWork file
//                fileExtension = [[newURL URLByDeletingPathExtension] pathExtension];
//                fileName = [[newURL URLByDeletingPathExtension] lastPathComponent];
//            }
//        }
//        
//        NSError *fileConversionError;
//        fileData = [NSData dataWithContentsOfURL:newURL options:NSDataReadingUncached error:&fileConversionError];
//        
//        
//    }];
//
//    [self.url stopAccessingSecurityScopedResource];
    return [NSData dataWithContentsOfURL:self.url];
}

@end
