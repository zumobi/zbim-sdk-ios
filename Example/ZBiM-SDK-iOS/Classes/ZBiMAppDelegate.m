//
//  ZBiMAppDelegate.m
//  ZBiMSampleApp
//
//  Created by George Tonev on 4/8/14.
//  Copyright (c) 2014 Zumobi. All rights reserved.
//

#import <AdSupport/AdSupport.h>

#import "ZBiMAppDelegate.h"
#import "ZBiMViewController.h"
#import "UIView+Toast.h"

// The custom URL scheme is registered as part of the
// application's info.plist file, so if you want to change it
// you must update both places.
#define ZBIM_CUSTOM_URL_SCHEME @"zbimsampleapp"

@implementation ZBiMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.viewController = [[ZBiMViewController alloc] initWithNibName:@"ZBiMViewController" bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
    // In iOS 8 and later, the application must explicitly
    // register for notifications.
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert categories:nil]];
    }
#endif
    
    // Initialize the ZBiM SDK
    [ZBiM start];
    [ZBiM setAdvertiserIdDelegate:self];
    [ZBiM setLoggingDelegate:self];
    [ZBiM whitelistURLScheme:ZBIM_CUSTOM_URL_SCHEME];
    
    UILocalNotification *localNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotification)
    {
        if (![ZBiM handleLocalNotification:localNotification showAlert:NO])
        {
            // This was not a ZBiM local notification, so the
            // application must decide how to handle it. In the
            // case of this sample app, just show an alert.
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"UNHANDLED: %@", localNotification.alertAction]
                                                            message:[NSString stringWithFormat:@"UNHANDLED: %@", localNotification.alertBody]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ignore"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    if (![ZBiM handleLocalNotification:notification showAlert:([application applicationState] == UIApplicationStateActive)])
    {
        // This was not a ZBiM local notification, so the
        // application must decide how to handle it. In the
        // case of this sample app, just show an alert.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"UNHANDLED: %@", notification.alertAction]
                                                        message:[NSString stringWithFormat:@"UNHANDLED: %@", notification.alertBody]
                                                       delegate:nil
                                              cancelButtonTitle:@"Ignore"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Custom URL Handler"
                                                    message:[NSString stringWithFormat:@"App received request to handle custom URL scheme: %@", url]
                                                   delegate:nil
                                          cancelButtonTitle:@"Ignore"
                                          otherButtonTitles:nil];
    [alert show];
    
    return YES;
}

+ (void)showToast:(NSString *)message isErrorMessage:(BOOL)isErrorMessage
{
    UIView *topView = [[[[UIApplication sharedApplication] keyWindow] subviews] lastObject];
    
    if (!isErrorMessage)
    {
        [topView makeToast:message duration:3.0 position:@"top" backgroundColor:[UIColor colorWithRed:63.0f/255.0 green:217.0f/255.0f blue:111.0f / 255.0f alpha:0.9f]];
    }
    else
    {
        [topView makeToast:message duration:NSTimeIntervalSince1970 position:@"top" backgroundColor:[UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:0.8f]];
    }
}

#pragma mark ZBiMAdvertiserIdDelegate methods

- (NSString *)advertiserId
{
    return [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
}

#pragma mark ZBiMLoggingDelegate methods

- (void)log:(NSString *)message severityLevel:(ZBiMSeverityLevel)severityLevel verbosityLevel:(ZBiMVerbosityLevel)verbosityLevel
{
    if (verbosityLevel == ZBiMLogVerbosityInfo)
    {
        BOOL isErrorMessage = (severityLevel <= ZBiMLogSeverityError);
        
        if (![NSThread isMainThread])
        {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [ZBiMAppDelegate showToast:message isErrorMessage:isErrorMessage];
            });
        }
        else
        {
            [ZBiMAppDelegate showToast:message isErrorMessage:isErrorMessage];
        }
    }

    NSLog(@"%@", message);
}

@end
