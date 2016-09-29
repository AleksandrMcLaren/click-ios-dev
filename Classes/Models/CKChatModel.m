//
//  CKChatModel.m
//  click
//
//  Created by Igor Tetyuev on 06.04.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKChatModel.h"
#import "CKMessageServerConnection.h"

@implementation CKSentMessageModel

@end

@implementation CKReceivedMessageModel

+ (instancetype)modelWithDictionary:(NSDictionary *)dict
{
    CKReceivedMessageModel *model = [CKMessageServerConnection sharedInstance].messageModelCache[dict[@"id"]];
    if (model) {
        return model;
    }
    
    model = [CKReceivedMessageModel new];
    model.isOwner = [dict[@"owner"] boolValue];
    model.message = dict[@"message"];
    model.id = dict[@"id"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"UTF"];
    [dateFormatter setDateFormat:@"YYYY-MM-DDThh:mm:ss"];
    model.date = [dateFormatter dateFromString:dict[@"date"]];
    
    model.fromUserID = [NSString stringWithFormat:@"%@", dict[@"userid"]];
    NSMutableArray *attachements = [NSMutableArray new];
    for (NSDictionary *i in dict[@"attach"])
    {
        CKAttachModel *attach = [CKAttachModel modelWithDictionary:i];
        [attachements addObject:attach];
        if (attach.preview) {
            model.attachPreviewCounter++;
        }
    }
    model.attachements = attachements;
    model.timer = [dict[@"timer"] integerValue];
    model.location = CLLocationCoordinate2DMake([dict[@"lat"] doubleValue], [dict[@"lng"] doubleValue]);
    [CKMessageServerConnection sharedInstance].messageModelCache[model.id] = model;
    return model;
}

- (void)setAttachements:(NSArray *)attachements {
    [super setAttachements:attachements];
    for (CKAttachModel *attach in attachements) {
        @weakify(self);
        [[RACObserve(attach, preview) skip:1] subscribeNext:^(id x) {
            @strongify(self);
            self.attachPreviewCounter++;
        }];
    }
}

@end

@implementation CKMessageModel

@end

@implementation CKChatModel

@end
