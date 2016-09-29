//
//  CKAttachModel.m
//  click
//
//  Created by Igor Tetyuev on 10.06.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKAttachModel.h"
#import "CKPictureAttachModel.h"
#import "CKVideoAttachModel.h"
#import "CKCloudAttachModel.h"

@implementation CKAttachModel

- (instancetype)init {
    if (self = [super init]) {
        _uuid = [[NSUUID UUID] UUIDString];
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        _uuid = dict[@"id"];
        _contentType = dict[@"contenttype"];
        _type = (CKAttachType)[dict[@"attach_type"] integerValue];
    }
    return self;
}

+ (CKAttachModel *) modelWithDictionary:(NSDictionary *)dict
{
    NSLog(@"%@", dict);
    CKAttachModel *result = nil;
    CKAttachType type = (CKAttachType)[dict[@"attach_type"] integerValue];
    switch (type) {
        case CKAttachTypeFile:
            result = [CKCloudAttachModel modelWithDictionary:dict];
            break;
        case CKAttachTypeImage:
            result = [CKPictureAttachModel modelWithDictionary:dict];
            break;
        case CKAttachTypeVideo:
            result = [CKVideoAttachModel modelWithDictionary:dict];
            break;
        default:
            result = [CKAttachModel new];
            break;
    }
    return result;
}


@end
