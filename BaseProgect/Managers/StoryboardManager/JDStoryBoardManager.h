//
//  DKCSStoryBoardManager.h
//  DKCSProject
//
//  Created by hzad on 2018/12/27.
//  Copyright © 2018 hzad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WJDBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface JDStoryBoardManager : NSObject



/**
 根据id返回

 @param viewcontrollerID sb的id
 @return 根据
 */
+ (WJDBaseViewController *)getViewControllerWithStoryID:(NSString *)viewcontrollerID;
+ (WJDBaseViewController *)getViewControllerWithStoryID:(NSString *)storyBoardName
                             andViewControllerName:(NSString *)viewcontrollerID;

//使用sb分屏之后的获取方法
+ (WJDBaseViewController *)getViewControllerWithfromHomeStoryboadWithViewControllerName:(NSString *)viewcontrollerID;
+ (WJDBaseViewController *)getViewControllerWithfromFindStoryboadWithViewControllerName:(NSString *)viewcontrollerID;
+ (WJDBaseViewController *)getViewControllerWithfromMineStoryboadWithViewControllerName:(NSString *)viewcontrollerID;
+ (WJDBaseViewController *)getViewControllerWithfromLoginStoryboadWithViewControllerName:(NSString *)viewcontrollerID;

//经常获取的某个页面
+ (WJDBaseViewController *)getLoginViewController;

@end

NS_ASSUME_NONNULL_END
