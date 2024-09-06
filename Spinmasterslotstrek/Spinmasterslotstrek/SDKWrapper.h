//
//  AppDelegate.h
//  Spinmasterslotstrek
//
//  Created by adin on 2024/9/5.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface SDKWrapper : NSObject
@property(nonatomic,strong) NSString *name;
+ (instancetype)getInstance;
// iOS应用生命周期
- (void)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
- (void)applicationDidBecomeActive:(UIApplication *)application;
- (void)applicationWillResignActive:(UIApplication *)application;
- (void)applicationDidEnterBackground:(UIApplication *)application;
- (void)applicationWillEnterForeground:(UIApplication *)application;
- (void)applicationWillTerminate:(UIApplication *)application;
@end

NS_ASSUME_NONNULL_END
