//
//  NSObject+JSON.m
//  click
//
//  Created by Дрягин Павел on 15.12.16.
//  Copyright © 2016 Click. All rights reserved.
//

#import "NSObject+JSON.h"

@implementation NSObject (JSON)

-(NSString*)serializeToJSON{
    NSData *jsondata = [NSJSONSerialization dataWithJSONObject:self options:0 error:nil];
    NSString *json = [[NSString alloc] initWithData:jsondata encoding:NSUTF8StringEncoding];
    return json;
}

-(NSObject*)deserializeWithJSON:(NSString*)json{
    NSData *JSONData = [json dataUsingEncoding:NSUTF8StringEncoding];
    
    NSObject* result = [NSJSONSerialization JSONObjectWithData:JSONData
                                                  options:kNilOptions
                                                    error:nil];
    return result;
}
@end
