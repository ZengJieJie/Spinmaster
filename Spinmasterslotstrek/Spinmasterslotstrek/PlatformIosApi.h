//
//  AppDelegate.h
//  Spinmasterslotstrek
//
//  Created by adin on 2024/9/5.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
@interface PlatformIosApi : NSObject

+ (UIImage*)imageByScalingAndCroppingForSize:(UIImage*)sourceImage size:(CGSize)targetSize;

@end



