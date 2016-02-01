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

#import "ZBiMUserManagementViewController.h"
#import "ZBiMSwitchUserViewController.h"
#import "ZBiMCreateNewUserViewController.h"
#import "ZBiMUserManagementTableViewCell.h"
#import "ZBiM.h"
#import "SampleAppUtilities.h"

static NSString * const TableViewCellIdentifier = @"ZBiMUserManagementTableViewCell";
static NSArray * allowedTagsArray;

@interface ZBiMUserManagementViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign) CGFloat scaleFactor;
@property (nonatomic, strong) UIFont *regularFont;
@property (nonatomic, strong) UIFont *smallFont;

@end

@implementation ZBiMUserManagementViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UINib *nib = [UINib nibWithNibName:@"ZBiMUserManagementTableViewCell" bundle:nil];
    [self.tagsListTableView registerNib:nib forCellReuseIdentifier:@"ZBiMUserManagementTableViewCell"];
    
    allowedTagsArray = [NSArray arrayWithObjects:@"Food", @"Italian", @"Mexican", @"Thai", @"Seafood", @"Sushi", @"Activity", @"Inside", @"Outside", @"Art", @"Pool", @"Shuffleboard", @"Darts", @"Bowling", @"Bocci", @"Drinks", @"Wine", @"Beer", @"Cocktails", @"Whiskey", nil];
    
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
    self.smallFont = [SampleAppUtilities smallFontWithScale:self.scaleFactor];
    self.regularFont = [SampleAppUtilities regularFontWithScale:self.scaleFactor];
    
    [SampleAppUtilities setUpButton:self.switchUserButton :self.scaleFactor];
    [SampleAppUtilities setUpButton:self.createNewUserButton :self.scaleFactor];
    
    self.tagInfoLabel.font = self.smallFont;
    self.userNameLabel.font = self.regularFont;
}

-(void)viewWillAppear:(BOOL)animated
{
    self.userNameLabel.text = [ZBiM activeUser];
    [self.tagsListTableView reloadData];
}

- (IBAction)switchUserPressed:(id)sender
{
    ZBiMSwitchUserViewController *switchUserViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ZBiMSwitchUserViewController"];
    
    [switchUserViewController.navigationItem setHidesBackButton:YES animated:NO];
    
    [self.navigationController pushViewController:switchUserViewController animated:NO];
}

- (IBAction)createNewUserPressed:(id)sender
{
    ZBiMCreateNewUserViewController *createNewUserViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ZBiMCreateNewUserViewController"];
    
    [createNewUserViewController.navigationItem setHidesBackButton:YES animated:NO];
    
    [self.navigationController pushViewController:createNewUserViewController animated:NO];
}

#pragma mark UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f * self.scaleFactor;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return allowedTagsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZBiMUserManagementTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TableViewCellIdentifier];
    
    cell.tagName.font = self.regularFont;
    cell.tagWeight.font = self.regularFont;
    cell.tagName.text = allowedTagsArray[indexPath.row];
    
    NSError *error = nil;
    NSDictionary *tagDictionary = [ZBiM tagUsageCountsForUser:[ZBiM activeUser] error:&error];
    if (!tagDictionary)
    {
        NSLog(@"Failed getting weight for tag (%@). Error: %@", cell.tagName.text, error);
    }
    
    if (!tagDictionary || ![tagDictionary objectForKey:allowedTagsArray[indexPath.row]])
    {
        cell.tagWeight.text = [NSString stringWithFormat:@"%d", 0];
    }
    else
    {
        cell.tagWeight.text = [NSString stringWithFormat:@"%ld", (long) [[tagDictionary objectForKey:allowedTagsArray[indexPath.row]] integerValue]];
    }
    
    return cell;
}

@end
