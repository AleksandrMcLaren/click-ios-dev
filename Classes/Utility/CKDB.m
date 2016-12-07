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

@interface CKDB(){
    BOOL _created;
}

@end

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
        [self copyDatabaseIfNeeded];
        _queue = [FMDatabaseQueue databaseQueueWithPath:[CKDB databasePath]];
        if (!_created) {
            [self createDataBase];
            _created = YES;
        }
        
    }
    return self;
}

-(void)copyDatabaseIfNeeded{
    
    // copy database from resources
    NSString *destPath = [CKDB databasePath];
    NSLog(@"DB Path:%@", destPath);
    _created = [[NSFileManager defaultManager] fileExistsAtPath:destPath];
    
    if (!_created){
        NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"click" ofType:@"db"];
        [[NSFileManager defaultManager] copyItemAtPath:sourcePath toPath:destPath error:nil];
    }
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

+ (NSString *)dataDir
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"data"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSError *dirCreationError = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:path
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&dirCreationError];
        if (dirCreationError != nil) {
            NSLog(@"Ошибка создания папки для кэша");
            assert(0);
        }
    }
    return path;
}

+ (NSString *)databasePath
{
    return [[CKDB dataDir] stringByAppendingPathComponent:@"click.db"];
}

-(void)createDataBase{
    
    [_queue inDatabase:^(FMDatabase *db) {
        NSString* sql = @"CREATE TABLE `dialogs` ( \
        `avatar`	TEXT, \
        `canwrite`	INTEGER, \
        `cntattach`	INTEGER, \
        `cntonline`	INTEGER, \
        `cnttotal`	INTEGER, \
        `date`	TEXT, \
        `dlgadmin`	INTEGER, \
        `dlgavatar`	TEXT, \
        `dlgdesc`	TEXT, \
        `dlgname`	TEXT, \
        `entryid`	TEXT NOT NULL UNIQUE, \
        `inblacklist`	INTEGER, \
        `lat`	NUMERIC, \
        `lng`	NUMERIC, \
        `login`	TEXT, \
        `message`	INTEGER, \
        `msgid`	TEXT , \
        `msgstatus`	INTEGER, \
        `msgtotal`	INTEGER, \
        `msgtype`	INTEGER, \
        `msgunread`	INTEGER, \
        `name`	TEXT, \
        `owner`	INTEGER, \
        `state`	INTEGER, \
        `status`	INTEGER, \
        `surname`	TEXT, \
        `type`	INTEGER, \
        `userid`	INTEGER, \
        PRIMARY KEY(`entryid`) \
        ) ";
        BOOL success = [db executeUpdate:sql];
        if (!success) {
            NSLog(@"dialogs create error %@", [db lastError]);
        }
    }];
    
    [_queue inDatabase:^(FMDatabase *db) {
        NSString* sql = @"CREATE TABLE `users` ( \
        'age' INTEGER, \
        'avatar' TEXT, \
        'birthdate' TEXT, \
        'city' INTEGER, \
        'cityname' TEXT, \
        'country' INTEGER, \
        'countryname' TEXT, \
        'distance' NUMERIC, \
        'geostatus' INTEGER, \
        'id' TEXT, \
        'inanonblacklist' INTEGER, \
        'inblacklist' INTEGER, \
        'invite' TEXT, \
        'isfriend' INTEGER, \
        'isliked' INTEGER, \
        'iso' INTEGER, \
        'lat' NUMERIC, \
        'likes' INTEGER, \
        'lng' NUMERIC, \
        'login'  TEXT, \
        'name' TEXT, \
        'registereddate' TEXT, \
        'reregister' INTEGER, \
        'sex' TEXT, \
        'status' INTEGER, \
        'statusdate' TEXT, \
        'surname' TEXT, \
         PRIMARY KEY(`id`) \
        )";
        BOOL success = [db executeUpdate:sql];
        if (!success) {
            NSLog(@"users create error %@", [db lastError]);
        }
    }];
   
    [_queue inDatabase:^(FMDatabase *db) {
        NSString* sql = @"CREATE TABLE `messages` ( \
        attach  TEXT, \
        date  TEXT, \
        dialogstate INTEGER, \
        dialogtype INTEGER, \
        entryid  TEXT, \
        id TEXT, \
        lat NUMERIC, \
        lng NUMERIC, \
        message  TEXT, \
        owner NUMERIC, \
        status NUMERIC, \
        timer NUMERIC, \
        type INTEGER, \
        useravatar  TEXT, \
        userid TEXT, \
        userlist  TEXT, \
        userlogin TEXT, \
        username  TEXT, \
        userstatus  INTEGER, \
        usersurname   TEXT, \
        PRIMARY KEY(`id`) \
        )";
        BOOL success = [db executeUpdate:sql];
        if (!success) {
            NSLog(@"users create messages %@", [db lastError]);
        }
    }];
}

-(void)updateTable:(NSString*)table withValues:(NSDictionary*)values{
    NSDictionary* preparedValues = [values prepared];
    [self.queue inDatabase:^(FMDatabase *db) {
        NSMutableArray* cols = [[NSMutableArray alloc] init];
        NSMutableArray* vals = [[NSMutableArray alloc] init];
        for (id key in preparedValues) {
            [cols addObject:key];
//            NSJSONSerialization
            id value = [preparedValues objectForKey:key];
            if ([value isKindOfClass:[NSArray class]]) {
                NSData* innerJson = [NSJSONSerialization dataWithJSONObject:value options:0 error:NULL];
                value = [[NSString alloc] initWithData:innerJson encoding:NSUTF8StringEncoding];
            }
            [vals addObject:value];
        }
        NSMutableArray* newCols = [[NSMutableArray alloc] init];
        NSMutableArray* newVals = [[NSMutableArray alloc] init];
        for (int i = 0; i<[cols count]; i++) {
            [newCols addObject:[NSString stringWithFormat:@"'%@'", [cols objectAtIndex:i]]];
            [newVals addObject:[NSString stringWithFormat:@"'%@'", [vals objectAtIndex:i]]];
        }
        NSString* sql = [NSString stringWithFormat:@"insert or replace into %@ (%@) values (%@)", table, [newCols componentsJoinedByString:@", "], [newVals componentsJoinedByString:@", "]];
        BOOL success = [db executeUpdate:sql];
        if (!success) {
            NSLog(@"%@", [db lastError]);
        }
    }];
}
@end
