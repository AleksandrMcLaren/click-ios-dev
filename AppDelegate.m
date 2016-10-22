//
//  AppDelegate.m
//  click
//
//  Created by Igor Tetyuev on 07.03.16.
//  Copyright © 2016 Igor Tetyuev. All rights reserved.
//

#import "AppDelegate.h"
#import "CKApplicationModel.h"
#import "CKMainViewController.h"
#import "CKApplicationModel.h"
#import "CKServerConnection.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

@interface AppDelegate ()

@end

@implementation AppDelegate
{
    CKMainViewController *_mainViewController;
}

+ (NSString *)dataDir
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"data"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSError *dirCreationError = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:path
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&dirCreationError];
        if (dirCreationError != nil) {
            NSLog(@"Ошибка создания папки для кэша");
            assert(0);
        }
    }
    return path;
}

+ (NSString *)databasePath
{
    return [[AppDelegate dataDir] stringByAppendingPathComponent:@"click.db"];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [Fabric with:@[[Crashlytics class]]];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    // copy database from resources
    NSString *destPath = [AppDelegate databasePath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:destPath])
    {
        NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"click" ofType:@"db"];
        [[NSFileManager defaultManager] copyItemAtPath:sourcePath toPath:destPath error:nil];
    }
    
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    _mainViewController = [CKMainViewController new];
    self.window.rootViewController = _mainViewController;
    [self.window makeKeyAndVisible];
    
    [[CKApplicationModel sharedInstance] setMainController:_mainViewController];
    [[CKApplicationModel sharedInstance] didStarted];
    
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    
    return YES;

}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken  {
    [CKServerConnection sharedInstance].apnToken = deviceToken;
    NSLog(@"My token is: %@", deviceToken);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [CKServerConnection sharedInstance].apnToken = nil;
    NSLog(@"Failed to get token, error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"didReceiveRemoteNotification: %@", userInfo);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
