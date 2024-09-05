//
//  AppDelegate.m
//  Spinmasterslotstrek
//
//  Created by adin on 2024/9/5.
//

#import <IQKeyboardManager/IQKeyboardManager.h>
#import "AppDelegate.h"
#import <CoreData/CoreData.h>


@interface AppDelegate ()
@property (nonatomic, strong) NSPersistentContainer *persistentContainer;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[IQKeyboardManager sharedManager] setEnable:YES];
    return YES;
}


// 懒加载 NSPersistentContainer
- (NSPersistentContainer *)persistentContainer {
    if (self.persistentContainer == nil) {
        self.persistentContainer = [[NSPersistentContainer alloc] initWithName:@"spinmaster_slots_trek"];
        
        [self.persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
            if (error != nil) {
                NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                abort();
            }
        }];
    }
    return self.persistentContainer;
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

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [self saveContext];
}

@end
