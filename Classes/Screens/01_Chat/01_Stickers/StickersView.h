//  Created by Дрягин Павел on 18.11.16.
//  Copyright © 2016 Click. All rights reserved.


#import "utilities.h"


@protocol StickersDelegate


- (void)didSelectSticker:(NSString *)sticker;

@end


@interface StickersView : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>


@property (nonatomic, assign) IBOutlet id<StickersDelegate>delegate;

@end

