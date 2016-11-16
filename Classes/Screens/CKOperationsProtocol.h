//
//  CKOperationsProtocol.h
//  click
//
//  Created by Дрягин Павел on 23.10.16.
//  Copyright © 2016 Click. All rights reserved.
//
@import Foundation;

@protocol CKOperationsProtocol

@required

-(void)beginOperation:(NSString*)operation;
-(void)endOperation:(NSString*)operation;

@end
