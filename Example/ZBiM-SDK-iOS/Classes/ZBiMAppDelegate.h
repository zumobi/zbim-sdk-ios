//
//  ZBiMAppDelegate.h
//  ZBiMSampleApp
//
//  Created by George Tonev on 4/8/14.
//  Copyright (c) 2014 Zumobi. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ZBiM.h"

@class ZBiMViewController;

@interface ZBiMAppDelegate : UIResponder <UIApplicationDelegate, ZBiMAdvertiserIdDelegate, ZBiMLoggingDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ZBiMViewController *viewController;

+ (void)showToast:(NSString *)message isErrorMessage:(BOOL)isErrorMessage;

@end
