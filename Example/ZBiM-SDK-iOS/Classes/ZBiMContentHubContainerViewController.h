//
//  ZBiMContentHubContainerViewController.h
//  ZBiMSampleApp
//
//  Created by George Tonev on 6/12/14.
//  Copyright (c) 2014 Zumobi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZBiMContentHubContainerViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIView *contentHubContainerView;
@property (nonatomic, weak) IBOutlet UIButton *closeButton;
@property (nonatomic, weak) IBOutlet UIButton *backButton;

- (IBAction)backButtonPressed:(id)sender;
- (IBAction)closeButtonPressed:(id)sender;

@end
