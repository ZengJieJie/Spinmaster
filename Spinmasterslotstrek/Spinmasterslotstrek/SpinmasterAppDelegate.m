//
//  AppDelegate.m
//  Spinmasterslotstrek
//
//  Created by adin on 2024/9/5.
//

#import <IQKeyboardManager/IQKeyboardManager.h>
#import <CoreData/CoreData.h>
#import <UMCommon/UMCommon.h>
#import "SpinmasterAppDelegate.h"
#import "cocos2d.h"
#import "AppDelegate.h"
#import "RootViewController.h"
#import "SDKWrapper.h"
#import "platform/ios/CCEAGLView-ios.h"
#import "Adjust.h"
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <AdSupport/AdSupport.h>
#import "SpinmasafeProtector.h"

using namespace cocos2d;

@implementation SpinmasterAppDelegate

Application* app = nullptr;
@synthesize window;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [SpinmasafeProtector SpinmasopenSafeProtectorWithIsDebug:NO block:^(NSException *exception, LSSafeProtectorCrashType crashType) {
          
        }];
    [[SDKWrapper getInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    
    NSString *yourAppToken = @"p0jjcvpsfdhc";
    NSString *environment = ADJEnvironmentProduction;
    ADJConfig* myAdjustConfig = [ADJConfig configWithAppToken:yourAppToken
                                   environment:environment];
    [myAdjustConfig setLogLevel:ADJLogLevelVerbose];
   
    [UMConfigure initWithAppkey:@"p0jjcvpdfasfdhc" channel:@"Spinmaster"];
    
    // Add the view controller's view to the window and display.
    float scale = [[UIScreen mainScreen] scale];
    CGRect bounds = [[UIScreen mainScreen] bounds];
    window = [[UIWindow alloc] initWithFrame: bounds];
    
    // cocos2d application instance
    app = new AppDelegate(bounds.size.width * scale, bounds.size.height * scale);
    app->setMultitouch(true);
    
    // Use RootViewController to manage CCEAGLView
    _viewController = [[RootViewController alloc]init];
#ifdef NSFoundationVersionNumber_iOS_7_0
    _viewController.automaticallyAdjustsScrollViewInsets = NO;
    _viewController.extendedLayoutIncludesOpaqueBars = NO;
    _viewController.edgesForExtendedLayout = UIRectEdgeAll;
#else
    _viewController.wantsFullScreenLayout = YES;
#endif
    // Set RootViewController to window
    if ( [[UIDevice currentDevice].systemVersion floatValue] < 6.0)
    {
        // warning: addSubView doesn't work on iOS6
        [window addSubview: _viewController.view];
    }
    else
    {
        // use this method on ios6
        [window setRootViewController:_viewController];
        
    }
    
    [window makeKeyAndVisible];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    //run the cocos2d-x game scene
    app->start();

    


    [Adjust appDidLaunch:myAdjustConfig];
    
    

    return YES;
}


- (void)requestIDFA {
  [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {

  }];
}

- (void)applicationWillResignActive:(UIApplication *)application {
   
    app->onPause();
    [[SDKWrapper getInstance] applicationWillResignActive:application];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    app->onResume();
    [[SDKWrapper getInstance] applicationDidBecomeActive:application];
    [Adjust requestTrackingAuthorizationWithCompletionHandler:^(NSUInteger status) {
//        NSLog(@"idfa %@,idfv  %@,status %lu",[Adjust idfa], [Adjust idfv] ,status);
       switch (status) {
          case 0:
             // ATTrackingManagerAuthorizationStatusNotDetermined case
             break;
          case 1:
             // ATTrackingManagerAuthorizationStatusRestricted case
             break;
          case 2:
             // ATTrackingManagerAuthorizationStatusDenied case
             break;
          case 3:
             // ATTrackingManagerAuthorizationStatusAuthorized case
             break;
       }
    }];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
    [[SDKWrapper getInstance] applicationDidEnterBackground:application];
    [self saveContext];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
    [[SDKWrapper getInstance] applicationWillEnterForeground:application];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[SDKWrapper getInstance] applicationWillTerminate:application];
    delete app;
    app = nil;
}

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    if ([context hasChanges]) {
        @try {
            NSError *error = nil;
            if (![context save:&error]) {
                // 处理错误
                NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                abort();
            }
        }
        @catch (NSException *exception) {
            NSLog(@"Exception occurred: %@, %@", exception, [exception userInfo]);
            abort();
        }
    }
}

// 懒加载 NSPersistentContainer
- (NSPersistentContainer *)persistentContainer {
    if (_persistentContainer == nil) {
        _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"spinmaster_slots_trek"];
        
        [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
            if (error != nil) {
                NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                abort();
            }
        }];
    }
    return _persistentContainer;
}



#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}



@end
