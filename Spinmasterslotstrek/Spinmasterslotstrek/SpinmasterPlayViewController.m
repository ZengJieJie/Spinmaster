//
//  ViewController.m
//  Spinmasterslotstrek
//
//  Created by adin on 2024/9/5.
//

#import "SpinmasterPlayViewController.h"
#import "Spinmasterslotstrek-Swift.h"
#import "RootViewController.h"
#import "SpinmasterAppDelegate.h"
@interface SpinmasterPlayViewController ()

@end

@implementation SpinmasterPlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


+ (void) SpinmasterPlay
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *gameMainVC = [storyboard instantiateInitialViewController];
    RootViewController *rootVC = [(SpinmasterAppDelegate *)UIApplication.sharedApplication.delegate viewController];
    gameMainVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [rootVC presentViewController:gameMainVC animated:NO completion:nil];
}

@end
