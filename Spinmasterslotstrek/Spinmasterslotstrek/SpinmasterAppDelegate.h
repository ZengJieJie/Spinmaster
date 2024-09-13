//
//  AppDelegate.h
//  Spinmasterslotstrek
//
//  Created by adin on 2024/9/5.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>



@interface SpinmasterAppDelegate : NSObject <UIApplicationDelegate>
{
}
@property (nonatomic, strong) NSPersistentContainer *persistentContainer;
@property (strong, nonatomic) UIWindow * window;

@end


