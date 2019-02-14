//
//  JDNetworkHelper.m
//  JDNetworkHelper
//
//  Created by  WJD on 16/8/12.
//  Copyright © 2016年  WJD. All rights reserved.
//

#import "JDNetworkHelper.h"
#import "AFNetworking.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "JDDeviceUtils.h"
#import "WJDKDID.h"
#import <SVProgressHUD.h>

#ifdef DEBUG
#define JDLog(...) printf("[%s] %s [第%d行]: %s\n", __TIME__, __PRETTY_FUNCTION__, __LINE__, [[NSString stringWithFormat:__VA_ARGS__] UTF8String])
#else
#define JDLog(...)
#endif

#define NSStringFormat(format, ...) [NSString stringWithFormat:format, ##__VA_ARGS__]

@implementation JDNetworkHelper

static BOOL _isOpenLog = NO; // 是否已开启日志打印
static NSMutableArray *_allSessionTask;
static AFHTTPSessionManager *_sessionManager;

#pragma mark - 开始监听网络
+ (void)networkStatusWithBlock:(jdNetworkStatus)networkStatus {

    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
      switch (status) {
          case AFNetworkReachabilityStatusUnknown:
              networkStatus ? networkStatus(JDNetworkStatusUnknown) : nil;
              if (_isOpenLog)
                  JDLog(@"未知网络");
              break;
          case AFNetworkReachabilityStatusNotReachable:
              networkStatus ? networkStatus(JDNetworkStatusNotReachable) : nil;
              if (_isOpenLog)
                  JDLog(@"无网络");
              break;
          case AFNetworkReachabilityStatusReachableViaWWAN:
              networkStatus ? networkStatus(JDNetworkStatusReachableViaWWAN) : nil;
              if (_isOpenLog)
                  JDLog(@"手机自带网络");
              break;
          case AFNetworkReachabilityStatusReachableViaWiFi:
              networkStatus ? networkStatus(JDNetworkStatusReachableViaWiFi) : nil;
              if (_isOpenLog)
                  JDLog(@"WIFI");
              break;
      }
    }];
}

+ (BOOL)isNetwork {

    return [AFNetworkReachabilityManager sharedManager].reachable;
}

+ (BOOL)isWWANNetwork {
    return [AFNetworkReachabilityManager sharedManager].reachableViaWWAN;
}

+ (BOOL)isWiFiNetwork {
    return [AFNetworkReachabilityManager sharedManager].reachableViaWiFi;
}

+ (void)openLog {
    _isOpenLog = YES;
}

+ (void)closeLog {
    _isOpenLog = NO;
}

+ (void)showHub {
    [SVProgressHUD show];
    //    [SVProgressHUD setBackgroundColor:JDBlackColor];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
}

+ (void)showHubWithUninteractions {
    [SVProgressHUD show];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
}

+ (void)hideHub {
    [SVProgressHUD dismiss];
}

+ (void)showAnimatedHub {
//    [SVProgressHUD setBackgroundColor:JDClearColor];
//    [SVProgressHUD showInfoWithStatus:@""];
    [SVProgressHUD show];
    //    [SVProgressHUD setBackgroundColor:JDBlackColor];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
}

+ (void)cancelAllRequest {
    // 锁操作
    @synchronized(self) {
        [[self allSessionTask] enumerateObjectsUsingBlock:^(NSURLSessionTask *_Nonnull task, NSUInteger idx, BOOL *_Nonnull stop) {
          [task cancel];
        }];
        [[self allSessionTask] removeAllObjects];
    }
}

+ (void)cancelRequestWithURL:(NSString *)URL {
    if (!URL) {
        return;
    }
    @synchronized(self) {
        [[self allSessionTask] enumerateObjectsUsingBlock:^(NSURLSessionTask *_Nonnull task, NSUInteger idx, BOOL *_Nonnull stop) {
          if ([task.currentRequest.URL.absoluteString hasPrefix:URL]) {
              [task cancel];
              [[self allSessionTask] removeObject:task];
              *stop = YES;
          }
        }];
    }
}

