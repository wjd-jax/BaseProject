//
//  AppDelegate+Push.h
//  BaseProgect
//
//  Created by hzad on 2019/2/11.
//  Copyright © 2019 WJD. All rights reserved.
//  推送


#import "AppDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface AppDelegate (Push)

- (void)resignPushWithApplicaiton:(UIApplication *)application options:(NSDictionary *)launchOptions;

@end

NS_ASSUME_NONNULL_END
