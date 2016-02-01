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

#import "ZBiMContentProviderConfigViewController.h"
#import "ZBiMViewController.h"
#import "ZBiMAppDelegate.h"
#import "SampleAppUtilities.h"
#import "UINavigationController+CompletionHandler.h"

NSString *const ShowConfigOnStartupSettingKey = @"ZBiMSampleApp.ShowConfigOnStartup";
NSString *const PubKeyOverrideSettingKey = @"ZBiMSampleApp.PubKeyOverride";
NSString *const ZBiMConfigOverrideSettingKey = @"ZBiMSampleApp.ZBiMConfigOverride";
NSString *const PubKeyOverrideFileName = @"pubkey_override.der";
NSString *const ZBiMConfigOverrideFileName = @"zbimconfig_override.plist";

@interface ZBiMContentProviderConfigViewController ()

@property (nonatomic, assign) CGFloat scaleFactor;
@property (nonatomic, strong) UIFont *regularFont;

@end

@implementation ZBiMContentProviderConfigViewController
{
    NSURLSession *_defaultSession;
    UIActivityIndicatorView *_activityIndicator;
    NSString *_pubKeyPath;
    NSString *_zbimConfigPath;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.hidesBackButton = YES;
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults removeObjectForKey:ShowConfigOnStartupSettingKey];
    [standardUserDefaults synchronize];
    
    NSURLSessionConfiguration *defaultConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    _defaultSession = [NSURLSession sessionWithConfiguration:defaultConfig];
    self.configURLTextField.delegate = self;

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.scaleFactor = [SampleAppUtilities scaleFactor];

    [self updateFonts];
}

// For information about this method look at ZBiMViewController
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
    self.regularFont = [SampleAppUtilities regularFontWithScale:self.scaleFactor];
    
    [SampleAppUtilities setUpButton:self.getNewConfigButton :self.scaleFactor];
    [SampleAppUtilities setUpButton:self.existingConfigButton :self.scaleFactor];
    [SampleAppUtilities setUpButton:self.cancelButton :self.scaleFactor];
    
    self.descriptionLabel.font = self.regularFont;
    self.configURLTextField.font = self.regularFont;
}

- (IBAction)proceedButtonPressed:(id)sender
{
    [self configureNewContentProvider];
}

- (IBAction)resetButtonPressed:(id)sender
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults removeObjectForKey:PubKeyOverrideSettingKey];
    [standardUserDefaults removeObjectForKey:ZBiMConfigOverrideSettingKey];
    [standardUserDefaults synchronize];
    [self presentMainViewController];
}

- (IBAction)cancelButtonPressed:(id)sender
{
    [self presentMainViewController];
}

- (void)configureNewContentProvider
{
    NSString *configString = self.configURLTextField.text;
    NSURL *configURL = [NSURL URLWithString:configString];
    
    if (![configURL.scheme isEqualToString:@"https"])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Incorrect URL format"
                                                        message:@"All DB service urls must implement https. Please update your url to support https."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    else
    {
    
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_activityIndicator];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_activityIndicator
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.0
                                                               constant:0.0]];

        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_activityIndicator
                                                              attribute:NSLayoutAttributeCenterY
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeCenterY
                                                             multiplier:1.0
                                                               constant:0.0]];


        [_activityIndicator startAnimating];


        NSURLSessionDataTask *dataTask = [_defaultSession dataTaskWithRequest:[NSURLRequest requestWithURL:configURL]
                                                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                                [self processContentProviderConfigData:data];
                                                            }];

        [dataTask resume];
    }
}

