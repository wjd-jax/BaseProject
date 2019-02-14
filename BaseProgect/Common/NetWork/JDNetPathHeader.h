//
//  JDNetPathHeader.h
//  DKCSProject
//
//  Created by hzad on 2018/12/24.
//  Copyright © 2018 hzad. All rights reserved.
//

#ifndef JDNetPathHeader_h
#define JDNetPathHeader_h

#define url0 @"http://wwww.baidu.com" //调试环境1
#define url1 @"http://wwww.baidu.com" //调试环境2
#define url2 @"http://wwww.baidu.com" //调试环境3


#ifdef DEBUG

#define BaseURLString url2

#else

#define BaseURLString url0
                                                                                                                                                                                                                                                                                                                                                      
#endif

#endif /* JDNetPathHeader_h */
