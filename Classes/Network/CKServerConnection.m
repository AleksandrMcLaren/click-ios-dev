//
//  CKServerConnection.m
//  click
//
//  Created by Igor Tetyuev on 21.03.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKServerConnection.h"
#import <SAMKeychain/SAMKeychain.h>
#import "CKUserServerConnection.h"
#import "Reachability.h"

#define CONNECTION_OPEN_CALLBACK_IDENTIFIER @"CONNECTION_OPEN_CALLBACK_IDENTIFIER"

@interface CKServerConnection()

@property (nonatomic, strong, readonly) NSString* entryPoint;
@property (nonatomic, strong) dispatch_queue_t queueReceiveMessage;
@property (nonatomic, strong) Reachability* internetReachable;

@end

@implementation CKServerConnection
{
    SRWebSocket *_connection;
    NSMutableDictionary *_callbacks;
    NSMutableArray *_queue;
    BOOL _isConnecting;
    NSString *_udid;
    NSString *_entryPoint;
}

- (instancetype)init
{
    if (self = [super init])
    {
        _callbacks = [NSMutableDictionary new];
        _udid = [CKServerConnection getUniqueDeviceIdentifierAsString];
        _queue = [NSMutableArray new];
        self.queueReceiveMessage = dispatch_queue_create("queueReceiveMessage", DISPATCH_QUEUE_SERIAL);
        
        [self createConnectByChangeInternetReachable];
    }
    return self;
}

+ (instancetype)sharedInstance
{
    static CKServerConnection *instance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    
    return instance;
}

+(NSString *)getUniqueDeviceIdentifierAsString
{
    NSString *appName=[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];
    NSString *strApplicationUUID = [SAMKeychain passwordForService:appName account:@"incoding"];
    if (strApplicationUUID == nil)
    {
        strApplicationUUID  = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        [SAMKeychain setPassword:strApplicationUUID forService:appName account:@"incoding"];
    }
    return strApplicationUUID;
}

- (void)createConnectByChangeInternetReachable
{
    self.internetReachable = [Reachability reachabilityForInternetConnection];
    
    __weak typeof(self) _weakSelf = self;
    self.internetReachable.reachableBlock = ^(Reachability *reachability) {
        
        if(_weakSelf && !_weakSelf.isConnected)
            [_weakSelf connect];
    };
    
    [self.internetReachable startNotifier];
}

- (void)connect
{
    [self connect:self.entryPoint callback:nil];
}

- (void)connectWithCallback:(CKServerConnectionExecuted)callback{
    [self connect:self.entryPoint callback:callback];
}

-(NSString*)entryPoint{
    return nil;
}

- (void)connect:(NSString *)entryPoint callback:(CKServerConnectionExecuted)callback
{
    if (callback) {
        _callbacks[CONNECTION_OPEN_CALLBACK_IDENTIFIER] = callback;
    }
    NSMutableString *connectionString = [NSMutableString stringWithFormat:@"wss://chatclick.ru:8101/%@?", entryPoint];
    
    if (self.phoneNumber)
    {
        [connectionString appendFormat:@"id=%@",self.phoneNumber];
    }
    if (self.token)
    {
        [connectionString appendFormat:@"&uuid=%@",self.token];
    }
    if (self.apnToken)
    {
        NSString *encodedString = [[self.apnToken base64EncodedStringWithOptions:0] stringByAddingPercentEncodingWithAllowedCharacters:[[NSCharacterSet characterSetWithCharactersInString:@"!*'();:@&=+$,/?%#[]"] invertedSet]];

        [connectionString appendFormat:@"&pushid=%@",encodedString];
    }
    if (_udid)
    {
        [connectionString appendFormat:@"&deviceid=%@",_udid];
    }
    [connectionString appendFormat:@"&osname=iOS"];
    NSString *osversion = [[UIDevice currentDevice] systemVersion];
    if (osversion)
    {
        [connectionString appendFormat:@"&osversion=%@",osversion];
    }

    NSURL* url = [NSURL URLWithString:connectionString];
    
    if (_connection && _connection.readyState != SR_CLOSED)
    {
        [_connection close];
    }
    _connection = [[SRWebSocket alloc] initWithURL:url];
    _connection.delegate = self;
    _isConnecting = YES;
    [_connection open];

}

//- (void)sendDataWithAlert:(NSDictionary *)data successfulCompletion:(CKServerConnectionExecuted)completion{
//    [self sendData:data completion:^(NSDictionary *result) {
//        if ([result socketMessageStatus] == S_OK){
//                completion(result);
//        }else{
//            [[[CKApplicationModel sharedInstance] mainController] showAlertWithResult:result completion:nil];
//        }
//    }];
//}

//- (void)sendData:(NSDictionary *)data successfulCompletion:(CKServerConnectionExecuted)successfulCompletion
//badResponseCompletion:(CKServerConnectionExecuted)badResponseCompletion{
//    [self sendData:data completion:^(NSDictionary *result) {
//        if ([result socketMessageStatus] == S_OK){
//            successfulCompletion(result);
//        }else{
//            badResponseCompletion(result);
//        }
//    }];
//}

