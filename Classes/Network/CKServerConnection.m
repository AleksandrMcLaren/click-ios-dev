//
//  CKServerConnection.m
//  click
//
//  Created by Igor Tetyuev on 21.03.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKServerConnection.h"
#import "SAMKeychain.h"

#define CONNECTION_OPEN_CALLBACK_IDENTIFIER @"CONNECTION_OPEN_CALLBACK_IDENTIFIER"

@interface CKServerConnection()

@property (nonatomic, strong, readonly) NSString* entryPoint;

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

- (void)connect
{
    [self connect:self.entryPoint callback:nil] ;
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
    _queue = [NSMutableArray new];
    _isConnecting = YES;
    [_connection open];

}

- (void)sendDataWithAlert:(NSDictionary *)data successfulCompletion:(CKServerConnectionExecuted)completion{
    [self sendData:data completion:^(NSDictionary *result) {
        if ([result socketMessageStatus] == S_OK){
                completion(result);
        }else{
            [[[CKApplicationModel sharedInstance] mainController] showAlertWithResult:result completion:nil];
        }
    }];
}

- (void)sendData:(NSDictionary *)data completion:(CKServerConnectionExecuted)completion
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
    
    NSLog(@"\n[Socket Request]\n%@", data);

    
    if(_connection.readyState == SR_CONNECTING) {
        [_queue addObject:sendString];
    } else if(_connection.readyState == SR_CLOSED) {
        [_queue addObject:sendString];
        [self connect];
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
    NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:[message dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    NSLog(@"\n[Socket Response]\n%@", dict);
    if([[dict objectForKey:@"action"] isEqualToString:@"onopen"]) {
        [self processIncomingEvent:dict];
        CKServerConnectionExecuted callback = [_callbacks objectForKey:CONNECTION_OPEN_CALLBACK_IDENTIFIER];
        if (callback){
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(dict);
            });
            [_callbacks removeObjectForKey:CONNECTION_OPEN_CALLBACK_IDENTIFIER];
        }
    }
    if([[dict objectForKey:@"action"] isEqualToString:@"onmessage"]) {
        [self processIncomingEvent:dict];
    }
    NSString *mid = [dict objectForKey:@"mid"];
    if (mid)
    {
//        CKServerConnectionExecuted callback = [_callbacks objectForKey:mid];
//        if (callback)
//        {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                callback(dict);
//            });
//        }
//
        [self runCallBack:[_callbacks objectForKey:mid] withValue:dict];
        [_callbacks removeObjectForKey:mid];
    }
}

-(void)runCallBack:(id)callBack withValue:(id) value{
    CKServerConnectionExecuted block = callBack;
    if (block)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            block(value);
        });
    }
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    NSLog(@"didOpen %@", webSocket.url);
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
            for (id callBack in _callbacks.allValues) {
                NSLog(@"%@ class", callBack );
                [self runCallBack:callBack withValue:nil];
            }
            [_callbacks removeAllObjects];
        }
        [self connect];
    }
}


- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload
{
    NSLog(@"didReceivePong %@ %@", webSocket.url, pongPayload);
}

@end
