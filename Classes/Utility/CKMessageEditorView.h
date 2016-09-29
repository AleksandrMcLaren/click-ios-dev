//
//  CKMessageEditorView.h
//  click
//
//  Created by Igor Tetyuev on 08.04.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKDialogChatModel.h"

@interface CKMessageEditorView : UIControl<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) UIButton *showMediaButton;
@property (nonatomic, strong) NSArray *attachements;
@property (nonatomic, assign) CKDialogChatModel *chat;
@end
