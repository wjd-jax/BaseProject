//
//  PPNetPathHeader.h
//  DKCSProject
//
//  Created by hzad on 2018/12/24.
//  Copyright © 2018 hzad. All rights reserved.
//

#ifndef PPNetPathHeader_h
#define PPNetPathHeader_h

#define url0 @"http://118.31.14.130:1828" //调试环境
#define url1 @"http://172.16.0.176:8080"  //调试环境 林海文
#define url2 @"http://172.16.0.74:8080"   //调试环境 张瑞
#define url3 @"http://47.110.187.78:1828" //调试环境 快速

#ifdef DEBUG

#define BaseURLString url3

#else

#define BaseURLString url0
                                                                                                                                                                                                                                                                                                                                                      
#endif

#endif /* PPNetPathHeader_h */
