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

#import "ZBiMCreateNewUserViewController.h"
#import "ZBiMAppDelegate.h"
#import "ZBiM.h"
#import "SampleAppUtilities.h"

@interface ZBiMCreateNewUserViewController()

@property (nonatomic, assign) CGFloat scaleFactor;
@property (nonatomic, strong) UIFont *regularFont;

@end

@implementation ZBiMCreateNewUserViewController
{
    NSArray *array;
    NSMutableDictionary *_tagSelection;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    array = [NSArray arrayWithObjects:(@"Food"), (@"Activity"), (@"Drinks"), (@"Pool"), (@"Inside"), (@"Outside"), nil];
    
    self.scaleFactor = [SampleAppUtilities scaleFactor];
    
    [self updateFonts];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.navigationItem setHidesBackButton:NO animated:YES];
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
    
    [SampleAppUtilities setUpButton:self.createUserButton :self.scaleFactor];
    
    self.userNameDescription.font = self.regularFont;;
    self.userNameTextField.font = self.regularFont;;
    self.userNameTextField.text = [ZBiM generateDefaultUserId];
}

- (IBAction)createNewUserButtonPressed:(id)sender
{
    NSError *error = nil;
    NSMutableArray *tags = [NSMutableArray array];
    for (NSString *tag in _tagSelection)
    {
        if ([(UISwitch *)_tagSelection[tag] isOn])
        {
            [tags addObject:tag];
        }
    }
    
    // App can provide a user id that makes sense in its context
    // or it can pass nil and have ZBiM SDK generate one on the
    // app's behlaf (or use a previously generated one).
    NSString *userId = self.userNameTextField.text;
    if (![ZBiM createUser:userId withTags:@[] error:&error])
    {
        if (error.code == ZBiMErrorUserAlreadyExists)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Username Already Exists"
                                                            message:@"Would you like to switch to the pre-existing user profile?"
                                                           delegate:self
                                                  cancelButtonTitle:@"Yes"
                                                  otherButtonTitles:@"No", nil];
            [alert show];
        }
        else
        {
            NSLog(@"Failed creating user with tags: %@", error);
        }
        return;
    }
    
    if (![ZBiM setActiveUser:userId error:&error])
    {
        NSLog(@"Failed setting active user: %@", error);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
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

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

#pragma Mark UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        NSError *error = nil;
        NSString *userId = self.userNameTextField.text;
        if (![ZBiM setActiveUser:userId error:&error])
        {
            NSLog(@"Failed setting active user: %@", error);
        }
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