- (void)sendData:(NSDictionary *)data completion:(CKServerConnectionExecuted)completion
{
    [self sendData:data completion:completion failure:nil];
}

- (void)sendData:(NSDictionary *)data completion:(CKServerConnectionExecuted)completion failure:(void (^)())failure
{
    if (!_connection)
    {
        NSLog(@"Not connected");
        [self connect];
    }
    
    NSMutableDictionary *mdata = [NSMutableDictionary dictionaryWithDictionary:data];
    
    NSString *mid = [mdata objectForKey:@"mid"];
    
    if(!mid) {
        mid = [[NSUUID UUID] UUIDString];
        [mdata setObject:mid forKey:@"mid"];
    }
    _callbacks[mid] = completion;
    
    
    NSData *jsondata = [NSJSONSerialization dataWithJSONObject:mdata options:0 error:nil];
    NSString *sendString = [[NSString alloc] initWithData:jsondata encoding:NSUTF8StringEncoding];
    
    NSMutableDictionary* values = [[NSMutableDictionary alloc] initWithDictionary:data];
    if ([values objectForKey:@"options"]) {
        NSMutableDictionary* options = ((NSDictionary*)[values objectForKey:@"options"]).mutableCopy;
        if ([options objectForKey:@"avatar"]) {
            [options setObject:@"avatar exist" forKey:@"avatar"];
            [values setObject:options forKey:@"options"];
        }
        
    }
    NSLog(@"\n[Socket Request]\n%@", values);

    
    if(_connection.readyState == SR_CONNECTING) {
       
        [_queue addObject:sendString];
        
        if(failure)
            failure();
        
    } else if(_connection.readyState == SR_CLOSED) {
        [self connect];
        [_queue addObject:sendString];
        
        if(failure)
            failure();
        
    } else {
        [_connection send:sendString];
    }
    
}


- (void)processIncomingEvent:(NSDictionary *)eventData
{
    
}


#pragma mark SRWebSocket delegate
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    dispatch_async(self.queueReceiveMessage, ^{
        
        NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:[message dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
        NSLog(@"\n[Socket Response]\n%@", dict);
        if([[dict objectForKey:@"action"] isEqualToString:@"onopen"]) {
      
            CKServerConnectionExecuted callback = [_callbacks objectForKey:CONNECTION_OPEN_CALLBACK_IDENTIFIER];
            if (callback){
                    callback(dict);
                [_callbacks removeObjectForKey:CONNECTION_OPEN_CALLBACK_IDENTIFIER];
            }
        }
        else
        {
            [self processIncomingEvent:dict];
        }
        
        NSString *mid = [dict objectForKey:@"mid"];
        if (mid)
        {
            [self runCallBack:[_callbacks objectForKey:mid] withValue:dict];
            [_callbacks removeObjectForKey:mid];
        }
        
    });
}

-(void)runCallBack:(id)callBack withValue:(id) value{
    CKServerConnectionExecuted block = callBack;
    if (block)
    {
        block(value);
    }
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    NSLog(@"didOpen %@", webSocket.url);
    
    [[CKUserServerConnection sharedInstance] setUserStatus:@1];
    
    _isConnected = YES;
    _isConnecting = NO;
    NSMutableArray *newQueue = [NSMutableArray new];
    for(NSString *i in _queue) {
        @try {
            if(_connection.readyState != SR_CONNECTING) {
                NSLog(@"resending: %@", i);
                [_connection send:i];   
            } else {
                NSLog(@"Socket is fuzzy");
                [newQueue addObject:i];
            }
        }
        @catch(NSError* err) {
            NSLog(@"Network Error %@", err.description);
        }
    }
    _queue = newQueue;
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError %@ %@", webSocket.url, error);
     _isConnected = NO;
//    if (_connection.readyState == SR_CLOSED) {
        //Error Domain=com.squareup.SocketRocket Code=504 "Timeout Connecting to Server" UserInfo={NSLocalizedDescription=Timeout Connecting to Server}
        if (error.code == 504) {
             [self runCallBackWithError];
        }
//    }
}
- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    NSLog(@"didCloseWithCode %@ code:%ld reason:%@ wasClean:%d", webSocket.url,(long)code, reason, wasClean);
    _isConnected = NO;
    if(_isConnecting) {
        // do nothing
        NSLog(@"Connecting now");
    } else {
        NSLog(@"Reconnect");
        if ((_callbacks.count) && (!_queue.count)) {
            NSLog(@"Есть не обработанные callbacks");
            [self runCallBackWithError];
        }
        [self connect];
    }
}

-(void)runCallBackWithError{
    for (id callBack in _callbacks.allValues) {
        NSLog(@"%@ class", callBack );
        [self runCallBack:callBack withValue:@{CKSocketMessageFieldStatus:@(S_UNDEFINED)}];
    }
    [_callbacks removeAllObjects];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload
{
    NSLog(@"didReceivePong %@ %@", webSocket.url, pongPayload);
}

@end
