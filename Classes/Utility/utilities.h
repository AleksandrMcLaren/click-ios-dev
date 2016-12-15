//
//  utilities.h
//  click
//
//  Created by Дрягин Павел on 20.11.16.
//  Copyright © 2016 Click. All rights reserved.
//#pragma mark - connections
//
//#import "CKUserServerConnection.h"
//#import "CKMessageServerConnection.h"
//
#import "CKAttachModel.h"
#import "NSObject+JSON.h"



#ifndef utilities_h
#define utilities_h

#import <AVKit/AVKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

//#import <Sinch/Sinch.h>
//#import <SinchService/SinchService.h>
#import <MapKit/MapKit.h>

#import "Reachability.h"
#import "RNGridMenu.h"
#import "IQAudioRecorderViewController.h"
#import "JSQMessages.h"
#import "MBProgressHUD.h"
#import "ProgressHUD.h"
#import "RNEncryptor.h"
#import "RNDecryptor.h"



#pragma mark - general1

#import "NotificationCenter.h"
#import "NSDictionary+Util.h"
#import "UserDefaults.h"
#import "CKGroupChatModel.h"

#pragma mark - general2

#import "Audio.h"
#import "Checksum.h"
#import "Cryptor.h"
#import "Dir.h"
#import "Emoji.h"
#import "File.h"
#import "Image.h"
#import "Password.h"
#import "Video.h"

#pragma mark - general3

#import "camera.h"
#import "common.h"
#import "converter.h"

#pragma mark - backend1

#import "FObject.h"
#import "CKUser.h"
#import "CKUser+Util.h"
#import "NSError+Util.h"

#pragma mark - backend2

#import "CallHistories.h"
#import "Groups.h"
#import "Recents.h"
#import "Users.h"
#import "UserStatuses.h"

#pragma mark - backend3

#import "Account.h"
#import "CallHistory.h"
#import "Group.h"
#import "CKChatModel.h"
#import "CKDialogChatModel.h"
#import "CKGroupChatModel.h"
#import "CKDialogsModel.h"

#pragma mark - messages


#import "Message.h"
#import "Connection.h"
#import "Incoming.h"
#import "MessageSend1.h"
#import "MessageSend2.h"
#import "MessageQueue.h"

#import "Recent.h"

#pragma mark - mediaitems

#import "EmojiMediaItem.h"
#import "AudioMediaItem.h"
#import "PhotoMediaItem.h"
#import "VideoMediaItem.h"

#pragma mark - manager

#import "AlbumManager.h"
#import "CacheManager.h"
#import "DownloadManager.h"
#import "MediaManager.h"

#endif /* utilities_h */
