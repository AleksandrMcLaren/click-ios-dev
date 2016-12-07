//  Created by Дрягин Павел on 18.11.16.
//  Copyright © 2016 Click. All rights reserved.


#import "utilities.h"

#import "StickersView.h"


@interface ChatView : JSQMessagesViewController <RNGridMenuDelegate, UIImagePickerControllerDelegate, IQAudioRecorderViewControllerDelegate, StickersDelegate>

- (id)initWithChat:(CKChatModel *)chat;

@end

