//
//  WJDBaseViewController.m
//  BaseProgect
//
//  Created by hzad on 2019/2/11.
//  Copyright © 2019 WJD. All rights reserved.
//  这是所有页面继承的基类

#import "WJDBaseViewController.h"
#import "WJDConstStrHeader.h"

@interface WJDBaseViewController ()

@end

@implementation WJDBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (void)loadData{
    
    DLog(@"%@子类没有重写加载数据方法",[self className]);
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
