//
//  MLChatCellContentViewController.h
//  click
//
//  Created by Aleksandr on 07/02/2017.
//  Copyright © 2017 Click. All rights reserved.
//

@class MLChatMessageModel;


@protocol MLChatCellContentViewControllerDelegate;

@interface MLChatCellContentViewController : UIViewController

@property (nonatomic, weak) id<MLChatCellContentViewControllerDelegate> delegate;
@property (nonatomic, strong) MLChatMessageModel *message;

@end


@protocol MLChatCellContentViewControllerDelegate <NSObject>

@required
- (void)chatCellContentViewControllerNeedsSize:(CGSize)size;

@end


@interface MLChatMessageModel : NSObject

@property (nonatomic, strong) NSString *ident;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, assign) BOOL isFirst;
@property (nonatomic, assign) BOOL isOwner;
@property (nonatomic, assign) NSString *text;

@end
