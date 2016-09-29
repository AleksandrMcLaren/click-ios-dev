//
//  CKServerConnection.h
//  click
//
//  Created by Igor Tetyuev on 21.03.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SocketRocket/SRWebSocket.h>

typedef void (^CKServerConnectionExecuted)(NSDictionary* result);
typedef void (^CKServerConnectionExecutedStatus)(NSInteger status);
typedef void (^CKServerConnectionExecutedStatus)(NSInteger status);

@interface CKServerConnection : NSObject<SRWebSocketDelegate>

+ (instancetype)sharedInstance;

- (void)connect;

@property (nonatomic, strong) NSData *apnToken;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSString *token;

@property (nonatomic, readonly) BOOL isConnected;

- (void)connect:(NSString *)entryPoint;
- (void)sendData:(NSDictionary *)data completion:(CKServerConnectionExecuted)completion;
- (void)processIncomingEvent:(NSDictionary *)eventData;

@end
