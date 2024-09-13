//
//  AppDelegate.m
//  Spinmasterslotstrek
//
//  Created by adin on 2024/9/5.
//

#import "SpinmasterAppDelegate.h"
#import <CoreData/CoreData.h>
#import <AppsFlyerLib/AppsFlyerLib.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>

@interface SpinmasterAppDelegate ()<AppsFlyerLibDelegate>

@end

@implementation SpinmasterAppDelegate


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    AppsFlyerLib *appsFlyer = [AppsFlyerLib shared];
    appsFlyer.appsFlyerDevKey = [NSString stringWithFormat:@"%@%@", @"R9CH5Zs5bytFgTj6sm", @"kgG8"];
    appsFlyer.appleAppID = @"6670533489";
    [appsFlyer waitForATTUserAuthorizationWithTimeoutInterval:60];
    appsFlyer.delegate = self;
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [AppsFlyerLib.shared start];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (@available(iOS 14, *)) {
            [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            }];
        }
    });
}

- (void)onConversionDataSuccess:(NSDictionary *)conversionInfo
{
    NSLog(@"onConversionDataSuccess");
}

- (void)onConversionDataFail:(NSError *)error
{
    NSLog(@"onConversionDataFail");
}

@end