- (void)processContentProviderConfigData:(NSData *)data
{
    NSError *deserializeError = nil;
    NSDictionary *contentProviderConfig = nil;
    __block BOOL retrievedPublicKeyFile = NO;
    __block BOOL retrievedZBiMConfigFile = NO;
    
    if (!data)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"An error has occured"
                                                        message:@"Something went wrong while configuring the content provider. Please check to make sure you are using a supported URL and try again."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        [_activityIndicator stopAnimating];
    }
    else
    {
        
        id deserializedJSON = [NSJSONSerialization JSONObjectWithData:data
                                                              options:NSJSONReadingAllowFragments
                                                                error:&deserializeError];
        
        if (deserializeError)
        {
            NSLog(@"Failed deserializing content provider config data: %@", deserializeError);
        }
        else if (![deserializedJSON isKindOfClass:[NSDictionary class]])
        {
            NSLog(@"Unexpected format for deserialized content provider config data.");
        }
        else
        {
            contentProviderConfig = (NSDictionary *)deserializedJSON;
        }
        
        NSString *pathToPubkey = [contentProviderConfig objectForKey:@"pubKeyPath"];
        NSString *pathToZBiMConfig = [contentProviderConfig objectForKey:@"zbimConfigPath"];
        
        dispatch_group_t group = dispatch_group_create();
        dispatch_group_enter(group);
        
        NSURLSessionDownloadTask *pubKeyDownloadTask =
        [_defaultSession downloadTaskWithURL:[NSURL URLWithString:pathToPubkey]
           completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
               if (error)
               {
                   NSLog(@"Failed downloading file containing public key (url: %@). Error: %@", pathToPubkey, error);
               }
               else
               {
                   NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                   NSString *libraryDirectory = [paths objectAtIndex:0];
                   _pubKeyPath = [libraryDirectory stringByAppendingPathComponent:PubKeyOverrideFileName];
                   NSError *fileManagerError = nil;
                   
                   NSFileManager *fileManager = [NSFileManager defaultManager];
                   if ([fileManager fileExistsAtPath:_pubKeyPath])
                   {
                       if (![fileManager removeItemAtPath:_pubKeyPath error:&fileManagerError])
                       {
                           NSLog(@"Failed removing previously downloaded public key file. Error: %@", fileManagerError);
                       }
                   }
                   
                   fileManagerError = nil;
                   
                   if (![[NSFileManager defaultManager] moveItemAtPath:[location path] toPath:_pubKeyPath error:&fileManagerError])
                   {
                       NSLog(@"Failed moving file containing public key from temporary download location. Error: %@", fileManagerError);
                   }
                   else
                   {
                       retrievedPublicKeyFile = YES;
                   }
               }
               
               dispatch_group_leave(group);
           }];
        
        [pubKeyDownloadTask resume];
        
        dispatch_group_enter(group);
        
        NSURLSessionDownloadTask *zbimConfigDownloadTask =
        [_defaultSession downloadTaskWithURL:[NSURL URLWithString:pathToZBiMConfig]
           completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
               if (error)
               {
                   NSLog(@"Failed downloading file containing ZBiM config data (url: %@). Error: %@", pathToZBiMConfig, error);
               }
               else
               {
                   NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                   NSString *libraryDirectory = [paths objectAtIndex:0];
                   _zbimConfigPath = [libraryDirectory stringByAppendingPathComponent:ZBiMConfigOverrideFileName];
                   NSError *fileManagerError = nil;
                   
                   NSFileManager *fileManager = [NSFileManager defaultManager];
                   
                   if ([fileManager fileExistsAtPath:_zbimConfigPath])
                   {
                       if (![fileManager removeItemAtPath:_zbimConfigPath error:&fileManagerError])
                       {
                           NSLog(@"Failed removing previously downloaded ZBiM config file. Error: %@", fileManagerError);
                       }
                   }
                   
                   fileManagerError = nil;
                   
                   if (![fileManager moveItemAtPath:[location path] toPath:_zbimConfigPath error:&fileManagerError])
                   {
                       NSLog(@"Failed moving file containing ZBiM config from temporary download location. Error: %@", fileManagerError);
                   }
                   else
                   {
                       retrievedZBiMConfigFile = YES;
                   }
               }
               
               dispatch_group_leave(group);
           }];
        [zbimConfigDownloadTask resume];
        
        dispatch_group_notify(group, dispatch_get_main_queue(), ^
          {
              [_activityIndicator stopAnimating];
              
              if (retrievedPublicKeyFile && retrievedZBiMConfigFile)
              {
                  NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
                  [standardUserDefaults setObject:PubKeyOverrideFileName forKey:PubKeyOverrideSettingKey];
                  [standardUserDefaults setObject:ZBiMConfigOverrideFileName forKey:ZBiMConfigOverrideSettingKey];
                  [standardUserDefaults synchronize];
                  
                  [self presentMainViewController];
              }
              else
              {
                  [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed retrieving one or more configuration entries. Please ensure you have the correct URL and a working Internet connection."
                                             delegate:nil
                                    cancelButtonTitle:@"OK"
                                    otherButtonTitles:nil] show];
              }
          });
    }
}

- (void)presentMainViewController
{
    ZBiMViewController *zbimViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ZBiMViewController"];
    
    [zbimViewController.navigationItem setHidesBackButton:YES animated:NO];
    
    [self.navigationController completionhandler_pushViewController:zbimViewController animated:YES completion:^(){
        ZBiMAppDelegate *appDelegate = (ZBiMAppDelegate *)[UIApplication sharedApplication].delegate;
        appDelegate.viewController = zbimViewController;
        [appDelegate initializeZBiMSDK:nil];
    }];
}

#pragma mark UITextFieldDelegate

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [self.configURLTextField resignFirstResponder];
    return YES;
}
@end
