//
//  CKDatabase.m
//  click
//
//  Created by Igor Tetyuev on 24.03.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKDB.h"
#import "AppDelegate.h"
#include <sqlite3.h>

@implementation CKDB

+ (instancetype)sharedInstance
{
    static CKDB *instance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [CKDB new];
    });
    
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        _queue = [FMDatabaseQueue databaseQueueWithPath:[AppDelegate databasePath]];
    }
    return self;
}

static void myLow(sqlite3_context *context, int argc, sqlite3_value **argv)
{
    NSString* str = [[NSString alloc] initWithUTF8String:
                     (const char *)sqlite3_value_text(argv[0])];
    const char* s = [[str lowercaseString] UTF8String];
    sqlite3_result_text(context, s, (int) strlen(s), NULL);
}

- (void) configureDB:(FMDatabase *)db
{
    sqlite3_create_function(db.sqliteHandle, "myLow", 1, SQLITE_UTF8, NULL, &myLow, NULL, NULL);
}


@end
