//
//  DKCSWebViewController.h
//  DKCSProject
//
//  Created by hzad on 2018/12/24.
//  Copyright © 2018 hzad. All rights reserved.
//

#import "WJDBaseViewController.h"
#import <WebKit/WebKit.h>

typedef void (^adDismissFinishedBlock)(void);

NS_ASSUME_NONNULL_BEGIN

@interface JDWebViewController : WJDBaseViewController

@property (nonatomic, copy) NSString *urlString; //加载的 URL
@property (nonatomic, copy) NSString *navTitle;  //硬性标题,设置后不通过网页修改

/**
 打开某个网址
 
 @param urlString URL
 @param viewController 跳转调用页面
 */

+ (JDWebViewController *)loadURL:(NSString *)urlString
                             title:(NSString *)navTitle
                fromViewController:(UIViewController *)viewController;

/**
 打开某个网址
 
 @param urlString URL
 @param viewController 跳转调用UINavigationController
 */

+ (JDWebViewController *)loadURL:(NSString *)urlString
                             title:(NSString *)navTitle
          fromNavigationController:(UINavigationController *)viewController;

/**
 刷新数据
 */
- (void)reloadURLData;
- (void)addHeadWithRequest:(NSMutableURLRequest *)request;
@end

NS_ASSUME_NONNULL_END
