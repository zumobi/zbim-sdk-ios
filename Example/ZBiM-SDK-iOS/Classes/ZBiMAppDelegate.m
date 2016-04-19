/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2014-2016 Zumobi Inc.
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
#import "UINavigationController+CompletionHandler.h"
#import "ZBiMAppDelegate.h"
#import "ZBiMViewController.h"
#import "ZBiMContentProviderConfigViewController.h"
#import "ZBiMProductPageViewController.h"
#import "SampleAppUtilities.h"

NSString * const PresentationModeKey = @"ZBiMSampleApp.PresentationModeKey";
NSString * const ColorSchemeModeKey = @"ZBiMSampleApp.ColorSchemeModeKey";
NSString * const NetworkModeKey = @"ZBiMSampleApp.NetworkModeKey";

NSString * const SampleAppScheme = @"zbimsampleapp";
NSString * const DetailPageScheme = @"detailpage";
NSString * const ZBiMScheme = @"zbimdb";
NSString * const HttpScheme = @"http";

@implementation ZBiMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    BOOL configureContentProvider = [[standardUserDefaults objectForKey:ShowConfigOnStartupSettingKey] boolValue];
    
    if ([standardUserDefaults objectForKey:PresentationModeKey] == nil)
    {
        [standardUserDefaults setInteger:0 forKey:PresentationModeKey];
        [standardUserDefaults setInteger:0 forKey:ColorSchemeModeKey];
        [standardUserDefaults setInteger:0 forKey:NetworkModeKey];
    }
    [standardUserDefaults synchronize];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
    // In iOS 8 and later, the application must explicitly
    // register for notifications.
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert categories:nil]];
    }
#endif
    
    if (!configureContentProvider)
    {
        [self initializeZBiMSDK:[launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey]];
    }
    
    //Set the font to be used for navigation bar items
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]
     setTitleTextAttributes: @{NSFontAttributeName:[SampleAppUtilities regularFontWithScale:[SampleAppUtilities scaleFactor]]}
     forState:UIControlStateNormal];
    
    //Reposition UINavigationBar items to be centered on iPads
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]
      setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -17.2 * ([SampleAppUtilities scaleFactor] - 1)) forBarMetrics:UIBarMetricsDefault];
    
    [[UINavigationBar appearance] setTitleVerticalPositionAdjustment:(-22 * ([SampleAppUtilities scaleFactor] - 1)) forBarMetrics:UIBarMetricsDefault];
    
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
    UIViewController *currentViewController = [self getTopViewController];
    
    if ([currentViewController isMemberOfClass:[ZBiMProductPageViewController class]])
    {
        //Dismiss current details page before new content is opened
        [currentViewController dismissViewControllerAnimated:YES completion:^{
            [self handleIncomingURL:url];
        }];
    }
    else
    {
        [self handleIncomingURL:url];
    }

    return YES;
}

- (BOOL) application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void(^)(NSArray *restorableObjects))restorationHandler
{
    if ([userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb])
    {
        [self handleIncomingURL:userActivity.webpageURL];
    }
    
    return YES;
}

- (void)handleIncomingURL:(NSURL *)url
{
    // Check to see if content provider is being configured
    // if so alert user that provider must be configured
    if ([self.viewController isMemberOfClass:[ZBiMContentProviderConfigViewController class]])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Configure Content Provider"
                                                        message:[NSString stringWithFormat:@"A content provider must be configured before deep-linking can occur."]
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];

        return;
    }
    
    NSLog(@"Handling incoming URL: %@", url);
    
    if ([[url scheme] isEqualToString:DetailPageScheme])
    {
        ZBiMProductPageViewController *productPageViewController = [self.viewController.storyboard instantiateViewControllerWithIdentifier:@"ZBiMProductPageViewController"];
        
        NSString* absoluteStringUrl = [[url absoluteString] stringByReplacingOccurrencesOfString:DetailPageScheme withString:HttpScheme];
        [productPageViewController setURL:[NSURL URLWithString:absoluteStringUrl]];
        
        [[self getTopViewController] presentViewController:productPageViewController animated:YES completion:nil];
    }
    else
    {
        NSString *contentHubURI = [url absoluteString];
        if ([[url scheme] isEqualToString:SampleAppScheme])
        {
            NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
            components.scheme = ZBiMScheme;
            contentHubURI = components.URL.absoluteString;
        }
        
        id<ZBiMContentHubDelegate> contentHub = [ZBiM getCurrentContentHub];
        if (contentHub)
        {
            [contentHub loadContentWithURI:contentHubURI];
        }
        else
        {
            [ZBiM presentHubWithUri:contentHubURI completion:^(BOOL success, NSError *error) {
                if (!success)
                {
                    NSLog(@"Failed presenting Content Hub for URL: %@. Error: %@", contentHubURI, error);
                }
            }];
        }
    }
}

- (void)initializeZBiMSDK:(UILocalNotification *)localNotification
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *pubKeyPath = [standardUserDefaults objectForKey:PubKeyOverrideSettingKey];
    NSString *zbimConfigPath = [standardUserDefaults objectForKey:ZBiMConfigOverrideSettingKey];
    
    if (pubKeyPath && zbimConfigPath)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *libraryDirectory = [paths objectAtIndex:0];
        
        [ZBiM setPathToPublicKey:[libraryDirectory stringByAppendingPathComponent:pubKeyPath]];
        [ZBiM setPathToConfig:[libraryDirectory stringByAppendingPathComponent:zbimConfigPath]];
    }
    else if (pubKeyPath || zbimConfigPath)
    {
        NSLog(@"Either both paths (to files containing public key and ZBiM config) are defined, or these are not used.");
    }
    
    // Initialize the ZBiM SDK
    [ZBiM start];
    [ZBiM setAdvertiserIdDelegate:self];
    [ZBiM setLoggingDelegate:self];
    
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
        if ([ZBiM createUser:newUser withTags:nil error:&error])
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

#pragma mark Background downloads related methods

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler
{
    if ([ZBiM canHandleEventsForBackgroundURLSession:identifier])
    {
        [ZBiM setBackgroundSessionCompletionHandler:completionHandler];
    }
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [ZBiM performFetchWithCompletionHandler:^(UIBackgroundFetchResult result)
    {
        completionHandler(result);
    }];
}

- (UIViewController *) getTopViewController {
    UIViewController *currentViewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    while (currentViewController.presentedViewController)
    {
        currentViewController = (currentViewController.presentedViewController);
    }
    return currentViewController;
}

@end
