//
//  CKCountrySelectionController.h
//  click
//
//  Created by Igor Tetyuev on 10.03.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKCountrySelectionController;

@protocol CKCountrySelectionControllerDelegate <NSObject>

- (void) countrySelectionController:(CKCountrySelectionController *)controller didSelectCountryWithId:(NSInteger)id name:(NSString *)name code:(NSNumber *)code;

@end

@interface CKCountrySelectionController : UIViewController<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (nonatomic, assign) id<CKCountrySelectionControllerDelegate>delegate;

@end
