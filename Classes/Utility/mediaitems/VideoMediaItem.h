//  Created by Дрягин Павел
//  Copyright © 2016 Click. All rights reserved.



#import "JSQMediaItem.h"


@interface VideoMediaItem : JSQMediaItem <JSQMessageMediaData, NSCoding, NSCopying>


@property (nonatomic, assign) int status;

@property (nonatomic, strong) NSURL *fileURL;
@property (copy, nonatomic) UIImage *image;

- (instancetype)initWithFileURL:(NSURL *)fileURL;

@end

