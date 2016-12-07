//  Created by Дрягин Павел
//  Copyright © 2016 Click. All rights reserved.


#import "utilities.h"

@implementation Connection


+ (Connection *)shared

{
	static dispatch_once_t once;
	static Connection *connection;
	
	dispatch_once(&once, ^{ connection = [[Connection alloc] init]; });
	
	return connection;
}


- (id)init

{
	self = [super init];
	
	self.reachability = [Reachability reachabilityWithHostname:@"www.google.com"];
	[self.reachability startNotifier];
	
	[NotificationCenter addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification];
	
	return self;
}

#pragma mark - Reachability methods


+ (BOOL)isReachable

{
	return [self shared].reachability.isReachable;
}


+ (BOOL)isReachableViaWWAN

{
	return [self shared].reachability.isReachableViaWWAN;
}


+ (BOOL)isReachableViaWiFi

{
	return [self shared].reachability.isReachableViaWiFi;
}

#pragma mark -


- (void)reachabilityChanged:(NSNotification *)notification

{
}


- (void)sendMessage:(Message *)dbmessage

{
}

@end

