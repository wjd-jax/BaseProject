//
//  DKCSWebDelegeteController.m
//  DKCSProject
//
//  Created by hzad on 2018/12/24.
//  Copyright © 2018 hzad. All rights reserved.
//

#import "JDWebDelegeteController.h"

@implementation JDWebDelegeteController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([self.delegate respondsToSelector:@selector(userContentController:didReceiveScriptMessage:)]) {
        [self.delegate userContentController:userContentController didReceiveScriptMessage:message];
    }
}

@end
