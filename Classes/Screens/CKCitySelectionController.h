//
//  CKCitySelectionController.h
//  click
//
//  Created by Igor Tetyuev on 10.03.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKCitySelectionController;

@protocol CKCitySelectionControllerDelegate <NSObject>

- (void) citySelectionController:(CKCitySelectionController *)controller didSelectCityWithId:(NSInteger)id name:(NSString *)name;

@end

@interface CKCitySelectionController : UIViewController<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (nonatomic, assign) NSInteger countryId;
@property (nonatomic, assign) id<CKCitySelectionControllerDelegate>delegate;

@end
