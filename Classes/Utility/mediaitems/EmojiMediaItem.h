//  Created by Дрягин Павел
//  Copyright © 2016 Click. All rights reserved.


#import "JSQMediaItem.h"


@interface EmojiMediaItem : JSQMediaItem <JSQMessageMediaData, NSCoding, NSCopying>


@property (nonatomic, strong) NSString *text;

- (instancetype)initWithText:(NSString *)text;

@end

