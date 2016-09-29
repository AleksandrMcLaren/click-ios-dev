#import <UIKit/UIKit.h>
#import "CKHTTPRequest.h"
#import "NSDictionary+UrlEncodedString.h"

static dispatch_queue_t http_requests_queue;

@implementation CKHTTPResponse

- (id)initWithData:(NSData *)d response:(NSHTTPURLResponse *)r request:(CKHTTPRequest *)request
{
    if ((self = [super init])) {
        self.data = d;
        self.response = r;
		self.request = request;
    }
    return self;
}

@end


@implementation CKHTTPError

- (id)initWithError:(NSError *)error httpResponse:(NSHTTPURLResponse *)response httpData:(NSData *)d request:(CKHTTPRequest *)request
{
    if ((self = [super init])) {

        self.httpResultData = d;

        if (response) {
            self.errorCode = response.statusCode;
            self.errorType = CKHttpError;
            
            /* В случае работы через прокси, такой вариант тоже нужно учитывать */
            if (self.errorCode == 503) {
                self.errorType = PZHostUnreachableError;
			}
        }

		self.request = request;

        if (error) {
            self.userInfo = error.userInfo;

            switch (error.code) {
                case NSURLErrorCannotFindHost:
                case NSURLErrorCannotConnectToHost:
                    self.errorType = PZHostUnreachableError;
                    break;
                case NSURLErrorTimedOut:
                    self.errorType = PZConnectionTimeoutError;
                    break;
                case NSURLErrorNetworkConnectionLost:
                    self.errorType = PZNetworkUnreachableError;
                    break;
                case PZRequestInternalError:
                    self.errorType = PZRequestInternalError;
                    break;
                default:
                    self.errorType = PZNetworkUnreachableError;
                    break;
            }
        }
    }

    return self;
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"\nКод ошибки: %ld\nТип ошибки: %ld\nHTTP-ответ: %@",
            (long)self.errorCode, self.errorType, [[NSString alloc] initWithData:self.httpResultData encoding:NSUTF8StringEncoding]];
}

@end

@interface CKHTTPRequest ()

@property(nonatomic, strong) NSMutableData *receivedData;
@property(nonatomic, strong) NSURLResponse *response;
@property(nonatomic, strong) NSURLConnection *connection;

- (NSString *)methodToString:(CKHTTPMethod)method;

@end


@implementation CKHTTPRequest
{
    BOOL _isCanceled;
}


- (id)init
{
    if ((self = [super init])) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            http_requests_queue = dispatch_queue_create("http_requests_queue", DISPATCH_QUEUE_SERIAL);
        });

        self.shouldShowNetworkActivityIndicator = YES;

        /* Устанавливем значение по-умолчанию, иначе на iOS 5 будет постоянно падать по таймауту */
        self.timeoutInterval = 60;
    }
    return self;
}


#pragma mark - Utils

+ (void)setNetworkActivityIndicatorVisible:(BOOL)setVisible
{
    static NSInteger numberOfCallsToSetVisible = 0;

    if (setVisible) {
        numberOfCallsToSetVisible++;
	}
    else if (numberOfCallsToSetVisible > 0) {
        numberOfCallsToSetVisible--;
	}

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:(numberOfCallsToSetVisible > 0)];
}


- (NSString *)methodToString:(CKHTTPMethod)method
{
    switch (method) {
        case GET:
            return @"GET";
        case HEAD:
            return @"HEAD";
        case POST:
            return @"POST";
        case DELETE:
            return @"DELETE";
        case PUT:
            return @"PUT";
        default:
            return nil;
    }
}


#pragma mark - Request

+ (CKHTTPRequest *)requestWithUrl:(NSString *)urlString
                           method:(CKHTTPMethod)method
                             body:(NSData *)body
                     extraHeaders:(NSDictionary *)headers
                       contentType:(NSString *)contentType
                        onSuccess:(CKHTTPRequestSuccessBlock)aSuccessBlock
                          onError:(CKHTTPRequestErrorBlock)anErrorBlock
{
    Class klass = [self class];
    CKHTTPRequest *request = [klass new];
    request.url = urlString;
    request.method = method;
    request.body = body;
    request.contentType = contentType;
    request.extraHeaders = headers;
	request.successBlock = aSuccessBlock;
	request.errorBlock = anErrorBlock;
    //request.request.cachePolicy = NSURLRequestReloadIgnoringCacheData;

    return request;
}


+ (CKHTTPRequest *)requestToGetUrl:(NSString *)url
                            params:(NSDictionary *)params
                         onSuccess:(CKHTTPRequestSuccessBlock)aSuccessBlock
                           onError:(CKHTTPRequestErrorBlock)anErrorBlock
{
    CKHTTPRequest *r =  [self requestWithUrl:url
                                      method:GET
                                        body:nil
                                extraHeaders:nil
                                  contentType:nil
                                   onSuccess:aSuccessBlock
                                     onError:anErrorBlock];
    if (params) {
        r.url = [NSString stringWithFormat:@"%@?%@", url, [params urlEncodedString]];
    }

    return r;
}

