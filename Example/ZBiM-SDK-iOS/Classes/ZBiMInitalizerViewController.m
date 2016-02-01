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

#import "ZBiMInitalizerViewController.h"
#import "ZBiMAppDelegate.h"
#import "ZBiMContentProviderConfigViewController.h"
#import "ZBiMViewController.h"

@interface ZBiMInitalizerViewController ()

@end

@implementation ZBiMInitalizerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    ZBiMAppDelegate *appDelegate = (ZBiMAppDelegate *)[UIApplication sharedApplication].delegate;

    BOOL configureContentProvider = [[[NSUserDefaults standardUserDefaults] objectForKey:ShowConfigOnStartupSettingKey] boolValue];
    
    if (configureContentProvider)
    {
        appDelegate.viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ZBiMContentProviderConfigViewController"];
    }
    else
    {
        appDelegate.viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ZBiMViewController"];
    }
    
    // If you want the back button hidden completley you have to hide it before the nav bar
    // has switched to the view controller, otherwise only the arrow will be hidden.
    [appDelegate.viewController.navigationItem setHidesBackButton:YES animated:NO];
    
    [self.navigationController pushViewController:appDelegate.viewController animated:NO];
}

@end
