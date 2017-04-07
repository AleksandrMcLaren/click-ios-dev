//
//  CKServerConnection.h
//  click
//
//  Created by Igor Tetyuev on 21.03.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SocketRocket/SRWebSocket.h>
#import "CKStatusCode.h"

typedef void (^CKServerConnectionExecuted)(NSDictionary* result);
typedef void (^CKServerConnectionExecutedStatus)(CKStatusCode status);
typedef void (^CKServerConnectionExecutedObject)(id model);

@interface CKServerConnection : NSObject<SRWebSocketDelegate>

+ (instancetype)sharedInstance;

- (void)connect;

@property (nonatomic, strong) NSData *apnToken;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSString *token;

@property (nonatomic, readonly) BOOL isConnected;

- (void)connectWithCallback:(CKServerConnectionExecuted)callback;
- (void)sendData:(NSDictionary *)data completion:(CKServerConnectionExecuted)completion;
- (void)sendData:(NSDictionary *)data completion:(CKServerConnectionExecuted)completion failure:(void (^)())failure;
//- (void)sendDataWithAlert:(NSDictionary *)data successfulCompletion:(CKServerConnectionExecuted)completion;
//- (void)sendData:(NSDictionary *)data successfulCompletion:(CKServerConnectionExecuted)successfulCompletion
//badResponseCompletion:(CKServerConnectionExecuted)badResponseCompletion;
- (void)processIncomingEvent:(NSDictionary *)eventData;

@end
