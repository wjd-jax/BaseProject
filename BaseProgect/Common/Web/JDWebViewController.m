//
//  DKCSWebViewController.m
//  DKCSProject
//
//  Created by hzad on 2018/12/24.
//  Copyright © 2018 hzad. All rights reserved.
//

#import "JDWebViewController.h"
#import <WebKit/WebKit.h>
#import "JDWebDelegeteController.h"
#import "WJDKDID.h"
#import "JDDeviceUtils.h"
#import <Masonry.h>
#import "JDUIFactory.h"

@interface JDWebViewController () < WKNavigationDelegate, WKUIDelegate, UIScrollViewDelegate, WKScriptMessageHandler, WKDelegate >

@property (nonatomic, strong) UIProgressView *progressView; //进度条
@property (nonatomic, strong) WKWebView *wkWebView;         //webview
@property (nonatomic, strong) UIButton *exitButton;         //退出按钮

@end

@implementation JDWebViewController

- (void)viewDidLoad {

    [super viewDidLoad];
    [self createWebView];
}

+ (JDWebViewController *)loadURL:(NSString *)urlString
                           title:(NSString *)navTitle
        fromNavigationController:(UINavigationController *)viewController;
{

    JDWebViewController *vc = [[self alloc] init];
    vc.urlString = urlString;
    vc.navTitle = navTitle;
    [viewController pushViewController:vc animated:YES];
    return vc;
}

+ (JDWebViewController *)loadURL:(NSString *)urlString
                           title:(NSString *)navTitle
              fromViewController:(UIViewController *)viewController {

    JDWebViewController *vc = [[self alloc] init];

    vc.urlString = urlString;
    vc.navTitle = navTitle;

    if (viewController.navigationController) {
        [viewController.navigationController pushViewController:vc animated:YES];
    } else {
        [viewController presentViewController:viewController animated:YES completion:nil];
    }
    return vc;
}

- (void)reloadURLData {

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_urlString]];
    [request setTimeoutInterval:10];
    [self.wkWebView loadRequest:request];
}

#pragma mark - UI
- (void)createWebView {

    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.selectionGranularity = WKSelectionGranularityCharacter;

    self.wkWebView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
    [self.view addSubview:self.wkWebView];
    [self.wkWebView mas_makeConstraints:^(MASConstraintMaker *make) {
      make.bottom.left.right.mas_equalTo(self.view);
      make.top.equalTo(JD_NavTopHeight);
    }];

    self.wkWebView.navigationDelegate = self;
    self.wkWebView.scrollView.delegate = self;

    //允许左右划手势导航，默认NO
    self.wkWebView.allowsBackForwardNavigationGestures = YES;
    //监听进度
    [self.wkWebView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [self.wkWebView addObserver:self
                     forKeyPath:@"title"
                        options:NSKeyValueObservingOptionNew
                        context:NULL];

    [self.view addSubview:[self progressView]];

    NSURL *url = [NSURL URLWithString:_urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];

    [request setTimeoutInterval:10];
    [self.wkWebView loadRequest:request];
}

- (void)addHeadWithRequest:(NSMutableURLRequest *)request {

    [request addValue:[[UIDevice currentDevice] systemVersion] forHTTPHeaderField:@"os-ver"];      //收集系统版本
    [request addValue:[JDDeviceUtils device] forHTTPHeaderField:@"brand"];                         //品牌
    [request addValue:[UIApplication sharedApplication].appVersion forHTTPHeaderField:@"app-ver"]; //app版本
}

#pragma mark - Setting
//- (void)setUrlString:(NSString *)urlString {
//
//    //中文字符处理
//    NSCharacterSet *encode_set = [NSCharacterSet URLQueryAllowedCharacterSet];
//    NSString *urlString_encode = [urlString stringByAddingPercentEncodingWithAllowedCharacters:encode_set];
//    _urlString = urlString_encode;
//}

- (void)setNavTitle:(NSString *)navTitle {
    _navTitle = navTitle;
}

- (void)setTitle:(NSString *)title {
    [super setTitle:title];
    self.title = title;
}

#pragma mark - 配置WKWebViewConfiguration
- (WKWebViewConfiguration *)getWkWebViewConfiguration {

    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.preferences = [WKPreferences new];
    //最小的字体大小,默认是0
    config.preferences.minimumFontSize = 10;
    //是否支持JavaScript
    config.preferences.javaScriptEnabled = YES;
    //不通过用户交互，是否可以打开窗口
    config.preferences.javaScriptCanOpenWindowsAutomatically = NO;
    //    self.userContentController = [[WKUserContentController alloc] init];
    //    config.userContentController = self.userContentController;

    return config;
}

#pragma mark - WKNavigationDelegate 页面加载过程
//开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
}
//当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {

    self.title = self.navTitle.length > 0 ? self.navTitle : webView.title;
}
//页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    self.exitButton.hidden = ![webView canGoBack];
    self.title = self.navTitle.length > 0 ? self.navTitle : webView.title;
    DLog(@"%@", self.navTitle);
    DLog(@"%@", webView.title);
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    //跳转页面的 JS 请求
    if ([message.name isEqualToString:@"changePage"]) {

        NSDictionary *bodyDict = message.body;
        [self JSCallExtention:bodyDict];
    }
}

