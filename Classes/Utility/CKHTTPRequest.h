#import <Foundation/Foundation.h>

@class CKHTTPRequest;

#define NOT_AUTHORIZED_RECEIVED @"NOT_AUTHORIZED_RECEIVED"

/**
 Оберточный класс для серверного ответа
 */
@interface CKHTTPResponse : NSObject

/**
 Запрос, который привел к этому самому ответу
 */
@property(strong, nonatomic) CKHTTPRequest *request;

/**
 Данные, полученные с сервера
 */
@property(strong) NSData *data;

/**
 Объект NSHTTPURLResponse
 */
@property(strong) NSHTTPURLResponse *response;

/**
 Инициализирует объект с данными и ответом сервера
 */
- (id)initWithData:(NSData *)d response:(NSHTTPURLResponse *)r request:(CKHTTPRequest *)request;

@end

/**
 Оберточный класс для ошибки
 */
@interface CKHTTPError : NSObject

typedef NS_ENUM(NSInteger, CKHTTPErrorType) {
    CKHttpError,
    PZNetworkUnreachableError,
    PZHostUnreachableError,
    PZConnectionTimeoutError,
    PZRequestInternalError
};

/**
 Запрос, который привел к ошибке
 */
@property(strong, nonatomic) CKHTTPRequest *request;

/**
 Код ошибки. Может содержать в себе HTTP-код ошибки, либо внутренний код ошибки от Apple
 */
@property(assign) NSInteger errorCode;

/**
 В случае ошибки http в этом поле будут лежать данные, которые вернул сервер
 */
@property(nonatomic, strong) NSData *httpResultData;

/**
 Если это возможно, внутри словаря будут лежать детали относительно ошибки
 */
@property(nonatomic, strong) NSDictionary *userInfo;

/**
 Тип ошибки
 */
@property(assign) CKHTTPErrorType errorType;

@end


/**
 Все поддерживаемые http-методы.
 Вынесено в отдельное перечисление, чтобы добавить немного проверки типов. 
 А то грустно очень.
 */
typedef enum {
    GET,
    HEAD,
    POST,
    DELETE,
    PUT
} CKHTTPMethod;

/**
 При успешном запросе в коллбэк вернутся данные
 */
typedef void (^CKHTTPRequestSuccessBlock)(CKHTTPResponse *response);

/**
 При ошибке запроса в коллбэк объект с ошибкой
 */
typedef void (^CKHTTPRequestErrorBlock)(CKHTTPError *error);

/**
 Коллбэк для отслеживания процесса скачивания
 */
typedef void (^CKHTTPRequestDataReceivedBlock)(long sizeDownloaded, long sizeOverall);

/**
 Класс для работы с HTTP-запросами.
 По-умолчанию все запросы выполняются на фоновой асинхронной очереди, для выполнения на последовтельной можно установить свойство 
 performOnSerialQueue в YES. Коллбэки выполняются либо на очереди
 указанной через свойство callbacksQueue, либо, по-умолчанию, на главной очереди.
 
 */
@interface CKHTTPRequest : NSObject

/**
 Оригинальный запрос
 */
@property(nonatomic, strong) NSMutableURLRequest *request;

/**
 Коллбэк, который будет вызван в случае успеха
 */
@property(nonatomic, copy) CKHTTPRequestErrorBlock errorBlock;

/**
 Коллбэк, который будет вызван в случае ошибки
 */
@property(nonatomic, copy) CKHTTPRequestSuccessBlock successBlock;

/**
 Коллбэк, который будет вызван сразу после получения ответа от сервера
 */
@property(nonatomic, copy) CKHTTPRequestSuccessBlock responseReceivedCallback;

/**
 Коллбэк, который будет вызваться при каждом получении чанка данных
 */
@property (nonatomic, copy) CKHTTPRequestDataReceivedBlock dataReceivedCallback;

/**
 Очередь, на которой должен выполниться код коллбэков. Если не указана явно, то код выполнится на главной очереди.
 */
@property(assign) dispatch_queue_t callbacksQueue;

/**
 Тип контента. 
 */
@property(nonatomic, strong) NSString *contentType;

/**
 Дополнительные http-заголовки. Будут установлены по-умолчанию в дополнение к уже имеющимся
 */
@property(nonatomic, strong) NSDictionary *extraHeaders;

/**
 URL для запроса.
 @warning Не должен содержать GET параметров в случае, если используется GET запрос.
 */
