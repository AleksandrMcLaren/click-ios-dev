//  Created by Дрягин Павел
//  Copyright © 2016 Click. All rights reserved.



#import "VideoView.h"


@interface VideoView()
{
	NSURL *url;
	AVPlayerViewController *controller;
}
@end


@implementation VideoView


- (id)initWith:(NSURL *)url_

{
	self = [super init];
	url = url_;
	return self;
}


- (void)viewDidLoad

{
	[super viewDidLoad];
	
	[NotificationCenter addObserver:self selector:@selector(actionDone) name:AVPlayerItemDidPlayToEndTimeNotification];
}


- (void)viewWillAppear:(BOOL)animated

{
	[super viewWillAppear:animated];
	
	[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
	
	controller = [[AVPlayerViewController alloc] init];
	controller.player = [AVPlayer playerWithURL:url];
	[controller.player play];
	
	[self addChildViewController:controller];
	[self.view addSubview:controller.view];
	controller.view.frame = self.view.frame;
}


- (void)viewWillDisappear:(BOOL)animated

{
	[super viewWillDisappear:animated];
	
	[NotificationCenter removeObserver:self];
}

#pragma mark - User actions


- (void)actionDone

{
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end

