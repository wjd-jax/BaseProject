//
//  WJDShortcutHeader.h
//  BaseProgect
//
//  Created by hzad on 2019/2/11.
//  Copyright © 2019 WJD. All rights reserved.
//  快捷宏

#ifndef WJDShortcutHeader_h
#define WJDShortcutHeader_h

//获取沙盒 Document
#define kPathDocument \
[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];

//获取沙盒 Cache
#define kPathCache \
[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];

//读取图片
#define JDIMAGE_NAMED(name) [UIImage imageNamed:name]

#define AJDMainBundleInfo [[NSBundle mainBundle] infoDictionary]                            //
#define AJDCurrentAJDName [AJDMainBundleInfo objectForKey:@"CFBundleDisplayName"]           //获取当前 AJD 的名字
#define AJDCurrentAJDBundleID [[NSBundle mainBundle] bundleIdentifier]                      //获取当前 app 的 bundleID
#define AJDCurrentAJDVersion [AJDMainBundleInfo objectForKey:@"CFBundleShortVersionString"] //获取当前 app 的 版本号
#define AJDCurrentAJDBuild [AJDMainBundleInfo objectForKey:@"CFBundleVersion"]              //获取当前 app 的 build 号
#define AJDUserDefaults [NSUserDefaults standardUserDefaults]                               //获取UserDefaults
#define AJDNotificationCenter [NSNotificationCenter defaultCenter]                          //defaultCenter
#define AJDChannel @"appstore"                                                              //获取渠道 上架还是企业包

#pragma mark-----------沙盒目录文件-----------

#define kPathTem NSTemporaryDirectory() //获取Temp 目录

//获取沙盒 Document
#define kPathDocument \
[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];

//获取沙盒 Cache
#define kPathCache \
[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];

#pragma mark-----------快捷操作-----------

//获取通知中心
#define JDNotificationCenter [NSNotificationCenter defaultCenter]

#pragma mark-----------View操作-----------

//弱引用/强引用
#define JDWeakSelf(type) __weak typeof(type) weak##type = type;
#define JDStrongSelf(type) __strong typeof(type) type = weak##type;

//设置 View 边框粗细和颜色
#define JDViewBorderRadius(View, Width, color) \
\
[View.layer setBorderWidth:(Width)];       \
[View.layer setBorderColor:color]

//设置圆角
#define JDViewSetRadius(View, Radius)      \
\
[View.layer setCornerRadius:(Radius)]; \
[View.layer setMasksToBounds:YES];

//定义UIImage对象

#define JDImageWithFile(_pointer)                                                                                                     \
[UIImage imageWithContentsOfFile:([[NSBundle mainBundle]                                                                          \
pathForResource:[NSString stringWithFormat:@"%@@%dx",                                        \
_pointer, (int)[UIScreen mainScreen].nativeScale] \
ofType:@"png"])]

#define JDIMAGE_NAMED(name) [UIImage imageNamed:name]

#pragma mark-----------设置相关-----------

//获取当前语言
#define JDCurrentLanguage ([[NSLocale preferredLanguages] objectAtIndex:0])

#pragma mark-----------GCD-----------

//GCD - 一次性执行

#define JDDISPATCH_ONCE_BLOCK(onceBlock) \
static dispatch_once_t onceToken;    \
dispatch_once(&onceToken, onceBlock);

//GCD - 在Main线程上运行
#define JDDISPATCH_MAIN_THREAD(mainQueueBlock) dispatch_async(dispatch_get_main_queue(), mainQueueBlock);

//GCD - 开启异步线程
#define JDDISPATCH_GLOBAL_QUEUE_DEFAULT(globalQueueBlock) dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), globalQueueBlock);

//单例
#define JDSHAREINSTANCE_FOR_CLASS(__CLASSNAME__) \
\
static __CLASSNAME__ *instance = nil;        \
\
+(__CLASSNAME__ *)sharedInstance {           \
static dispatch_once_t onceToken;        \
dispatch_once(&onceToken, ^{             \
if (nil == instance) {                 \
instance = [[self alloc] init];    \
}                                      \
});                                      \
\
return instance;                         \
}

#endif

#pragma mark-----------打印日志-----------

//DEBUG 模式下打印日志,当前行
#ifdef DEBUG

#define DLog(format, ...) printf("%s [Line %d]  \n%s\n", __PRETTY_FUNCTION__, __LINE__, [[NSString stringWithFormat:(format), ##__VA_ARGS__] UTF8String])

#else

#define DLog(...)

#endif /* WJDShortcutHeader_h */
