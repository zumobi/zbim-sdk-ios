//
//  ZBiMContentHubContainerViewController.m
//  ZBiMSampleApp
//
//  Created by George Tonev on 6/12/14.
//  Copyright (c) 2014 Zumobi. All rights reserved.
//

#import "ZBiMContentHubContainerViewController.h"
#import "ZBiM.h"

@implementation ZBiMContentHubContainerViewController
{
    id<ZBiMContentHubDelegate> _contentHub;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _contentHub = [ZBiM presentHubWithTags:nil
                                parentView:self.contentHubContainerView
                      parentViewController:self
                                completion:^(BOOL success, NSError *error) {

        if (!success)
        {
            NSLog(@"Failed opening content hub. Error: %@", error);
        }
    }];
    
    self.contentHubContainerView.layer.borderWidth = 2.0f;
    self.contentHubContainerView.layer.borderColor = [UIColor colorWithRed:228.0f/255.0 green:89.0f/255.0f blue:37.0f / 255.0f alpha:1.0f].CGColor;
    
    self.closeButton.layer.borderWidth = 1.0f;
    self.closeButton.layer.cornerRadius = 10.0f;
    self.closeButton.layer.borderColor = [UIColor colorWithRed:228.0f/255.0 green:89.0f/255.0f blue:37.0f / 255.0f alpha:1.0f].CGColor;
    
    self.backButton.layer.borderWidth = 1.0f;
    self.backButton.layer.cornerRadius = 10.0f;
    self.backButton.layer.borderColor = [UIColor colorWithRed:228.0f/255.0 green:89.0f/255.0f blue:37.0f / 255.0f alpha:1.0f].CGColor;
    
    if ([ZBiM colorScheme] == ZBiMColorSchemeLight)
    {
        self.view.backgroundColor = [UIColor whiteColor];
    }
}

- (void)backButtonPressed:(id)sender
{
    [_contentHub goBack];
}

- (void)closeButtonPressed:(id)sender
{
    NSError *error = nil;
    if (![_contentHub dismiss:&error])
    {
        NSLog(@"Failed dismissing content hub. Error: %@", error);
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        _contentHub = nil;
    }];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

@end
