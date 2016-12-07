//  Created by Дрягин Павел
//  Copyright © 2016 Click. All rights reserved.


#import "MessageSend1.h"
#import "AppDelegate.h"


@interface MessageSend1()
{
	NSString* _groupId;
	UIView* _view;
}
@end


@implementation MessageSend1


- (id)initWith:(NSString *)groupId_ View:(UIView *)view_

{
	self = [super init];
	_groupId = groupId_;
	_view = view_;
	return self;
}



@end

