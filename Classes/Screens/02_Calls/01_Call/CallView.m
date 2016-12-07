//  Created by Дрягин Павел
//  Copyright © 2016 Click. All rights reserved.



#import "CallView.h"
#import "AppDelegate.h"


@interface CallView()
{
	CKUser *dbuser;
	NSTimer *timer;
	BOOL incoming, outgoing;
	BOOL muted, speaker;

	id call;
	id audioController;
}

@property (strong, nonatomic) IBOutlet UIImageView *imageUser;
@property (strong, nonatomic) IBOutlet UILabel *labelInitials;
@property (strong, nonatomic) IBOutlet UILabel *labelName;
@property (strong, nonatomic) IBOutlet UILabel *labelStatus;

@property (strong, nonatomic) IBOutlet UIView *viewButtons;
@property (strong, nonatomic) IBOutlet UIButton *buttonMute;
@property (strong, nonatomic) IBOutlet UIButton *buttonSpeaker;
@property (strong, nonatomic) IBOutlet UIButton *buttonVideo;

@property (strong, nonatomic) IBOutlet UIView *viewButtons1;
@property (strong, nonatomic) IBOutlet UIView *viewButtons2;

@property (strong, nonatomic) IBOutlet UIView *viewEnded;

@end


@implementation CallView


@end

