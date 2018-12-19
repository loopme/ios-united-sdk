//
//  LoopMeGDPRViewController.m
//  LoopMeSDK
//
//  Created by Bohdan on 5/14/18.
//  Copyright © 2018 LoopMe. All rights reserved.
//
#import <WebKit/WebKit.h>

#import "LoopMeGDPRViewController.h"
#import "LoopMeBackView.h"
#import "LoopMeDefinitions.h"
#import "NSURL+LoopMeAdditions.h"
#import "LoopMeLogging.h"

static NSString * const _kLoopMeNamespacePopup = @"popup";
static NSString * const _kLoopMePopupCloseCommand = @"close";
static NSString * const _kLoopMePopupReadyCommand = @"ready";
static NSTimeInterval _kLoopMeClosePopupInterval = 5;

@interface LoopMeGDPRViewController () <WKNavigationDelegate, WKUIDelegate>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) UIBarButtonItem *backButton;
@property (nonatomic, strong) UIBarButtonItem *refreshButton;
@property (nonatomic, strong) UIBarButtonItem *safariButton;
@property (nonatomic, strong) UIBarButtonItem *doneButton;

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSTimer *popupCloseTimer;

@end

@implementation LoopMeGDPRViewController

- (instancetype)initWithURL:(NSURL *)url {
    if (self = [super init]) {
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
        _webView.translatesAutoresizingMaskIntoConstraints = NO;
        _webView.backgroundColor = [UIColor whiteColor];
        _webView.navigationDelegate = self;
        _webView.UIDelegate = self;
        _url = url;

        [_webView loadRequest:[NSURLRequest requestWithURL:url]];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.webView];
    
    UIToolbar *toolBar = [self createToolbar];
    [self.view addSubview:toolBar];
    
    if (@available(iOS 11.0, *)) {
        [toolBar.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor].active = YES;
        [self.webView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
        [self.webView.bottomAnchor constraintEqualToAnchor:toolBar.safeAreaLayoutGuide.topAnchor].active = YES;
    } else {
        [toolBar.bottomAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.bottomAnchor].active = YES;
        [self.webView.topAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.topAnchor].active = YES;
        [self.webView.bottomAnchor constraintEqualToAnchor:toolBar.layoutMarginsGuide.topAnchor].active = YES;
    }
    
    [self.webView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.webView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [toolBar.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [toolBar.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.popupCloseTimer = [NSTimer scheduledTimerWithTimeInterval:_kLoopMeClosePopupInterval target:self selector:@selector(close) userInfo:nil repeats:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIToolbar *)createToolbar {
    self.spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectZero];
    [self.spinner sizeToFit];
    self.spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    self.spinner.hidesWhenStopped = YES;
    
    LoopMeBackView *backView = [[LoopMeBackView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    self.backButton = [[UIBarButtonItem alloc] initWithCustomView:backView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(back:)];
    [backView addGestureRecognizer:tap];
    
    self.refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                       target:self
                                                                       action:@selector(refresh)];

    UIBarButtonItem *flexiSpace1 = [[UIBarButtonItem alloc]
                                    initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                    target:nil
                                    action:nil];
    
    
    UIBarButtonItem *spinnerItem = [[UIBarButtonItem alloc] initWithTitle:@"S"
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:nil
                                                                   action:nil];
    spinnerItem.customView = self.spinner;
    
    UIToolbar *browseToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    browseToolbar.barStyle = UIBarStyleBlack;
    browseToolbar.translatesAutoresizingMaskIntoConstraints = NO;
    browseToolbar.items = @[self.backButton, flexiSpace1, spinnerItem];
    
    return browseToolbar;
}

- (void)back:(id)sender {
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    }
}

- (void)close {
    [self dismissViewControllerAnimated:YES completion:^{
        if ([self.delegate respondsToSelector:@selector(loopMeGDPRViewControllerDidDisapper)]) {
            [self.delegate loopMeGDPRViewControllerDidDisapper];
        }
    }];
}

- (void)refresh {
    [self.webView reload];
}

- (BOOL)shouldInterceptURL:(NSURL *)URL {
    return [URL.scheme.lowercaseString isEqualToString:kLoopMeURLScheme];
}

- (void)processURL:(NSURL *)URL {
    NSString *ns = URL.host;
    NSString *command = URL.lastPathComponent;
    NSDictionary *params = [URL lm_toDictionary];
    LoopMeLogDebug(@"Processing JS command: %@, namespace: %@, params: %@", command, ns, params);
    [self processCommand:command forNamespace:ns withParams:params];
}

- (void)processCommand:(NSString *)command forNamespace:(NSString *)ns withParams:(NSDictionary *)params {
    LoopMeLogDebug(@"JS command: %@", command);
    
    if ([ns isEqualToString:_kLoopMeNamespacePopup]) {
        [self processPopupCommand:command withParams:params];
    } else {
        LoopMeLogDebug(@"Namespace: %@ is not supported", ns);
    }
}

- (void)processPopupCommand:(NSString *)command withParams:(NSDictionary *)params {
    if ([command isEqualToString:_kLoopMePopupCloseCommand]) {
        [self close];
    } else if ([command isEqualToString:_kLoopMePopupReadyCommand]) {
        [self.popupCloseTimer invalidate];
    } else {
        LoopMeLogDebug(@"JS command: %@ for namespace: %@ is not supported", command, @"webview");
    }
}

#pragma mark - WKWebViewDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
//    [self.spinner startAnimating];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    if ([self shouldInterceptURL:navigationAction.request.URL]) {
        [self processURL:navigationAction.request.URL];
        decisionHandler(WKNavigationActionPolicyCancel);
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    
    return nil;
}

@end