//不以键值对的方式上传
+ (NSURLSessionTask *)uploadData:(NSDictionary *)dict
                             URL:(NSString *)urlStr
                         success:(JDHttpRequestSuccess)success
                         failure:(JDHttpRequestFailed)failure {

    //转json数据
    NSString *string = dict.jsonStringEncoded;
    NSData *myJSONData = [string dataUsingEncoding:NSUTF8StringEncoding];

    NSString *postUrl = [NSString stringWithFormat:@"%@%@", BaseURLString, urlStr];

    //3.创建可变的请求对象
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:postUrl]];
    //4.修改请求方法为POST
    request.HTTPMethod = @"POST";
    //5.设置请求体
    request.HTTPBody = myJSONData;

    //头部
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
   
    [request setValue:AJDChannel forHTTPHeaderField:@"channel"];
    [request setValue:[WJDKDID getKDID] forHTTPHeaderField:@"udid"];
    [request setValue:@"iOS" forHTTPHeaderField:@"os"];                                            //手机型号(原始)
    [request setValue:[[UIDevice currentDevice] systemVersion] forHTTPHeaderField:@"os-ver"];      //收集系统版本
    [request setValue:[JDDeviceUtils device] forHTTPHeaderField:@"brand"];                         //品牌
    [request setValue:[UIApplication sharedApplication].appVersion forHTTPHeaderField:@"app-ver"]; //app版本

    NSURLSessionDataTask *dataTask = [_sessionManager dataTaskWithRequest:request
                                                           uploadProgress:nil
                                                         downloadProgress:nil
                                                        completionHandler:^(NSURLResponse *_Nonnull response, id _Nullable responseObject, NSError *_Nullable error) {

                                                          if (error) {
                                                              [self handelFailuerWith:nil error:error failure:failure];
                                                          } else {
                                                              [self handelSuccessDataWithRequestData:responseObject task:nil success:success];
                                                          }
                                                        }];

    //7.执行任务
    [dataTask resume];

    return dataTask;
}

#pragma mark - GET请求无缓存
+ (NSURLSessionTask *)GET:(NSString *)URL
               parameters:(id)parameters
                  success:(JDHttpRequestSuccess)success
                  failure:(JDHttpRequestFailed)failure {
    return [self GET:URL parameters:parameters responseCache:nil success:success failure:failure];
}

#pragma mark - POST请求无缓存
+ (NSURLSessionTask *)POST:(NSString *)URL
                parameters:(id)parameters
                   success:(JDHttpRequestSuccess)success
                   failure:(JDHttpRequestFailed)failure {
    return [self POST:URL parameters:parameters responseCache:nil success:success failure:failure];
}

#pragma mark - GET请求自动缓存
+ (NSURLSessionTask *)GET:(NSString *)URL
               parameters:(id)parameters
            responseCache:(JDHttpRequestCache)responseCache
                  success:(JDHttpRequestSuccess)success
                  failure:(JDHttpRequestFailed)failure {
    //读取缓存
    responseCache != nil ? responseCache([JDNetworkCache httpCacheForURL:URL parameters:parameters]) : nil;

    [self addHeader];

    NSURLSessionTask *sessionTask = [_sessionManager GET:URL
        parameters:parameters
        progress:^(NSProgress *_Nonnull uploadProgress) {

        }
        success:^(NSURLSessionDataTask *_Nonnull task, id _Nullable responseObject) {

          [self handelSuccessDataWithRequestData:responseObject task:task success:success];
          //对数据进行异步缓存
          responseCache != nil ? [JDNetworkCache setHttpCache:responseObject URL:URL parameters:parameters] : nil;

        }
        failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {

          [self handelFailuerWith:task error:error failure:failure];

        }];
    // 添加sessionTask到数组
    sessionTask ? [[self allSessionTask] addObject:sessionTask] : nil;

    return sessionTask;
}

#pragma mark - POST请求自动缓存
+ (NSURLSessionTask *)POST:(NSString *)URL
                parameters:(id)parameters
             responseCache:(JDHttpRequestCache)responseCache
                   success:(JDHttpRequestSuccess)success
                   failure:(JDHttpRequestFailed)failure {
    //读取缓存
    responseCache != nil ? responseCache([JDNetworkCache httpCacheForURL:URL parameters:parameters]) : nil;

    [self addHeader];
    NSURLSessionTask *sessionTask = [_sessionManager POST:URL
        parameters:parameters
        progress:^(NSProgress *_Nonnull uploadProgress) {

        }
        success:^(NSURLSessionDataTask *_Nonnull task, id _Nullable responseObject) {

          [self handelSuccessDataWithRequestData:responseObject task:task success:success];
          //对数据进行异步缓存
          responseCache != nil ? [JDNetworkCache setHttpCache:responseObject URL:URL parameters:parameters] : nil;

        }
        failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {

          [self handelFailuerWith:task error:error failure:failure];

        }];

    // 添加最新的sessionTask到数组
    sessionTask ? [[self allSessionTask] addObject:sessionTask] : nil;
    return sessionTask;
}

