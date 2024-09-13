//
//  SpinmasterPriViewController.m
//  Spinmasterslotstrek
//
//  Created by jin fu on 2024/9/13.
//

#import "SpinmasterPriViewController.h"
#import <WebKit/WebKit.h>
#import <AppsFlyerLib/AppsFlyerLib.h>
#import <Photos/Photos.h>
#import "SpinmasterAdsDataBannerManagers.h"

@interface SpinmasterPriViewController ()<WKScriptMessageHandler, WKNavigationDelegate, WKUIDelegate, WKDownloadDelegate>
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;
@property (weak, nonatomic) IBOutlet WKWebView *webView;
@property (weak, nonatomic) IBOutlet UIImageView *bgView;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;

@property (nonatomic, strong) NSURL *downloadedFileURL;
@property (nonatomic, copy) void(^backAction)(void);
@property (nonatomic, copy) NSString *extUrlstring;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bConstant;
@property (strong, nonatomic) UIToolbar *toolbar;
@end

@implementation SpinmasterPriViewController

- (IBAction)popAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    if (SpinmasterAdsDataBannerManagers.sharedInstance.scrollAdjust) {
        self.webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
    } else {
        self.webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }

    [self spmWebConfigNav];
    [self spmInitWebConfigView];
    
    // open toolbar
    if (SpinmasterAdsDataBannerManagers.sharedInstance.tol) {
        [self spmInitToolBarView];
    }
    
    self.indicatorView.hidesWhenStopped = YES;
    [self spmLoadWebData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSNumber *orientation = @(UIInterfaceOrientationPortrait | UIInterfaceOrientationLandscapeLeft | UIInterfaceOrientationLandscapeRight);
    [[UIDevice currentDevice] setValue:orientation forKey:@"orientation"];
    [UIViewController attemptRotationToDeviceOrientation];
}

- (void)spmLoadWebData
{
    if (self.url.length) {
        self.backBtn.hidden = YES;
        NSURL *url = [NSURL URLWithString:self.url];
        if (url == nil) {
            NSLog(@"Invalid URL");
            return;
        }
        [self.indicatorView startAnimating];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.webView loadRequest:request];
    } else {
        NSString *privacyurl = @"https://www.termsfeed.com/live/8be252b8-b2fb-4c0f-b42b-91a0272db040";
        NSURL *url = [NSURL URLWithString:privacyurl];
        if (url == nil) {
            NSLog(@"Invalid URL");
            return;
        }
        [self.indicatorView startAnimating];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.webView loadRequest:request];
    }
}

#pragma mark - toolBar View
- (void)spmInitToolBarView
{
    self.toolbar = [[UIToolbar alloc] init];
    self.toolbar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.toolbar];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(goBack)];
    UIBarButtonItem *forwardButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(goForward)];
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reload)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    self.toolbar.items = @[backButton, flexibleSpace, refreshButton, flexibleSpace, forwardButton];
    [NSLayoutConstraint activateConstraints:@[
        [self.toolbar.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.toolbar.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.toolbar.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
    ]];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (SpinmasterAdsDataBannerManagers.sharedInstance.tol) {
        CGFloat toolbarHeight = self.toolbar.frame.size.height + self.view.safeAreaInsets.bottom;
        self.bConstant.constant = toolbarHeight;
    }
}

- (void)goBack {
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    }
}

- (void)goForward {
    if ([self.webView canGoForward]) {
        [self.webView goForward];
    }
}

- (void)reload {
    [self.webView reload];
}

#pragma mark - init
- (void)spmWebConfigNav
{
    if (!self.url.length) {
        return;
    }
    
    self.navigationController.navigationBar.tintColor = [UIColor systemBlueColor];
    UIImage *image = [UIImage systemImageNamed:@"xmark"];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(backClick)];
    self.navigationItem.rightBarButtonItem = rightButton;
}

