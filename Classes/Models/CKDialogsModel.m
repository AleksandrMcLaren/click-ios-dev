//
//  CKDialogsModel.m
//  click
//
//  Created by Igor Tetyuev on 25.03.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKDialogsModel.h"
#import "CKMessageServerConnection.h"

@implementation CKDialogListEntryModel

+ (instancetype)modelWithDictionary:(NSDictionary *)dict
{
    CKDialogListEntryModel *model = [CKDialogListEntryModel new];
    
    model.userAvatarId = dict[@"avatar"];
    model.attachCount = [dict[@"cntattach"] integerValue];
    model.onlineUsersCount = [dict[@"cntonline"] integerValue];
    model.userCount = [dict[@"cnttotal"] integerValue];
    
    if ([((NSString *)dict[@"date"]) isEqualToString:@"0001-01-01T00:00:00"]) {
        model.date = nil;
    }
    else {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"UTF"];
        [dateFormatter setDateFormat:@"YYYY-MM-DDThh:mm:ss"];
        model.date = [dateFormatter dateFromString:dict[@"date"]];
    }
    
    model.dialogAvatarId = dict[@"dlgavatar"];
    model.dialogDescription = dict[@"dlgdesc"];
    model.dialogName = dict[@"dlgname"];
    model.dialogId = dict[@"entryid"];
    model.location = CLLocationCoordinate2DMake([dict[@"lat"] doubleValue], [dict[@"lon"] doubleValue]);
    model.userLogin = dict[@"login"];
    model.message = dict[@"message"];
    model.messageId = dict[@"msgid"];
    model.messageStatus = [dict[@"msgstatus"] integerValue];
    model.messagesTotal = [dict[@"msgtotal"] integerValue];
    model.messageType = [dict[@"msgtype"] integerValue];
    model.messagesUnread = [dict[@"msgunread"] integerValue];
    model.userName = dict[@"name"];
    model.userSurname = dict[@"surname"];
    model.isOwner = [dict[@"owner"] integerValue];
    model.state = [dict[@"state"] integerValue];
    model.status = [dict[@"status"] integerValue];
    model.type = [dict[@"type"] integerValue];
    model.userId = [NSString stringWithFormat:@"%@", dict[@"userid"]];

    
    return model;
}

@end

@interface CKDialogsModel()

@property (nonatomic, strong) NSArray *dialogs;

@end

@implementation CKDialogsModel

+ (instancetype)sharedInstance
{
    static CKDialogsModel *instance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [CKDialogsModel new];
    });
    
    return instance;
}

- (instancetype)init
{
    if (self = [super init])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadDialogList) name:CKMessageServerConnectionReceived object:nil];
    }
    return self;
}

- (void)run
{
    _dialogs = [NSMutableArray new];
    [self reloadDialogList];
}

- (void)reloadDialogList
{
    [[CKMessageServerConnection sharedInstance] getDialogListWithCallback:^(NSDictionary *result) {
        NSMutableArray *dialogs = [NSMutableArray new];
        for (NSDictionary *i in result[@"result"])
        {
            CKDialogListEntryModel *model = [CKDialogListEntryModel modelWithDictionary:i];
            [dialogs addObject:model];
        }
        self.dialogs = dialogs;
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
