//
//  CKAttachModel.h
//  click
//
//  Created by Igor Tetyuev on 10.06.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum CKAttachType {
    CKAttachTypeFile,
    CKAttachTypeImage,
    CKAttachTypeVideo,
    CKAttachTypeAudio,
    CKAttachTypeVoice,
    CKAttachTypeContact,
    CKAttachTypeLocation
} CKAttachType;

@interface CKAttachModel : NSObject

- (instancetype)initWithDictionary:(NSDictionary *)dict;

+ (CKAttachModel *)modelWithDictionary:(NSDictionary *)dict;

@property (nonatomic, strong) UIImage *preview;
@property (nonatomic, readonly) NSData *data;
@property (nonatomic, readonly) NSString *contentType;
@property (nonatomic, readonly) CKAttachType type;
@property (nonatomic, readonly) NSString *uuid;
@property (nonatomic, readonly) NSString *filename;
@property (nonatomic, assign) BOOL isBusy;

@end
