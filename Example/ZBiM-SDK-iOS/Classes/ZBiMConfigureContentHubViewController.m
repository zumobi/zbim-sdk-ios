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

#import "ZBiMConfigureContentHubViewController.h"
#import "ZBiMAppDelegate.h"
#import "SampleAppUtilities.h"

@interface ZBiMConfigureContentHubViewController ()

@property (nonatomic, assign) CGFloat scaleFactor;
@property (nonatomic, strong) UIFont *regularFont;
@property (nonatomic, strong) UIFont *largeFont;

@end

@implementation ZBiMConfigureContentHubViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    self.pModeSegmentControl.selectedSegmentIndex = [standardUserDefaults integerForKey:PresentationModeKey];
    self.cSchemeSegmentControl.selectedSegmentIndex = [standardUserDefaults integerForKey:ColorSchemeModeKey];
    self.nModeSegmentControl.selectedSegmentIndex = [standardUserDefaults integerForKey:NetworkModeKey];
    
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
    self.largeFont = [SampleAppUtilities largeFontWithScale:self.scaleFactor];
    
    NSDictionary *segmentAttributes = [NSDictionary dictionaryWithObject:self.regularFont forKey:NSFontAttributeName];
    [self.pModeSegmentControl setTitleTextAttributes:segmentAttributes forState:UIControlStateNormal];
    [self.cSchemeSegmentControl setTitleTextAttributes:segmentAttributes forState:UIControlStateNormal];
    [self.nModeSegmentControl setTitleTextAttributes:segmentAttributes forState:UIControlStateNormal];
    
    self.presentationModeLabel.font = self.largeFont;
    self.colorSchemesLabel.font = self.largeFont;
    self.networkModeLabel.font = self.largeFont;
}

- (IBAction)pModeSegmentChanged:(id)sender
{
    [self changeModeHelper:(int)self.pModeSegmentControl.selectedSegmentIndex :PresentationModeKey];
}

- (IBAction)cSchemeSegmentChanged:(id)sender
{
    [self changeModeHelper:(int)self.cSchemeSegmentControl.selectedSegmentIndex :ColorSchemeModeKey];
}

- (IBAction)nModeSegmentChanged:(id)sender
{
    [self changeModeHelper:(int)self.nModeSegmentControl.selectedSegmentIndex :NetworkModeKey];
}

- (void)changeModeHelper:(int)segmentIndex :(NSString*)key
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setInteger:segmentIndex forKey:key];
    [standardUserDefaults synchronize];
}

@end
