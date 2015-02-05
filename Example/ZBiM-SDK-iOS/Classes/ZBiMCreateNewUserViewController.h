//
//  ZBiMCreateNewUserViewController.h
//  ZBiMSampleApp
//
//  Created by George Tonev on 6/16/14.
//  Copyright (c) 2014 Zumobi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZBiMCreateNewUserViewController : UIViewController

@property (nonatomic, weak) IBOutlet UITextField *userNameTextField;
@property (nonatomic, weak) IBOutlet UIScrollView *checkboxesContainer;
@property (nonatomic, weak) IBOutlet UIButton *createUserButton;
@property (nonatomic, weak) IBOutlet UIButton *cancelButton;

- (IBAction)createNewUserButtonPressed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)editingEnded:(id)sender;

- (void)showAvailableTags:(NSArray *)tags;

@end
