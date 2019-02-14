//
//  DKCSKDID.h
//  DKCSProject
//
//  Created by hzad on 2019/1/7.
//  Copyright © 2019 hzad. All rights reserved.
//  获取设备唯一识别码(只有用户在重置系统的时候才会重置)

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WJDKDID : NSObject

+ (NSString *)getKDID;

@end

NS_ASSUME_NONNULL_END
