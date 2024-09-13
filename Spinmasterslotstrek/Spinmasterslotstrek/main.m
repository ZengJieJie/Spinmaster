//
//  main.m
//  Spinmasterslotstrek
//
//  Created by adin on 2024/9/5.
//

#import <UIKit/UIKit.h>
#import "SpinmasterAppDelegate.h"

int main(int argc, char * argv[]) {
    NSString * appDelegateClassName;
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([SpinmasterAppDelegate class]);
    }
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
