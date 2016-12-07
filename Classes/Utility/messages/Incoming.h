//  Created by Дрягин Павел 
//  Copyright © 2016 Click. All rights reserved.

#import "Message.h"
#import "utilities.h"

@interface Incoming : NSObject


- (id)initWith:(Message *)dbmessage_ CollectionView:(JSQMessagesCollectionView *)collectionView_;

- (JSQMessage *)createMessage;

@end

