//
//  CKDatabase.h
//  click
//
//  Created by Igor Tetyuev on 24.03.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB/FMDB.h>

@interface CKDB : NSObject

@property (nonatomic, readonly) FMDatabaseQueue *queue;

+ (instancetype)sharedInstance;
- (void) configureDB: (FMDatabase *)db;
- (void) updateTable:(NSString*)table withValues:(NSDictionary*)values;
@end
