//
//  MLChatTableViewCell.h
//  click
//
//  Created by Aleksandr on 03/02/2017.
//  Copyright © 2017 Click. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MLChatMessageModel;

@interface MLChatTableViewCell : UITableViewCell

@property (nonatomic, strong) MLChatMessageModel *message;

@end


@interface MLChatMessageModel : NSObject

@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, assign) BOOL isFirst;
@property (nonatomic, assign) BOOL isReceived;

@end