@property(nonatomic, strong) NSString *url;

/**
 HTTP метод запроса
 */
@property(nonatomic, assign) CKHTTPMethod method;

/**
 Данные для отправки POST/PUT запросами
 */
@property(nonatomic, strong) NSData *body;

/**
 Определяет, будет ли запрос влиять на индикатор сетевой активности
 */
@property(assign) BOOL shouldShowNetworkActivityIndicator;

/**
 Фиксированное время для исполнения запроса. В случае, если запрос не укладывается будет сгенерирована ошибка.
 */
@property(assign) NSTimeInterval timeoutInterval;

/**
 Исполнять запросы на последовательной очереди
 */
@property(assign) BOOL performOnSerialQueue;

/**
 Тэг для идентификации запроса
 */
@property(assign) NSInteger tag;

/**
 Список хостов, которым можно доверять, даже если у них плохой сертификат
 */
@property (strong, nonatomic) NSArray *trustedHosts;

/**
 Наиболее общий метод для создания запроса.
 @warning Запрос автоматически будет использовать Cookies для домена взятые из NSHTTPCookieStorage.
 
 @param urlString: URL для запроса, в форме строки
 @param method: HTTP-метод
 @param body: тело http-запроса
 @param extraHeaders: дополнительные http-заголовки в виде NSDictionary
 @param contentType: тип контента
 @param onSuccess: коллбэк сработающий в случае успеха
 @param onError: коллбэк сработающий в случае ошибки
 */
+ (CKHTTPRequest *)requestWithUrl:(NSString *)urlString
                           method:(CKHTTPMethod)method
                             body:(NSData *)body
                     extraHeaders:(NSDictionary *)headers
                       contentType:(NSString *)contentType
                        onSuccess:(CKHTTPRequestSuccessBlock)aSuccessBlock
                          onError:(CKHTTPRequestErrorBlock)anErrorBlock;

/**
 Вернет GET запрос с параметрами.
 
 @param url URL для запроса
 @params params NSDictionary с GET параметрами, если параметр nil, то запрос отправиться без параметров
 */
+ (CKHTTPRequest *)requestToGetUrl:(NSString *)url
                            params:(NSDictionary *)params
                         onSuccess:(CKHTTPRequestSuccessBlock)aSuccessBlock
                           onError:(CKHTTPRequestErrorBlock)anErrorBlock;

+ (CKHTTPRequest *)requestToDownloadUrl:(NSString *)url
                                 params:(NSDictionary *)params
                       destionationPath:(NSString *)path
                         onSuccess:(CKHTTPRequestSuccessBlock)aSuccessBlock
                           onError:(CKHTTPRequestErrorBlock)anErrorBlock;

/**
 Вернет запрос для посылки данных методом POST
 */
+ (CKHTTPRequest *)requestToPostData:(NSData *)data
                               toUrl:(NSString *)url
                           onSuccess:(CKHTTPRequestSuccessBlock)aSuccessBlock
                             onError:(CKHTTPRequestErrorBlock)anErrorBlock;

/**
 Вернет POST запрос с параметрами
 */
+ (CKHTTPRequest *)requestToPostParams:(NSDictionary *)params
                                 toUrl:(NSString *)url
                             onSuccess:(CKHTTPRequestSuccessBlock)aSuccessBlock
                               onError:(CKHTTPRequestErrorBlock)anErrorBlock;

/**
 Вернет multipart/form-data POST запрос
 */
+ (CKHTTPRequest *)requestToPostMultipartData:(NSData *)data
                                     filename:(NSString *)filename
                                       params:(NSDictionary *)params
                                        toUrl:(NSString *)url
                                    onSuccess:(CKHTTPRequestSuccessBlock)aSuccessBlock
                                      onError:(CKHTTPRequestErrorBlock)anErrorBlock;
/**
 Вернет DELETE запрос
 */
+ (CKHTTPRequest *)requestToDeleteUrl:(NSString *)url
                            onSuccess:(CKHTTPRequestSuccessBlock)aSuccessBlock
                              onError:(CKHTTPRequestErrorBlock)anErrorBlock;

/**
 Запустить запрос.
 */
- (void)start;

/**
 Отменить запрос.
 После вызова этого метода объект никогда не выполнит код коллбэков
 */
- (void)cancel;


/**
 Сменить статус отображения активности сети
 */
+ (void)setNetworkActivityIndicatorVisible:(BOOL)setVisible;

@end
