//
//  AppDelegate.h
//  Spinmasterslotstrek
//
//  Created by adin on 2024/9/5.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>

@class RootViewController;

@interface SpinmasterAppDelegate : NSObject <UIApplicationDelegate>
{
}
@property (nonatomic, strong) NSPersistentContainer *persistentContainer;
@property(nonatomic, readonly) RootViewController* viewController;

@end


