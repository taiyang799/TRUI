//
//  AppDelegate.m
//  TRUI
//
//  Created by Mac on 2020/4/22.
//  Copyright © 2020 Mac. All rights reserved.
//

#import "TRAppDelegate.h"
#import "TRViewController.h"

@interface TRAppDelegate ()

@end

@implementation TRAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self setRootViewController];
    return YES;
}

- (void)setRootViewController
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    TRViewController *vc = [[TRViewController alloc] init];
    self.window.rootViewController = vc;
    [self.window makeKeyAndVisible];
}

@end