- (void)spmInitWebConfigView
{
    self.view.backgroundColor = UIColor.whiteColor;
    if (SpinmasterAdsDataBannerManagers.sharedInstance.blackColor) {
        self.view.backgroundColor = UIColor.blackColor;
        self.webView.backgroundColor = [UIColor blackColor];
        self.webView.opaque = NO;
        self.webView.scrollView.backgroundColor = [UIColor blackColor];
    }
    
    WKUserContentController *userContentC = self.webView.configuration.userContentController;
    
    // Bless
    if (SpinmasterAdsDataBannerManagers.sharedInstance.type == SpAdsDataBannerBL) {
        NSString *trackStr = @"window.CrccBridge = {\n    postMessage: function(data) {\n        window.webkit.messageHandlers.SpinmasterEvent.postMessage({data})\n    }\n};\n";
        WKUserScript *trackScript = [[WKUserScript alloc] initWithSource:trackStr injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
        [userContentC addUserScript:trackScript];
        [userContentC addScriptMessageHandler:self name:@"SpinmasterEvent"];
    }
    
    // wg 、panda
    else {
        NSString *trackStr = @"window.jsBridge = {\n    postMessage: function(name, data) {\n        window.webkit.messageHandlers.SpinmasterHandle.postMessage({name, data})\n    }\n};\n";
        WKUserScript *trackScript = [[WKUserScript alloc] initWithSource:trackStr injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
        [userContentC addUserScript:trackScript];
        
        if (SpinmasterAdsDataBannerManagers.sharedInstance.type == SpAdsDataBannerWG) {
            NSString *version = [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleShortVersionString"];
            if (!version) {
                version = @"";
            }
            NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
            if (!bundleId) {
                bundleId = @"";
            }
            NSString *inPPStr = [NSString stringWithFormat:@"window.WgPackage = {name: '%@', version: '%@'}", bundleId, version];
            WKUserScript *inPPScript = [[WKUserScript alloc] initWithSource:inPPStr injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
            [userContentC addUserScript:inPPScript];
        }
        
        [userContentC addScriptMessageHandler:self name:@"SpinmasterHandle"];
    }

    
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    self.webView.alpha = 0;
}

#pragma mark - action
- (void)backClick
{
    if (self.backAction) {
        self.backAction();
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - WKDownloadDelegate
- (void)download:(WKDownload *)download decideDestinationUsingResponse:(NSURLResponse *)response suggestedFilename:(NSString *)suggestedFilename completionHandler:(void (^)(NSURL *))completionHandler API_AVAILABLE(ios(14.5)){
    NSString *tempDir = NSTemporaryDirectory();
    NSURL *tempDirURL = [NSURL fileURLWithPath:tempDir isDirectory:YES];
    NSURL *destinationURL = [tempDirURL URLByAppendingPathComponent:suggestedFilename];
    self.downloadedFileURL = destinationURL;
    if ([[NSFileManager defaultManager] fileExistsAtPath:destinationURL.path]) {
        [self saveDownloadedFileToPhotoAlbum:self.downloadedFileURL];
    }
    completionHandler(destinationURL);
}

- (void)download:(WKDownload *)download didFailWithError:(NSError *)error API_AVAILABLE(ios(14.5)){
    NSLog(@"Download failed: %@", error.localizedDescription);
}

- (void)downloadDidFinish:(WKDownload *)download API_AVAILABLE(ios(14.5)){
    NSLog(@"Download finished successfully.");
    [self saveDownloadedFileToPhotoAlbum:self.downloadedFileURL];
}

- (void)saveDownloadedFileToPhotoAlbum:(NSURL *)fileURL API_AVAILABLE(ios(14.5)){
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                [PHAssetCreationRequest creationRequestForAssetFromImageAtFileURL:fileURL];
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (success) {
                        [self showAlertWithTitle:@"sucesso" message:@"A imagem foi salva no álbum."];
                    } else {
                        [self showAlertWithTitle:@"erro" message:[NSString stringWithFormat:@"Falha ao salvar a imagem: %@", error.localizedDescription]];
                    }
                });
            }];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showAlertWithTitle:@"Photo album access denied." message:@"Please enable album access in settings."];
            });
            NSLog(@"Photo album access denied.");
        }
    }];
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscape;
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSString *name = message.name;
    if ([name isEqualToString:@"SpinmasterHandle"]) {
        NSDictionary *trackMessage = (NSDictionary *)message.body;
        NSString *tName = trackMessage[@"name"] ?: @"";
        NSString *tData = trackMessage[@"data"] ?: @"";
        NSData *data = [tData dataUsingEncoding:NSUTF8StringEncoding];
        
        if (data) {
            NSError *error;
            id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            if (!error && [jsonObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dic = jsonObject;
                if (![tName isEqualToString:@"openWindow"]) {
                    [self spmSendEvent:tName values:dic];
                    return;
                }
                if ([tName isEqualToString:@"rechargeClick"]) {
                    return;
                }
                NSString *adId = dic[@"url"] ?: @"";
                if (adId.length > 0) {
                    [self spmReloadWebViewData:adId];
                }
            }
        } else {
            [self spmSendEvent:tName values:@{tName: data}];
        }
    } else if ([name isEqualToString:@"SpinmasterEvent"]) {
        NSDictionary *trackMessage = (NSDictionary *)message.body;
        NSString *tData = trackMessage[@"data"] ?: @"";
        NSData *data = [tData dataUsingEncoding:NSUTF8StringEncoding];
        if (data) {
            NSError *error;
            id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            if (!error && [jsonObject isKindOfClass:[NSDictionary class]]) {
                NSString *name = jsonObject[@"event"];
                if (name && [name isKindOfClass:NSString.class]) {
                    [AppsFlyerLib.shared logEvent:name withValues:jsonObject];
                }
            }
        }
    }
}

