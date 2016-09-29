//
//  CKCountryCell.h
//  click
//
//  Created by Igor Tetyuev on 10.03.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CKCountryCell : UITableViewCell

@property (nonatomic, readonly) UIImageView *countryBall;
@property (nonatomic, readonly) UILabel *title;
@property (nonatomic, readonly) UILabel *countryCode;

@end
