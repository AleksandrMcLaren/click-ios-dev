//  Created by Дрягин Павел
//  Copyright © 2016 Click. All rights reserved.



#import <UIKit/UIKit.h>

#import "AudioMediaItem.h"
#import "PhotoMediaItem.h"
#import "VideoMediaItem.h"

//#import "DBMessage.h"


@interface MediaManager : NSObject


#pragma mark - Picture

+ (void)loadPicture:(PhotoMediaItem *)mediaItem dbmessage:(Message *)dbmessage wifi:(BOOL)wifi
	 collectionView:(UICollectionView *)collectionView;

+ (void)loadPictureManual:(PhotoMediaItem *)mediaItem dbmessage:(Message *)dbmessage
		   collectionView:(UICollectionView *)collectionView;

#pragma mark - Video

+ (void)loadVideo:(VideoMediaItem *)mediaItem dbmessage:(Message *)dbmessage wifi:(BOOL)wifi
   collectionView:(UICollectionView *)collectionView;

+ (void)loadVideoManual:(VideoMediaItem *)mediaItem dbmessage:(Message *)dbmessage
		 collectionView:(UICollectionView *)collectionView;

#pragma mark - Audio

+ (void)loadAudio:(AudioMediaItem *)mediaItem dbmessage:(Message *)dbmessage wifi:(BOOL)wifi
   collectionView:(UICollectionView *)collectionView;

+ (void)loadAudioManual:(AudioMediaItem *)mediaItem dbmessage:(Message *)dbmessage
		 collectionView:(UICollectionView *)collectionView;

@end

