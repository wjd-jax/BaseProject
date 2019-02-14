//
//  DKCSWebDelegeteController.h
//  DKCSProject
//
//  Created by hzad on 2018/12/24.
//  Copyright © 2018 hzad. All rights reserved.
//

#import "WJDBaseViewController.h"
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol WKDelegate < NSObject >

@optional

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message;

@end

@interface JDWebDelegeteController : WJDBaseViewController

@property (weak, nonatomic) id< WKDelegate > delegate;

@end

NS_ASSUME_NONNULL_END
