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

#import "ZBiMViewController.h"
#import "ZBiM.h"
#import "ZBiMContentHubContainerViewController.h"
#import "ZBiMConfigureContentHubViewController.h"
#import "ZBiMCreateNewUserViewController.h"
#import "ZBiMUserManagementViewController.h"
#import "ZBiMAppDelegate.h"
#import "ZBiMContentProviderConfigViewController.h"
#import "ZBiMShowcasesViewController.h"
#import "SampleAppUtilities.h"

NSString *const ZBiMSimulatorLocationId = @"simulator";

@interface ZBiMViewController ()

@property (nonatomic, assign) CGFloat scaleFactor;
@property (nonatomic, strong) UIFont *largeFont;

@end

#pragma message "Uncomment one of the following to use URI or tag overrides when showing Content Hub."
// #define URI_OVERRIDE @"zbimdb://zumobi/about/linkedin/the-definitive-book-on-customer-centric-business-management.html"
// #define TAGS_OVERRIDE @"tag1,tag2,tag3"

@implementation ZBiMViewController
{
    NSArray *_allUsers;
    NSString *_pickerSelection;
    NSString *_uriOverride;
    NSArray *_tagsOverride;
    CLLocationManager *_locationManager;
    ZBiMLocationServiceCallback _locationServiceCallback;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dbDownloadProgressChanged:) name:ZBiMDBDownloadProgressChanged object:nil];
    
#ifdef URI_OVERRIDE
    _uriOverride = URI_OVERRIDE;
#endif
    
#ifdef TAGS_OVERRIDE
    NSString *tagsOverrideRawValue = TAGS_OVERRIDE;
    if (tagsOverrideRawValue)
    {
        _tagsOverride = [tagsOverrideRawValue componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
    }
#endif
    
    if (_uriOverride && _tagsOverride)
    {
        NSLog(@"URI override and tags override are mutually exclusive. Please use one OR the other. Ignoring tags override in favor of URI override as the latter is more specific.");
        _tagsOverride = nil;
    }
    
    [ZBiM setLocationServiceDelegate:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    self.progressView.progress = 0.0f;
    self.progressView.trackTintColor = [UIColor whiteColor];

    _allUsers = [ZBiM getAllUsers];
    
    self.scaleFactor = [SampleAppUtilities scaleFactor];
    
    [self updateFonts];
}

// Using traitCollection is the right way to determine scaling as it's based on
// size classes, but the property and the corresponding callback method were introduced
// in iOS 8. When running on iOS 7 we rely on viewDidLoad to set the scaleFactor
// as the following method will not be called.
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
    CGFloat newScaleFactor = [SampleAppUtilities newScaleFactor:self.traitCollection];
    
    if (newScaleFactor != self.scaleFactor)
    {
        self.scaleFactor = newScaleFactor;
        [self updateFonts];
    }
}

- (void)updateFonts
{
    self.largeFont = [SampleAppUtilities largeFontWithScale:self.scaleFactor];
    
    [SampleAppUtilities setUpButton:self.userManagmentButton :self.scaleFactor];
    [SampleAppUtilities setUpButton:self.configureContentProviderButton :self.scaleFactor];
    [SampleAppUtilities setUpButton:self.showcasesButton :self.scaleFactor];
    [SampleAppUtilities setUpButton:self.configureContentHubButton :self.scaleFactor];
    [SampleAppUtilities setUpButton:self.showContentHubButton :self.scaleFactor];
    
    self.showContentHubButton.titleLabel.font = self.largeFont;
}

