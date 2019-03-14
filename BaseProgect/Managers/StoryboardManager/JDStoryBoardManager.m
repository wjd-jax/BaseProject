//
//  DKCSStoryBoardManager.m
//  DKCSProject
//
//  Created by hzad on 2018/12/27.
//  Copyright © 2018 hzad. All rights reserved.
//

#import "JDStoryBoardManager.h"

@implementation JDStoryBoardManager

+ (WJDBaseViewController *)getViewControllerWithStoryID:(NSString *)viewcontrollerID{

    return [self getViewControllerWithStoryID:@"XXXXX" andViewControllerName:@"XXXXX"];
}

+ (UIViewController *)getViewControllerWithStoryID:(NSString *)storyBoardName
                             andViewControllerName:(NSString *)viewcontrollerID {

    UIStoryboard *sb = [UIStoryboard storyboardWithName:storyBoardName bundle:[NSBundle mainBundle]];
    //由storyboard根据myView的storyBoardID来获取我们要切换的视图
    UIViewController *vc = [sb instantiateViewControllerWithIdentifier:viewcontrollerID];
    return vc;
}

+ (UIViewController *)getViewControllerWithfromHomeStoryboadWithViewControllerName:(NSString *)viewcontrollerID {
    return [self getViewControllerWithStoryID:@"XXXXX" andViewControllerName:viewcontrollerID];
}
+ (UIViewController *)getViewControllerWithfromFindStoryboadWithViewControllerName:(NSString *)viewcontrollerID {
    return [self getViewControllerWithStoryID:@"XXXXX" andViewControllerName:viewcontrollerID];
}
+ (UIViewController *)getViewControllerWithfromMineStoryboadWithViewControllerName:(NSString *)viewcontrollerID {
    return [self getViewControllerWithStoryID:@"XXXXX" andViewControllerName:viewcontrollerID];
}
+ (UIViewController *)getViewControllerWithfromLoginStoryboadWithViewControllerName:(NSString *)viewcontrollerID {
    return [self getViewControllerWithStoryID:@"XXXXX" andViewControllerName:viewcontrollerID];
}

+ (UIViewController *)getLoginViewController {
    return [self getViewControllerWithStoryID:@"XXXXX" andViewControllerName:@"XXXXX"];
}
@end