#pragma mark - JS调用的方法
- (void)JSCallExtention:(NSDictionary *)infomation {
}

#pragma mark - 用户交互
//在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {

    NSURL *url = navigationAction.request.URL;
    //开始加载的时候判断是否有header
    NSURLRequest *request = navigationAction.request;
    NSMutableURLRequest *mutRequest = [request mutableCopy];
    NSDictionary *dictHader = request.allHTTPHeaderFields;

    if ([url.absoluteString isEqualToString:@"about:blank"]) {
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }

    if (![dictHader objectForKey:@"headerKey"]) {

        [mutRequest addValue:@"ture" forHTTPHeaderField:@"headerKey"];
        [self addHeadWithRequest:mutRequest];
        [webView loadRequest:mutRequest];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }

    UIApplication *app = [UIApplication sharedApplication];

    // 打开appstore,以及微信
    if ([url.scheme isEqualToString:@"itms-services"] ||
        [url.scheme isEqualToString:@"weixin"] ||
        [url.scheme isEqualToString:@"itms"] ||
        [url.absoluteString hasPrefix:@"https://itunes.apple.com"]) {

        if (@available(iOS 10.0, *)) {
            [app openURL:url options:@{ UIApplicationOpenURLOptionUniversalLinksOnly : @NO } completionHandler:nil];
        } else {
            [app openURL:url];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    } else if ([url.absoluteString hasPrefix:@"XX://"]) {

        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

#pragma mark - 进度条
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    //进度条
    if ([keyPath isEqualToString:@"estimatedProgress"]) {

        CGFloat newProgress = [[change objectForKey:NSKeyValueChangeNewKey] doubleValue];

        CGFloat oldProgress = [[change objectForKey:NSKeyValueChangeOldKey] doubleValue];
        //防止进度条倒行
        if (newProgress < oldProgress) {
            return;
        }

        if (newProgress == 1) {

            [self.progressView setProgress:newProgress animated:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

              [self.progressView setProgress:0 animated:NO];
              [self.progressView setHidden:YES];
              // [PPNetworkHelper hideHub];

            });
        } else {

            [self.progressView setProgress:newProgress animated:NO];
            [self.progressView setHidden:NO];
            // [PPNetworkHelper showAnimatedHub];
        }
    }

    else if ([keyPath isEqualToString:@"title"]) {
        if (object == self.wkWebView) {
            if (self.wkWebView.title.length != 0) {
                self.title = self.wkWebView.title;
            }
        } else {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    } else {

        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - 懒加载
- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, JD_NavTopHeight, KSCREEN_WIDTH, 12)];
        _progressView.tintColor = [UIColor greenColor];
        _progressView.trackTintColor = [UIColor whiteColor];
        _progressView.hidden = YES;
    }
    return _progressView;
}

#pragma mark - 按钮事件
- (void)leftButtonClick:(UIButton *)button {

    if ([self.wkWebView canGoBack]) {
        [self.wkWebView goBack];
    } else {
        if (self.navigationController) {
            [self.navigationController popViewControllerAnimated:YES];
        } else
            [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)exit {
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    } else
        [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc {
    [self.wkWebView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.wkWebView removeObserver:self forKeyPath:@"title"];
    [JDNotificationCenter removeObserver:self];
}

- (UIButton *)exitButton {
    if (!_exitButton) {

        _exitButton = [JDUIFactory createButtonWithFrame:CGRectMake(44, JD_StatusBarHeight, 44, 44) ImageName:@"normal_close" Target:self Action:@selector(exitClick) Title:nil];
        _exitButton.hidden = YES;
        [_exitButton addTarget:self action:@selector(exit) forControlEvents:UIControlEventTouchUpInside];
    }
    return _exitButton;
}

-(void)exitClick {

        if (self.navigationController) {
            [self.navigationController popViewControllerAnimated:YES];
        } else
            [self dismissViewControllerAnimated:YES completion:nil];
    }


@end
