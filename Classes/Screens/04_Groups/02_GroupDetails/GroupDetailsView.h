//  Created by Дрягин Павел
//  Copyright © 2016 Click. All rights reserved.



#import "utilities.h"

#import "SelectMultipleView.h"


@interface GroupDetailsView : UITableViewController <UIImagePickerControllerDelegate, SelectMultipleDelegate>


- (id)initWith:(NSString *)groupId Chat:(BOOL)chat;

@end