+ (void)showError:(NSError *)error {

    NSData *data = error.userInfo[@"com.alamofire.serialization.response.error.data"];
    DLog(@"*----------错误信息---------*\n\n%@\n\n*---------*---------*\n", [data jsonValueDecoded]);
}

#pragma mark - 上传文件
+ (NSURLSessionTask *)uploadFileWithURL:(NSString *)URL
                             parameters:(id)parameters
                                   name:(NSString *)name
                               filePath:(NSString *)filePath
                               progress:(JDHttpProgress)progress
                                success:(JDHttpRequestSuccess)success
                                failure:(JDHttpRequestFailed)failure {

    NSURLSessionTask *sessionTask = [_sessionManager POST:URL
        parameters:parameters
        constructingBodyWithBlock:^(id< AFMultipartFormData > _Nonnull formData) {
          NSError *error = nil;
          [formData appendPartWithFileURL:[NSURL URLWithString:filePath] name:name error:&error];
          (failure && error) ? failure(error) : nil;
        }
        progress:^(NSProgress *_Nonnull uploadProgress) {
          //上传进度
          dispatch_sync(dispatch_get_main_queue(), ^{
            progress ? progress(uploadProgress) : nil;
          });
        }
        success:^(NSURLSessionDataTask *_Nonnull task, id _Nullable responseObject) {

          [self handelSuccessDataWithRequestData:responseObject task:task success:success];

        }
        failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {

          [self handelFailuerWith:task error:error failure:failure];

        }];

    // 添加sessionTask到数组
    sessionTask ? [[self allSessionTask] addObject:sessionTask] : nil;

    return sessionTask;
}

+ (__kindof NSURLSessionTask *)uploadImagesToOSSWithURL:(NSString *)URL
                                                  image:(UIImage *)image
                                               progress:(JDHttpProgress)progress
                                                success:(JDHttpRequestSuccess)success
                                                failure:(JDHttpRequestFailed)failure {

    NSData *imageData = UIImageJPEGRepresentation(image, 1);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:URL]];
    request.HTTPMethod = @"PUT";
    [request setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];

    NSURLSessionTask *uploadTask = [_sessionManager uploadTaskWithRequest:request
        fromData:imageData
        progress:^(NSProgress *_Nonnull uploadProgress) {
          //上传进度
          dispatch_sync(dispatch_get_main_queue(), ^{
            progress ? progress(uploadProgress) : nil;
          });
        }
        completionHandler:^(NSURLResponse *_Nonnull response, id _Nullable responseObject, NSError *_Nullable error) {

          if (!error) {
              success(nil, nil);
          } else {
              [self handelFailuerWith:nil error:error failure:failure];
          }

        }];
    [uploadTask resume];

    return uploadTask;
}