- (IBAction)showContentHubButtonPressed:(id)sender
{
    if (![ZBiM activeUser])
    {
        UIAlertView *activeUserNotSetAlertView = [[UIAlertView alloc] initWithTitle:@"Cannot Show Content Hub" message:@"You first need to create a new user." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [activeUserNotSetAlertView show];
        return;
    }
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    if ([standardUserDefaults integerForKey:ColorSchemeModeKey] == 0)
    {
        [ZBiM setColorScheme:ZBiMColorSchemeDark];
    }
    else
    {
        [ZBiM setColorScheme:ZBiMColorSchemeLight];
    }
    
    if ([standardUserDefaults integerForKey:PresentationModeKey] == 0)
    {
        if (_uriOverride)
        {
            [ZBiM presentHubWithUri:_uriOverride completion:^(BOOL success, NSError *error) {
                if (!success)
                {
                    NSLog(@"Failed presenting content hub with URI override. Error: %@", error);
                }
            }];
        }
        else if (_tagsOverride)
        {
            [ZBiM presentHubWithTags:_tagsOverride completion:^(BOOL success, NSError *error) {
                if (!success)
                {
                    NSLog(@"Failed presenting content hub with tags override. Error: %@", error);
                }
            }];
        }
        else
        {
            [ZBiM presentHub:^(BOOL success, NSError *error) {
                if (!success)
                {
                    NSLog(@"Failed presenting content hub. Error: %@", error);
                }
            }];
        }
    }
    else
    {
        ZBiMContentHubContainerViewController *contentHubContainer = [self.storyboard instantiateViewControllerWithIdentifier:@"ZBiMContentHubContainerViewController"];
        contentHubContainer.uriOverride = _uriOverride;
        contentHubContainer.tagsOverride = _tagsOverride;
        
        [self presentViewController:contentHubContainer animated:YES completion:nil];
    }
    
    if ([standardUserDefaults integerForKey:NetworkModeKey] == 0)
    {
        [ZBiM setContentSource:ZBiMContentSourceExternalAllowed];
    }
    else
    {
        [ZBiM setContentSource:ZBiMContentSourceLocalOnly];
    }
}

- (IBAction)configureContentHub:(id)sender
{
    ZBiMConfigureContentHubViewController *configureContentHubViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ZBiMConfigureContentHubViewController"];
    
    [configureContentHubViewController.navigationItem setHidesBackButton:YES animated:NO];

    [self.navigationController pushViewController:configureContentHubViewController animated:NO];
}

- (IBAction)configureContentProviderButtonPressed:(id)sender
{
    UIAlertView *activeUserNotSetAlertView = [[UIAlertView alloc] initWithTitle:nil message:@"To configure a new content provider, please select OK and restart app." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [activeUserNotSetAlertView show];
}

- (IBAction)showUserManagementView:(id)sender
{
    ZBiMUserManagementViewController *userManagementViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ZBiMUserManagementViewController"];
    
    [userManagementViewController.navigationItem setHidesBackButton:YES animated:NO];
    
    [self.navigationController pushViewController:userManagementViewController animated:NO];
}

- (IBAction)showcasesButtonPressed:(id)sender
{
    ZBiMShowcasesViewController *showcasesViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ZBiMShowcasesViewController"];
    
    [showcasesViewController.navigationItem setHidesBackButton:YES animated:NO];
    
    [self.navigationController pushViewController:showcasesViewController animated:NO];
}

- (void)dbDownloadProgressChanged:(NSNotification *)notification
{
    self.progressView.progress = [notification.userInfo[@"progress"] floatValue] / 100.0f;
}

#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex)
    {
        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
        [standardUserDefaults setObject:@(YES) forKey:ShowConfigOnStartupSettingKey];
        [standardUserDefaults synchronize];
    }
}

#pragma mark ZBiM Location Service Delegate

- (void)fetchLocation:(ZBiMLocationServiceCallback)callback
{
#if TARGET_OS_SIMULATOR
    callback(nil, ZBiMSimulatorLocationId);
#else
    _locationManager = [CLLocationManager new];
    
    if (_locationManager.location) {
        callback(_locationManager.location, nil);
    } else {
        _locationServiceCallback = callback;
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;

        if (CLLocationManager.authorizationStatus == kCLAuthorizationStatusAuthorized ||
            CLLocationManager.authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse)
        {
            [_locationManager startUpdatingLocation];
        }
        else
        {
            [self authorizeLocationService];
        }
    }
#endif
}

#pragma mark CLLocationManager Delegate

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [manager stopUpdatingLocation];
    
    if (_locationServiceCallback) {
        _locationServiceCallback([locations lastObject], nil);
        _locationServiceCallback = nil;
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusNotDetermined) {
        return;
    }
    
    if (!_locationServiceCallback) {
        return;
    }
    
    if (CLLocationManager.authorizationStatus == kCLAuthorizationStatusAuthorized ||
        CLLocationManager.authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [_locationManager startUpdatingLocation];
    } else {
        _locationServiceCallback(nil, nil);
        _locationServiceCallback = nil;
    }
}

#pragma mark Location related methods

- (CLLocationManager *)authorizeLocationService
{
    if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
    {
        // In iOS8+, you need to explicitly ask for authorization
        [_locationManager requestWhenInUseAuthorization];
    }
    else
    {
        // In iOS7-, when you start location services, the OS asks for authorization
        [_locationManager startUpdatingLocation];
    }
    
    return _locationManager;
}

@end
