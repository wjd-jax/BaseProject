//
//  WJDBaseViewController.h
//  BaseProgect
//
//  Created by hzad on 2019/2/11.
//  Copyright © 2019 WJD. All rights reserved.
//  页面基类

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WJDBaseViewController : UIViewController

//加载数据,子类数据都从这里加载,便于登录退出的时候进行数据更新
- (void)loadData;

@end

NS_ASSUME_NONNULL_END
