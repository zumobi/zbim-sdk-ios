//
//  ZBiMViewController.h
//  ZBiMSampleApp
//
//  Created by George Tonev on 4/8/14.
//  Copyright (c) 2014 Zumobi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBiM.h"

@interface ZBiMViewController : UIViewController<UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, weak) IBOutlet UIButton *showContentHubButton;
@property (nonatomic, weak) IBOutlet UISegmentedControl *screenModePicker;
@property (nonatomic, weak) IBOutlet UISegmentedControl *colorSchemePicker;
@property (nonatomic, weak) IBOutlet UISegmentedControl *syncModePicker;
@property (nonatomic, weak) IBOutlet UIProgressView *progressView;
@property (nonatomic, weak) IBOutlet UIButton *switchUserButton;
@property (nonatomic, weak) IBOutlet UIPickerView *switchUserPickerView;
@property (nonatomic, weak) IBOutlet UIView *switchUserPickerContainerView;

- (IBAction)showContentHubButtonPressed:(id)sender;
- (IBAction)createNewUserPressed:(id)sender;
- (IBAction)switchUser:(id)sender;
- (IBAction)forceDBRefresh:(id)sender;
- (IBAction)pickerSelectionDone:(id)sender;
- (IBAction)pickerSelectionCancelled:(id)sender;
@end
