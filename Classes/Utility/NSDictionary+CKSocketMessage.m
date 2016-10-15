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


@end
