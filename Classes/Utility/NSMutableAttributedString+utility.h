//
//  NSMutableAttributedString+utility.h
//  click
//
//  Created by Igor Tetyuev on 18.03.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableAttributedString(utility)

+ (NSMutableAttributedString *)withString:(NSString *)string;
+ (NSAttributedString *)withImageName:(NSString *)image geometry:(CGRect)geometry;
+ (NSAttributedString *)withImage:(UIImage *)image geometry:(CGRect)geometry;
+ (NSMutableAttributedString *)withName:(NSString *)name surname:(NSString *)surname size:(double)size;

@end
