/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2014-2015 Zumobi Inc.
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
#import "ZBiMCreateNewUserViewController.h"
#import "ZBiMAppDelegate.h"

static NSArray *allTags;

@implementation ZBiMViewController
{
    NSArray *_allUsers;
    NSString *_pickerSelection;
}

+(void)initialize
{
    // IMPORTANT: Change the following tag array to reflect the set of
    // tags used by the Content Hub that this sample app is going to host.
    // Otherwise content tailoring will not work properly. 
    allTags = [NSArray arrayWithObjects:@"tag1", @"tag2", @"tag3", nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dbDownloadProgressChanged:) name:ZBiMDBDownloadProgressChanged object:nil];
    
    self.progressView.progress = 0.0f;
    
    self.showContentHubButton.layer.borderWidth = 1.0f;
    self.showContentHubButton.layer.cornerRadius = 10.0f;
    self.showContentHubButton.layer.borderColor = [UIColor colorWithRed:228.0f/255.0 green:89.0f/255.0f blue:37.0f / 255.0f alpha:1.0f].CGColor;
    
    self.switchUserPickerContainerView.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    _allUsers = [ZBiM getAllUsers];
}

- (IBAction)showContentHubButtonPressed:(id)sender
{
    if (![ZBiM activeUser])
    {
        UIAlertView *activeUserNotSetAlertView = [[UIAlertView alloc] initWithTitle:@"Cannot Show Content Hub" message:@"You first need to create a new user." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [activeUserNotSetAlertView show];
        return;
    }

    if (self.syncModePicker.selectedSegmentIndex == 0)
    {
        [ZBiM setSyncMode:ZBiMSyncNonBlocking];
    }
    else
    {
        [ZBiM setSyncMode:ZBiMSyncBlocking];
    }
    
    if (self.colorSchemePicker.selectedSegmentIndex == 0)
    {
        [ZBiM setColorScheme:ZBiMColorSchemeDark];
    }
    else
    {
        [ZBiM setColorScheme:ZBiMColorSchemeLight];
    }
    
    if (self.screenModePicker.selectedSegmentIndex == 0)
    {
        [ZBiM presentHubWithTags:nil completion:^(BOOL success, NSError *error) {
            if (!success)
            {
                NSLog(@"Failed presenting content hub. Error: %@", error);
            }
        }];
    }
    else
    {
        ZBiMContentHubContainerViewController *contentHubContainer = [[ZBiMContentHubContainerViewController alloc] initWithNibName:@"ZBiMContentHubContainerViewController" bundle:nil];
        [self presentViewController:contentHubContainer animated:YES completion:nil];
    }
}

- (IBAction)createNewUserPressed:(id)sender
{
    ZBiMCreateNewUserViewController *createNewUserViewController = [[ZBiMCreateNewUserViewController alloc] initWithNibName:@"ZBiMCreateNewUserViewController" bundle:nil];
    [self presentViewController:createNewUserViewController animated:YES completion:nil];
    [createNewUserViewController showAvailableTags:allTags];
}

- (IBAction)switchUser:(id)sender
{
    if (!_allUsers || _allUsers.count < 2)
    {
        UIAlertView *activeUserNotSetAlertView = [[UIAlertView alloc] initWithTitle:@"Cannot Switch User" message:@"You must create at least two users to be able to switch." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [activeUserNotSetAlertView show];
        return;
    }
    
    [self.switchUserPickerView reloadAllComponents];
    self.switchUserPickerContainerView.hidden = NO;

    // Make the picker have the current active user (if set)
    // as the selected item.
    _pickerSelection = [ZBiM activeUser];
    if (_pickerSelection)
    {
        [self.switchUserPickerView selectRow:[_allUsers indexOfObject:_pickerSelection]
                                 inComponent:0
                                    animated:YES];
    }
    else
    {
        _pickerSelection = [_allUsers objectAtIndex:0];
        [self.switchUserPickerView selectRow:0
                                 inComponent:0
                                    animated:YES];
    }
}

- (IBAction)forceDBRefresh:(id)sender
{
    [ZBiM refreshContentSource];
}

- (void)dbDownloadProgressChanged:(NSNotification *)notification
{
    self.progressView.progress = [notification.userInfo[@"progress"] floatValue] / 100.0f;
}

- (IBAction)pickerSelectionDone:(id)sender
{
    [ZBiM setActiveUser:_pickerSelection error:nil];
    self.switchUserPickerContainerView.hidden = YES;
}

- (IBAction)pickerSelectionCancelled:(id)sender
{
    _pickerSelection = nil;
    self.switchUserPickerContainerView.hidden = YES;
}

#pragma mark UIPickerViewDataSource

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _allUsers.count;
}

#pragma mark UIPickerViewDelegate

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return 300.0f;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 44.0f;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (!_allUsers || row < 0 || row >= _allUsers.count)
    {
        return nil;
    }
    
    return [_allUsers objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    _pickerSelection = [_allUsers objectAtIndex:row];
}

#pragma mark Orientation related methods

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
