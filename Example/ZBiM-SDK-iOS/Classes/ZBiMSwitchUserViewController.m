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

#import "ZBiMSwitchUserViewController.h"
#import "ZBiM.h"
#import "SampleAppUtilities.h"

@interface ZBiMSwitchUserViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign) CGFloat scaleFactor;
@property (nonatomic, strong) UIFont *regularFont;

@end

@implementation ZBiMSwitchUserViewController 

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    
    self.switchUserProfileLabel.font = self.regularFont;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        return 70;
    }
    else
    {
        return 35;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [ZBiM getAllUsers].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SwitchUserTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        cell.textLabel.text = [ZBiM getAllUsers][indexPath.row];
        cell.textLabel.font = self.regularFont;
        cell.textLabel.textColor = [UIColor colorWithRed:62.0/255.0 green:65.0/255.0 blue:64.0/255.0 alpha:1.0];
    }
    
    if ([[ZBiM getAllUsers][indexPath.row] isEqualToString:[ZBiM activeUser]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [ZBiM setActiveUser:[tableView cellForRowAtIndexPath:indexPath].textLabel.text error:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
