//
//  NSDictionary+CKSocketMessage.m
//  click
//
//  Created by Дрягин Павел on 15.10.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "NSDictionary+CKSocketMessage.h"

@implementation NSDictionary (CKSocketMessage)

-(id)socketMessageResult{
    return self[CKSocketMessageFieldResult] ;
}

-(NSInteger)socketMessageResultInteger{
    return [[self socketMessageResult] integerValue];
}

-(CKStatusCode)socketMessageStatus{
    CKStatusCode status = S_UNDEFINED;
    if (self[CKSocketMessageFieldStatus]){
        status = (CKStatusCode) [self[CKSocketMessageFieldStatus] integerValue] ;
    }
    return status;
}

-(NSString*)socketMessageMid{
    return self[CKSocketMessageFieldMID];
}

-(NSString*)socketMessageAction{
    return self[CKSocketMessageFieldAction];
}

-(NSDictionary*)prepared{
    NSMutableDictionary* attributes = [[NSMutableDictionary alloc] init];
    
    for (NSString* key in self.allKeys) {
        id value = self[key];
        
        if (![[self valueForKey:key] isKindOfClass:[NSNull class] ]) {
            [attributes setValue:value forKey:key];
        }
    }
    return attributes;
}

@end
