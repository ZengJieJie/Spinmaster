//
//  AppDelegate.m
//  YoDazzleSlotMatrixNo
//
//  Created by adin on 2024/9/10.
//

#import "AppDelegate.h"
#import <IQKeyboardManager/IQKeyboardManager.h>
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[IQKeyboardManager sharedManager] setEnable:YES];
    return YES;
}





@end