+ (CKHTTPRequest *)requestToPostParams:(NSDictionary *)params
                                 toUrl:(NSString *)url
                             onSuccess:(CKHTTPRequestSuccessBlock)aSuccessBlock
                               onError:(CKHTTPRequestErrorBlock)anErrorBlock
{
    CKHTTPRequest *r = [self requestWithUrl:url
                                     method:POST
                                       body:nil
                               extraHeaders:nil
                                 contentType:nil
                                  onSuccess:aSuccessBlock
                                    onError:anErrorBlock];

    r.body = [[params urlEncodedString] dataUsingEncoding:NSUTF8StringEncoding];
    return r;
}


+ (CKHTTPRequest *)requestToPostData:(NSData *)data
                               toUrl:(NSString *)url
                           onSuccess:(CKHTTPRequestSuccessBlock)aSuccessBlock
                             onError:(CKHTTPRequestErrorBlock)anErrorBlock
{
    return [self requestWithUrl:url method:POST body:data extraHeaders:nil contentType:nil onSuccess:aSuccessBlock onError:anErrorBlock];
}


+ (CKHTTPRequest *)requestToPostMultipartData:(NSData *)data
                                     filename:(NSString *)filename
                                       params:(NSDictionary *)params
                                        toUrl:(NSString *)url
                                    onSuccess:(CKHTTPRequestSuccessBlock)aSuccessBlock
                                      onError:(CKHTTPRequestErrorBlock)anErrorBlock
{
    NSMutableDictionary *ps = [params mutableCopy];

    NSDate *dt = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
    int timestamp = [dt timeIntervalSince1970];
    
    // You could calculate a better boundary here.
    NSString *HTTPRequestBodyBoundary = [NSString stringWithFormat:@"BOUNDARY-%d-%@", timestamp, [[NSProcessInfo processInfo] globallyUniqueString]];
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", HTTPRequestBodyBoundary];

    NSMutableData *HTTPRequestBody = [NSMutableData data];
    [HTTPRequestBody appendData:[[NSString stringWithFormat:@"--%@\r\n",HTTPRequestBodyBoundary] dataUsingEncoding:NSUTF8StringEncoding]];

    NSEnumerator *enumerator = [ps keyEnumerator];
    NSString *key;

    NSMutableArray *HTTPRequestBodyParts = [NSMutableArray array];

    while ((key = [enumerator nextObject])) {
        NSMutableData *someData = [[NSMutableData alloc] init];
        [someData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
        [someData appendData:[[NSString stringWithFormat:@"%@", [ps objectForKey:key]] dataUsingEncoding:NSUTF8StringEncoding]];

        [HTTPRequestBodyParts addObject:someData];
    }
    
    //
    NSMutableData *someData = [[NSMutableData alloc] init];
    [someData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"data\"\r\nContent-Type: application/octet-stream\r\n\r\n", filename] dataUsingEncoding:NSUTF8StringEncoding]];
    [someData appendData:data];
    
    [HTTPRequestBodyParts addObject:someData];
    //

    NSMutableData *resultingData = [NSMutableData data];
    NSUInteger count = [HTTPRequestBodyParts count];
    [HTTPRequestBodyParts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [resultingData appendData:obj];
        if (idx != count - 1) {
            [resultingData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", HTTPRequestBodyBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }];

    [HTTPRequestBody appendData:resultingData];
    [HTTPRequestBody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", HTTPRequestBodyBoundary] dataUsingEncoding:NSUTF8StringEncoding]];

    return [self requestWithUrl:url
                         method:POST
                           body:HTTPRequestBody
                   extraHeaders:nil
                     contentType:contentType
                      onSuccess:aSuccessBlock
                        onError:anErrorBlock];
}


+ (CKHTTPRequest *)requestToDeleteUrl:(NSString *)url
                            onSuccess:(CKHTTPRequestSuccessBlock)aSuccessBlock
                              onError:(CKHTTPRequestErrorBlock)anErrorBlock
{
    CKHTTPRequest *r =  [self requestWithUrl:url
                                      method:DELETE
                                        body:nil
                                extraHeaders:nil
                                  contentType:nil
                                   onSuccess:aSuccessBlock
                                     onError:anErrorBlock];
    
    return r;
}


- (void)start
{
    self.request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.url]
                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                       timeoutInterval:self.timeoutInterval];

    if (self.callbacksQueue == nil) {
        self.callbacksQueue = dispatch_get_main_queue();
    }
    
    NSString *httpMethod = [self methodToString:self.method];
    if (httpMethod == nil) {
        NSError *e = [NSError errorWithDomain:@"com.GFC.CKHTTPrequest"
                                         code:PZRequestInternalError
                                     userInfo:@{@"reason": @"Unknown HTTP method"}];
        
        CKHTTPError *error = [[CKHTTPError alloc] initWithError:e httpResponse:nil httpData:nil request:self];

        dispatch_async(self.callbacksQueue, ^{
            self.errorBlock(error);
        });
        return;
    }

    self.request.HTTPMethod = httpMethod;
	self.request.HTTPBody = self.body;

    for (NSString *header in self.extraHeaders) {
        [self.request setValue:self.extraHeaders[header] forHTTPHeaderField:header];
    }

    if (self.contentType) {
        [self.request setValue:self.contentType forHTTPHeaderField:@"content-type"];
    }
	
	self.receivedData = nil;
    self.response = nil;

	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	if (self.performOnSerialQueue) {
		queue = http_requests_queue;
	}

    dispatch_async(queue, ^{
        if (self.shouldShowNetworkActivityIndicator) {
            [CKHTTPRequest setNetworkActivityIndicatorVisible:YES];
        }

        self.connection = [NSURLConnection connectionWithRequest:self.request delegate:self];
		[self.connection start];

		if ([[NSRunLoop currentRunLoop] currentMode] == nil) {
			[[NSRunLoop currentRunLoop] run];
		}
	});
}


- (void)cancel
{
    _isCanceled = YES;
	[self.connection cancel];
	self.dataReceivedCallback = nil;
	self.successBlock = nil;
	self.errorBlock = nil;
	self.responseReceivedCallback = nil;
	
	if (self.shouldShowNetworkActivityIndicator) {
        [CKHTTPRequest setNetworkActivityIndicatorVisible:NO];
    }
}


#pragma mark - NSURLConnection delegate stuff

- (void)connection:(NSURLConnection *)aConnection didReceiveResponse:(NSURLResponse *)aResponse
{
    if (_isCanceled) {
        [aConnection cancel];
        return;
    }

	self.response = aResponse;

	CKHTTPResponse *resp = [[CKHTTPResponse alloc] initWithData:nil response:(NSHTTPURLResponse *)self.response request:self];

	dispatch_async(self.callbacksQueue, ^{
		if (self.responseReceivedCallback) {
			self.responseReceivedCallback(resp);
		}
	});
}


- (void)connection:(NSURLConnection *)aConnection didReceiveData:(NSData *)data
{
    if (_isCanceled) {
        [aConnection cancel];
        return;
    }

	if (self.receivedData == nil) {
		self.receivedData = [NSMutableData new];
    }

	[self.receivedData appendData:data];

	dispatch_async(self.callbacksQueue, ^{
		if (self.dataReceivedCallback) {
			self.dataReceivedCallback(self.receivedData.length, (long)self.response.expectedContentLength);
		}
	});
}


- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection
{
    if (self.shouldShowNetworkActivityIndicator) {
        [CKHTTPRequest setNetworkActivityIndicatorVisible:NO];
    }

    if (_isCanceled) {
        [aConnection cancel];
        return;
    }

	NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) self.response;

	if (httpResponse.statusCode != 200 && httpResponse.statusCode != 204) {
        CKHTTPError *error = [[CKHTTPError alloc] initWithError:nil httpResponse:httpResponse httpData:self.receivedData request:self];

		dispatch_async(self.callbacksQueue, ^{
            if (error.errorCode == 401) {
                [[NSNotificationCenter defaultCenter] postNotificationName:NOT_AUTHORIZED_RECEIVED object:error];
            }
			if (self.errorBlock) {
				self.errorBlock(error);
			}
		});
	} else {
		dispatch_async(self.callbacksQueue, ^{
			if (self.successBlock) {
				CKHTTPResponse *r = [[CKHTTPResponse alloc] initWithData:self.receivedData response:httpResponse request:self];
				self.successBlock(r);
			}
		});
	}
}


