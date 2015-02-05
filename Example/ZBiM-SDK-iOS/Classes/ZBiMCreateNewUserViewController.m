//
//  ZBiMCreateNewUserViewController.m
//  ZBiMSampleApp
//
//  Created by George Tonev on 6/16/14.
//  Copyright (c) 2014 Zumobi. All rights reserved.
//

#import "ZBiMCreateNewUserViewController.h"
#import "ZBiM.h"

@implementation ZBiMCreateNewUserViewController
{
    NSMutableDictionary *_tagSelection;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.userNameTextField.text = [ZBiM generateDefaultUserId];
    self.createUserButton.layer.borderWidth = 1.0f;
    self.createUserButton.layer.cornerRadius = 10.0f;
    self.createUserButton.layer.borderColor = [UIColor colorWithRed:228.0f/255.0 green:89.0f/255.0f blue:37.0f / 255.0f alpha:1.0f].CGColor;
    
    self.cancelButton.layer.borderWidth = 1.0f;
    self.cancelButton.layer.cornerRadius = 10.0f;
    self.cancelButton.layer.borderColor = [UIColor colorWithRed:228.0f/255.0 green:89.0f/255.0f blue:37.0f / 255.0f alpha:1.0f].CGColor;
}

- (void)showAvailableTags:(NSArray *)tags
{
    NSAssert(!_tagSelection, @"Resetting list of applicable tags is not supported.");
    
    _tagSelection = [NSMutableDictionary dictionary];
    
    NSUInteger tagIndex = 0;
    for (NSString *tag in tags)
    {
        NSAssert(46 * tagIndex < self.view.frame.size.height - 31,
                 @"Trying to display more tags than would fit on screen. Please limit number of tags.");

        UISwitch *checkbox = [[UISwitch alloc] initWithFrame:CGRectMake(25.0f, 46.0f * tagIndex, 51.0f, 31.0f)];
        checkbox.onTintColor = [UIColor colorWithRed:228.0f/255.0 green:89.0f/255.0f blue:37.0f / 255.0f alpha:1.0f];
        [self.checkboxesContainer addSubview:checkbox];
        
        UILabel *tagName = [[UILabel alloc] initWithFrame:CGRectMake(85.0f, 46.0f * tagIndex, 150.0f, 31.0f)];
        tagName.textColor = [UIColor blackColor];
        tagName.text = tag;
        [self.checkboxesContainer addSubview:tagName];
    
        [_tagSelection setObject:checkbox forKey:tag];

        tagIndex++;
    }
    
    self.checkboxesContainer.contentSize = CGSizeMake(self.checkboxesContainer.frame.size.width, 46.0f * tagIndex);
}

- (IBAction)createNewUserButtonPressed:(id)sender
{
    NSError *error = nil;
    
    NSMutableArray *tags = [NSMutableArray array];
    
    for (NSString *tag in _tagSelection) {
        if ([(UISwitch *)_tagSelection[tag] isOn])
        {
            [tags addObject:tag];
        }
    }
    
    // App can provide a user id that makes sense in its context
    // or it can pass nil and have ZBiM SDK generate one on the
    // app's behlaf (or use a previously generated one).
    NSString *userId = self.userNameTextField.text;
    if (![ZBiM createUser:userId withTags:tags error:&error])
    {
        if (error.code != ZBiMErrorUserAlreadyExists)
        {
            NSLog(@"Failed creating user with tags: %@", error);
            return;
        }
    }
    
    if (![ZBiM setActiveUser:userId error:&error])
    {
        NSLog(@"Failed setting active user: %@", error);
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancelButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)editingEnded:(id)sender
{
    [self.userNameTextField resignFirstResponder];
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
