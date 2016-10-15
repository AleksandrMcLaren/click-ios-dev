//
//  UIAlertController+CKSocketMessage.h
//  click
//
//  Created by Дрягин Павел on 15.10.16.
//  Copyright © 2016 Click. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertController (CKSocketMessage)

+(instancetype) newWithSocketResult:(NSDictionary*)result;

@end
