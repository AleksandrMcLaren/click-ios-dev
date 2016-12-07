//  Created by Дрягин Павел on 18.11.16.
//  Copyright © 2016 Click. All rights reserved.


#import "StickersCell.h"


@interface StickersCell()

@property (strong, nonatomic) IBOutlet UIImageView *imageItem;

@end


@implementation StickersCell

@synthesize imageItem;


- (void)bindData:(NSString *)file

{
	imageItem.image = [UIImage imageNamed:file];
}

@end

