//
//  CKServerConnection.m
//  click
//
//  Created by Igor Tetyuev on 21.03.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "CKServerConnection.h"

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
        _udid = [[NSUserDefaults standardUserDefaults] objectForKey:@"udid"];
        if (!_udid)
        {
            _udid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
            [[NSUserDefaults standardUserDefaults] setObject:_udid forKey:@"udid"];
        }

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

- (void)connect
{
    [self connect:@"User"];
}

- (void)connect:(NSString *)entryPoint
{
    NSMutableString *connectionString = [NSMutableString stringWithFormat:@"ws://click.httpx.ru:8101/%@?", entryPoint];
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
    
    NSLog(@"sendData: %@", sendString);

    
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
    NSLog(@"[Socket Response] :: %@", dict);
    if([[dict objectForKey:@"action"] isEqualToString:@"onopen"]) {
        [self processIncomingEvent:dict];
    }
    if([[dict objectForKey:@"action"] isEqualToString:@"onmessage"]) {
        [self processIncomingEvent:dict];
    }
    NSString *mid = [dict objectForKey:@"mid"];
    if (mid)
    {
        CKServerConnectionExecuted callback = [_callbacks objectForKey:mid];
        if (callback)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(dict);
            });
        }
        [_callbacks removeObjectForKey:mid];
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
        [self connect];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload
{
    NSLog(@"didReceivePong %@ %@", webSocket.url, pongPayload);
}

@end