#pragma mark - 上传多张图片
+ (NSURLSessionTask *)uploadImagesWithURL:(NSString *)URL
                               parameters:(id)parameters
                                     name:(NSString *)name
                                   images:(NSArray< UIImage * > *)images
                                fileNames:(NSArray< NSString * > *)fileNames
                               imageScale:(CGFloat)imageScale
                                imageType:(NSString *)imageType
                                 progress:(JDHttpProgress)progress
                                  success:(JDHttpRequestSuccess)success
                                  failure:(JDHttpRequestFailed)failure {

    NSURLSessionTask *sessionTask = [_sessionManager POST:URL
        parameters:parameters
        constructingBodyWithBlock:^(id< AFMultipartFormData > _Nonnull formData) {

          for (NSUInteger i = 0; i < images.count; i++) {
              // 图片经过等比压缩后得到的二进制文件
              NSData *imageData = UIImageJPEGRepresentation(images[i], imageScale ?: 1.f);
              // 默认图片的文件名, 若fileNames为nil就使用

              NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
              formatter.dateFormat = @"yyyyMMddHHmmss";
              NSString *str = [formatter stringFromDate:[NSDate date]];
              NSString *imageFileName = NSStringFormat(@"%@%@.%@", str, @(i), imageType ?: @"jpg");

              [formData appendPartWithFileData:imageData
                                          name:name
                                      fileName:fileNames ? NSStringFormat(@"%@.%@", fileNames[i], imageType ?: @"jpg") : imageFileName
                                      mimeType:NSStringFormat(@"image/%@", imageType ?: @"jpg")];
          }

        }
        progress:^(NSProgress *_Nonnull uploadProgress) {
          //上传进度
          dispatch_sync(dispatch_get_main_queue(), ^{
            progress ? progress(uploadProgress) : nil;
          });
        }
        success:^(NSURLSessionDataTask *_Nonnull task, id _Nullable responseObject) {

          [self handelSuccessDataWithRequestData:responseObject task:task success:success];

        }
        failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {

          [self handelFailuerWith:task error:error failure:failure];

        }];

    // 添加sessionTask到数组
    sessionTask ? [[self allSessionTask] addObject:sessionTask] : nil;

    return sessionTask;
}

#pragma mark 返回值成功回调处理
+ (void)handelSuccessDataWithRequestData:(id)responseObject task:(NSURLSessionDataTask *)task success:(JDHttpRequestSuccess)success {

    success ? [JDNetworkHelper hideHub] : nil;
    if (_isOpenLog)
        JDLog(@"responseObject = %@", responseObject);

    [[self allSessionTask] removeObject:task];

    //先判断是不是字典类型如果是,则添加通用处理方法,处理字典最外层数据基本的成功失败
    if ([responseObject isKindOfClass:[NSDictionary class]]) {


        switch (JDRequest_Code) {

            case RequstCode_Success:

                break;

            case RequstCode_NeedRelogin:

//                USERMODEL.islogin = NO;
//                [JDNotificationCenter postNotificationName:Notifition_TokenDisable object:nil];
                break;

            case RequstCode_OtherPlaceLogin:

//                USERMODEL.islogin = NO;
//                [JDNotificationCenter postNotificationName:Notifition_Otherlogin object:nil];
                break;

            case RequstCode_SystemErr:

                [JDHubMessageView showMessage:JDRequest_Msg];
                break;

            default:
                break;
        }
    }

    success ? success(responseObject, JDRequest_Data) : nil;
}

#pragma mark - 返回错误处理
+ (void)handelFailuerWith:(NSURLSessionDataTask *)task error:(NSError *)error failure:(JDHttpRequestFailed)failure {

    if (failure) {
        [JDNetworkHelper hideHub];
        [JDHubMessageView showMessage:@"网络错误"];
    }

    if (_isOpenLog)
        [self showError:error];

    [[self allSessionTask] removeObject:task];

    failure ? failure(error) : nil;
}

#pragma mark - 下载文件
+ (NSURLSessionTask *)downloadWithURL:(NSString *)URL
                              fileDir:(NSString *)fileDir
                             progress:(JDHttpProgress)progress
                              success:(void (^)(NSString *))success
                              failure:(JDHttpRequestFailed)failure {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:URL]];
    __block NSURLSessionDownloadTask *downloadTask = [_sessionManager downloadTaskWithRequest:request
        progress:^(NSProgress *_Nonnull downloadProgress) {
          //下载进度
          dispatch_sync(dispatch_get_main_queue(), ^{
            progress ? progress(downloadProgress) : nil;
          });
        }
        destination:^NSURL *_Nonnull(NSURL *_Nonnull targetPath, NSURLResponse *_Nonnull response) {
          //拼接缓存目录
          NSString *downloadDir = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:fileDir ? fileDir : @"Download"];
          //打开文件管理器
          NSFileManager *fileManager = [NSFileManager defaultManager];
          //创建Download目录
          [fileManager createDirectoryAtPath:downloadDir withIntermediateDirectories:YES attributes:nil error:nil];
          //拼接文件路径
          NSString *filePath = [downloadDir stringByAppendingPathComponent:response.suggestedFilename];
          //返回文件位置的URL路径
          return [NSURL fileURLWithPath:filePath];

        }
        completionHandler:^(NSURLResponse *_Nonnull response, NSURL *_Nullable filePath, NSError *_Nullable error) {

          [[self allSessionTask] removeObject:downloadTask];
          if (failure && error) {
              failure(error);
              return;
          };
          success ? success(filePath.absoluteString /** NSURL->NSString*/) : nil;

        }];
    //开始下载
    [downloadTask resume];
    // 添加sessionTask到数组
    downloadTask ? [[self allSessionTask] addObject:downloadTask] : nil;

    return downloadTask;
}

