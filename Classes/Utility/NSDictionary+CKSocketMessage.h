//
//  NSDictionary+CKSocketMessage.h
//  click
//
//  Created by Дрягин Павел on 15.10.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (CKSocketMessage)

-(id)socketMessageResult;
-(NSInteger)socketMessageResultInteger;

-(CKStatusCode)socketMessageStatus;
-(NSString*)socketMessageMid;
-(NSString*)socketMessageAction;
-(NSDictionary*)prepared;

@end
