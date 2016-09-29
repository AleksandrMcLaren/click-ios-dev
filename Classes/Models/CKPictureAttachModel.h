//
//  CKPictureAttachModel.h
//  click
//
//  Created by Igor Tetyuev on 10.06.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKAttachModel.h"

@interface CKPictureAttachModel : CKAttachModel

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSURL *url;
- (void) prepareForDisplay:(void(^)(NSString *path))completion;
@property (nonatomic, strong) NSString *localPath;

@end
