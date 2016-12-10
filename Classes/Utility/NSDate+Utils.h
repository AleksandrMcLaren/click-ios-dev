//
//  NSDate+Utils.h
//  click
//
//  Created by Дрягин Павел on 22.10.16.
//  Copyright © 2016 Click. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Utils)

+(NSString*)date2str:(NSDate*)date;

+(NSDate*)dateWithString:(NSString*)date;
+(NSString*)stringWithDate:(NSDate*)date;
@end
