//
//  CKFiltersForMapViewController.h
//  click
//
//  Created by Anatoly Mityaev on 25.10.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKMapViewController.h"
#import "CKCitySelectionController.h"
#import "CKCountrySelectionController.h"

@interface CKFiltersForMapViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UINavigationControllerDelegate,CKCountrySelectionControllerDelegate, CKCitySelectionControllerDelegate>

@property (nonatomic, assign) BOOL switchOn;
@property (nonatomic, strong) NSString *sex;
@property (nonatomic, strong) NSNumber *minage;
@property (nonatomic, strong) NSNumber *maxage;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, assign) NSInteger countryId;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, assign) NSInteger cityId;
@property (nonatomic, assign) BOOL endWithSumbit;
@property (nonatomic, assign) NSString *name;
@property (nonatomic, assign) BOOL allUsers;
@property (nonatomic, assign) NSInteger countryImageIso;
@property (nonatomic, assign) BOOL endWithCancelFilters;
@property (nonatomic, strong) CKUserModel *profile;


@end
