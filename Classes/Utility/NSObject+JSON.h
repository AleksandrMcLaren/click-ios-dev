//
//  NSObject+JSON.h
//  click
//
//  Created by Дрягин Павел on 15.12.16.
//  Copyright © 2016 Click. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (JSON)

-(NSString*)serializeToJSON;
-(NSObject*)deserializeWithJSON:(NSString*)json;

@end
