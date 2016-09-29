//
//  CKAttachCell.h
//  click
//
//  Created by Igor Tetyuev on 10.06.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKAttachModel.h"

@interface CKAttachCell : UICollectionViewCell

@property (nonatomic, strong) CKAttachModel *model;
@property (nonatomic, strong) UIButton *deleteButton;

@end