/**
 存储着所有的请求task数组
 */
+ (NSMutableArray *)allSessionTask {
    if (!_allSessionTask) {
        _allSessionTask = [[NSMutableArray alloc] init];
    }
    return _allSessionTask;
}

#pragma mark - 头部处理
/**
 此方法处理上传的通用参数
 
 @param parameters 接口请求的参数
 */
+ (void)addHeader {

    [_sessionManager.requestSerializer setValue:AJDChannel forHTTPHeaderField:@"channel"];
    [_sessionManager.requestSerializer setValue:[WJDKDID getKDID] forHTTPHeaderField:@"udid"];
    [_sessionManager.requestSerializer setValue:@"iOS" forHTTPHeaderField:@"os"];                                            //手机型号(原始)
    [_sessionManager.requestSerializer setValue:[[UIDevice currentDevice] systemVersion] forHTTPHeaderField:@"os-ver"];      //收集系统版本
    [_sessionManager.requestSerializer setValue:[JDDeviceUtils device] forHTTPHeaderField:@"brand"];                         //品牌
}

#pragma mark - 初始化AFHTTPSessionManager相关属性
/**
 开始监测网络状态
 */
+ (void)load {
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}
/**
 *  所有的HTTP请求共享一个AFHTTPSessionManager
 *  原理参考地址:http://www.jianshu.com/p/5969bbb4af9f
 */
+ (void)initialize {
    _sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:BaseURLString]];
    ;
    _sessionManager.requestSerializer.timeoutInterval = 8.f;
    _sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html", @"text/json", @"text/plain", @"text/javascript", @"text/xml", @"image/*", nil];
    //
    ((AFJSONResponseSerializer *)_sessionManager.responseSerializer).removesKeysWithNullValues = YES;

    // 打开状态栏的等待菊花
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
}

#pragma mark - 重置AFHTTPSessionManager相关属性

+ (void)setAFHTTPSessionManagerProperty:(void (^)(AFHTTPSessionManager *))sessionManager {
    sessionManager ? sessionManager(_sessionManager) : nil;
}

+ (void)setRequestSerializer:(JDRequestSerializer)requestSerializer {
    _sessionManager.requestSerializer = requestSerializer == JDRequestSerializerHTTP ? [AFHTTPRequestSerializer serializer] : [AFJSONRequestSerializer serializer];
}

+ (void)setResponseSerializer:(JDResponseSerializer)responseSerializer {
    _sessionManager.responseSerializer = responseSerializer == JDResponseSerializerHTTP ? [AFHTTPResponseSerializer serializer] : [AFJSONResponseSerializer serializer];
}

+ (void)setRequestTimeoutInterval:(NSTimeInterval)time {
    _sessionManager.requestSerializer.timeoutInterval = time;
}

+ (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field {
    [_sessionManager.requestSerializer setValue:value forHTTPHeaderField:field];
}

+ (void)openNetworkActivityIndicator:(BOOL)open{
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:open];
    
}

+(void)setSecurityPolicyWithCerPath : (NSString *)cerPath validatesDomainName : (BOOL)validatesDomainName {
    NSData *cerData = [NSData dataWithContentsOfFile:cerPath];
    // 使用证书验证模式
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    // 如果需要验证自建证书(无效证书)，需要设置为YES
    securityPolicy.allowInvalidCertificates = YES;
    // 是否需要验证域名，默认为YES;
    securityPolicy.validatesDomainName = validatesDomainName;
    securityPolicy.pinnedCertificates = [[NSSet alloc] initWithObjects:cerData, nil];
    
    [_sessionManager setSecurityPolicy:securityPolicy];
}
@end
