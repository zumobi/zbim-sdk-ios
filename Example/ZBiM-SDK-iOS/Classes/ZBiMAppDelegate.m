/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2014-2015 Zumobi Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import <AdSupport/AdSupport.h>

#import "ZBiMAppDelegate.h"
#import "ZBiMViewController.h"

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
    
    NSString *currentUser = [ZBiM activeUser];
    if (!currentUser)
    {
        // A new default user is created upon app
        // first run. There are no tags associated
        // with the default user. It's app to the
        // user to create a new user with the right
        // set of tags using the app's UI.
        NSError *error = nil;
        NSString *newUser = [ZBiM generateDefaultUserId];
        if ([ZBiM createUser:newUser withTags:@[] error:&error])
        {
            error = nil;
            if (![ZBiM setActiveUser:newUser error:&error])
            {
                NSLog(@"Failed setting new user (%@) as active. Error: %@", newUser, error);
            }
        }
        else
        {
            NSLog(@"Failed creating new user (%@). Error: %@", newUser, error);
        }
    }
    
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

#pragma mark ZBiMAdvertiserIdDelegate methods

- (NSString *)advertiserId
{
    // The following demonstrates overriding ZBiM SDK's handling of advertiser ID.
    // By default the ZBiM SDK will first check if "Limit Ad Tracking" has been turned
    // on inside Settings->Privacy->Advertising. If for whatever reason the app wants
    // to skip that check and always go straight to returning IDFA, it can do so by
    // implementing the ZBiMAdvertiserIdDelegate protocol and setting itself as the
    // ad ID delegate for ZBiM SDK. Alternatively, if the app wants to prevent SDK from
    // accessing IDFA altogether it can return nil or any other appropriate value from
    // this method, e.g.:
    //
    // return @"sample-ad-ID";
    
    return [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
}

#pragma mark ZBiMLoggingDelegate methods

// Demonstrates app setting itself as the logging delegate.
- (void)log:(NSString *)message severityLevel:(ZBiMSeverityLevel)severityLevel verbosityLevel:(ZBiMVerbosityLevel)verbosityLevel
{
    NSLog(@"ZBiM Sample App: %@", message);
}

@end
