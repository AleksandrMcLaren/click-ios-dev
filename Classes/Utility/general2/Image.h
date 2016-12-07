//  Created by Дрягин Павел
//  Copyright © 2016 Click. All rights reserved.



#import <Foundation/Foundation.h>
 

@interface Image : NSObject


+ (UIImage *)square:(UIImage *)image size:(CGFloat)size;

+ (UIImage *)resize:(UIImage *)image width:(CGFloat)width height:(CGFloat)height scale:(CGFloat)scale;

@end