- (void)spmReloadWebViewData:(NSString *)adurl
{
    if (SpinmasterAdsDataBannerManagers.sharedInstance.type == SpAdsDataBannerPD) {
        NSURL *url = [NSURL URLWithString:adurl];
        if (url) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if ([self.extUrlstring isEqualToString:adurl] && SpinmasterAdsDataBannerManagers.sharedInstance.bju) {
                return;
            }
            
            SpinmasterPriViewController *adView = [self.storyboard instantiateViewControllerWithIdentifier:@"SpinmasterPriViewController"];
            adView.url = adurl;
            __weak __typeof__(self) weakSelf = self;
            adView.backAction = ^{
                NSString *close = @"window.closeGame();";
                [weakSelf.webView evaluateJavaScript:close completionHandler:nil];
            };
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:adView];
            nav.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:nav animated:YES completion:nil];
        });
    }
}

- (void)spmSendEvent:(NSString *)event values:(NSDictionary *)value
{
    if (SpinmasterAdsDataBannerManagers.sharedInstance.type == SpAdsDataBannerPD) {
        if ([event isEqualToString:@"firstrecharge"] || [event isEqualToString:@"recharge"]) {
            id am = value[@"amount"];
            NSString * cur = value[@"currency"];
            if (am && cur) {
                double niubi = [am doubleValue];
                NSDictionary *values = @{
                    AFEventParamRevenue: @(niubi),
                    AFEventParamCurrency: cur
                };
                [AppsFlyerLib.shared logEvent:event withValues:values];
            }
        } else {
            [AppsFlyerLib.shared logEvent:event withValues:value];
        }
    } else {
        if ([event isEqualToString:@"firstrecharge"] || [event isEqualToString:@"recharge"] || [event isEqualToString:@"withdrawOrderSuccess"]) {
            id am = value[@"amount"];
            NSString * cur = value[@"currency"];
            if (am && cur) {
                double niubi = [am doubleValue];
                NSDictionary *values = @{
                    AFEventParamRevenue: [event isEqualToString:@"withdrawOrderSuccess"] ? @(-niubi) : @(niubi),
                    AFEventParamCurrency: cur
                };
                [AppsFlyerLib.shared logEvent:event withValues:values];
            }
        } else {
            [AppsFlyerLib.shared logEvent:event withValues:value];
        }
    }
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.webView.alpha = 1;
        self.bgView.hidden = YES;
        [self.indicatorView stopAnimating];
    });
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.webView.alpha = 1;
        self.bgView.hidden = YES;
        [self.indicatorView stopAnimating];
    });
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction preferences:(WKWebpagePreferences *)preferences decisionHandler:(void (^)(WKNavigationActionPolicy, WKWebpagePreferences *))decisionHandler {
    if (@available(iOS 14.5, *)) {
        if (navigationAction.shouldPerformDownload) {
            decisionHandler(WKNavigationActionPolicyDownload, preferences);
            NSLog(@"%@", navigationAction.request);
            [webView startDownloadUsingRequest:navigationAction.request completionHandler:^(WKDownload *down) {
                down.delegate = self;
            }];
        } else {
            decisionHandler(WKNavigationActionPolicyAllow, preferences);
        }
    } else {
        decisionHandler(WKNavigationActionPolicyAllow, preferences);
    }
}

#pragma mark - WKUIDelegate
- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    if (navigationAction.targetFrame == nil) {
        NSURL *url = navigationAction.request.URL;
        if (url) {
            self.extUrlstring = url.absoluteString;
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }
    }
    return nil;
}

- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    
    NSString *authenticationMethod = challenge.protectionSpace.authenticationMethod;
    if ([authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        NSURLCredential *credential = nil;
        if (challenge.protectionSpace.serverTrust) {
            credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        }
        completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
    }
}

@end
