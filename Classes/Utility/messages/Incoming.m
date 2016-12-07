//  Created by Дрягин Павел
//  Copyright © 2016 Click. All rights reserved.


#import "Incoming.h"

@interface Incoming()
{
	NSString *senderId;
	NSString *senderName;
	NSDate *date;

	BOOL wifi;
	BOOL maskOutgoing;

	Message *dbmessage;
	JSQMessagesCollectionView *collectionView;
}
@end


@implementation Incoming


- (id)initWith:(Message *)dbmessage_ CollectionView:(JSQMessagesCollectionView *)collectionView_

{
	self = [super init];
	
	dbmessage = dbmessage_;
	collectionView = collectionView_;
	
	wifi = [Connection isReachableViaWiFi];
	
	return self;
}


- (JSQMessage *)createMessage

{
	senderId = dbmessage.userid;
	senderName = dbmessage.senderName;
    date = dbmessage.date;
    
	maskOutgoing = [senderId isEqualToString:[CKUser currentId]];

    return [self createTextMessage];
    
//	if ([dbmessage.type isEqualToString:MESSAGE_TEXT])		return [self createTextMessage];
//	if ([dbmessage.type isEqualToString:MESSAGE_EMOJI])		return [self createEmojiMessage];
//	if ([dbmessage.type isEqualToString:MESSAGE_PICTURE])	return [self createPictureMessage];
//	if ([dbmessage.type isEqualToString:MESSAGE_VIDEO])		return [self createVideoMessage];
//	if ([dbmessage.type isEqualToString:MESSAGE_AUDIO])		return [self createAudioMessage];
//	if ([dbmessage.type isEqualToString:MESSAGE_LOCATION])	return [self createLocationMessage];
	
	return nil;
}

#pragma mark - Text message


- (JSQMessage *)createTextMessage

{
	NSString *text = dbmessage.text ;
//    [Cryptor decryptText:dbmessage.text groupId:dbmessage.groupId];
	
	return [[JSQMessage alloc] initWithSenderId:senderId senderDisplayName:senderName date:date text:text];
}

#pragma mark - Emoji message


- (JSQMessage *)createEmojiMessage

{
	NSString *text = @"123";//[Cryptor decryptText:dbmessage.text groupId:dbmessage.groupId];
	
	EmojiMediaItem *mediaItem = [[EmojiMediaItem alloc] initWithText:text];
	mediaItem.appliesMediaViewMaskAsOutgoing = maskOutgoing;
	
	return [[JSQMessage alloc] initWithSenderId:senderId senderDisplayName:senderName date:date media:mediaItem];
}

#pragma mark - Picture message


- (JSQMessage *)createPictureMessage

{
//	PhotoMediaItem *mediaItem = [[PhotoMediaItem alloc] initWithImage:nil Width:@(dbmessage.picture_width) Height:@(dbmessage.picture_height)];
//	mediaItem.appliesMediaViewMaskAsOutgoing = maskOutgoing;
//	
//	[MediaManager loadPicture:mediaItem dbmessage:dbmessage wifi:wifi collectionView:collectionView];
//	
//	return [[JSQMessage alloc] initWithSenderId:senderId senderDisplayName:senderName date:date media:mediaItem];
    return nil;
}

#pragma mark - Video message


- (JSQMessage *)createVideoMessage

{
	VideoMediaItem *mediaItem = [[VideoMediaItem alloc] initWithMaskAsOutgoing:maskOutgoing];
	
	[MediaManager loadVideo:mediaItem dbmessage:dbmessage wifi:wifi collectionView:collectionView];
	
	return [[JSQMessage alloc] initWithSenderId:senderId senderDisplayName:senderName date:date media:mediaItem];
}

#pragma mark - Audio message


- (JSQMessage *)createAudioMessage

{
	AudioMediaItem *mediaItem = [[AudioMediaItem alloc] initWithData:nil];
	mediaItem.appliesMediaViewMaskAsOutgoing = maskOutgoing;
	
	[MediaManager loadAudio:mediaItem dbmessage:dbmessage wifi:wifi collectionView:collectionView];
	
	return [[JSQMessage alloc] initWithSenderId:senderId senderDisplayName:senderName date:date media:mediaItem];
}

#pragma mark - Location message


- (JSQMessage *)createLocationMessage

{
	JSQLocationMediaItem *mediaItem = [[JSQLocationMediaItem alloc] initWithLocation:nil];
	mediaItem.appliesMediaViewMaskAsOutgoing = maskOutgoing;
	
//	CLLocation *location = [[CLLocation alloc] initWithLatitude:dbmessage.latitude longitude:dbmessage.longitude];
//	[mediaItem setLocation:location withCompletionHandler:^{
//		[collectionView reloadData];
//	}];
	
	return [[JSQMessage alloc] initWithSenderId:senderId senderDisplayName:senderName date:date media:mediaItem];
}

@end

