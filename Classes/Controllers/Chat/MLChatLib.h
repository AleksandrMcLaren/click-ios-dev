//
//  MLChatLib.h
//  click
//
//  Created by Александр on 11.02.17.
//  Copyright © 2017 Click. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MLChatLib : NSObject

+ (NSDateFormatter *)formatterDate_HH_mm;
+ (NSDateFormatter *)formatterDate_yyyy_MM_dd;

+ (CGSize)textSizeLabel:(UILabel *)label withWidth:(CGFloat)width;

@end