- (void)connection:(NSURLConnection *)aConnection didFailWithError:(NSError *)error
{
    if (self.shouldShowNetworkActivityIndicator) {
        [CKHTTPRequest setNetworkActivityIndicatorVisible:NO];
    }

    if (_isCanceled) {
        [aConnection cancel];
        return;
    }

    CKHTTPError *err = [[CKHTTPError alloc] initWithError:error httpResponse:nil httpData:nil request:self];
	dispatch_async(self.callbacksQueue, ^{
		if (self.errorBlock) {
            self.errorBlock(err);
		}
	});
}


- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}


- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        if (self.trustedHosts && [self.trustedHosts containsObject:challenge.protectionSpace.host]) {
            [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]
                 forAuthenticationChallenge:challenge];
        }
    }
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}


#pragma mark - Равенство

- (BOOL)isEqual:(id)object
{
	if (![object isKindOfClass:[CKHTTPRequest class]]) {
		return NO;
	}

	CKHTTPRequest *otherRequest = (CKHTTPRequest *)object;
    if (self.method != otherRequest.method) {
        return NO;
    }
    
    switch (self.method) {
        case POST:
            return [self.url isEqualToString:otherRequest.url] && [self.body isEqualToData:otherRequest.body];
            break;
        default:
            return [self.url isEqualToString:otherRequest.url];
            break;
    }
}

@end
