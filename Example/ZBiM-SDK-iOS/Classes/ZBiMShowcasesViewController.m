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

#import "ZBiMShowcasesViewController.h"
#import "SampleAppUtilities.h"

NSString * const deepLinkingURL = @"https://cdn.microsites.partnersite.mobi/sampleapp/index.html";

@interface ZBiMShowcasesViewController ()

@property (nonatomic, assign) CGFloat scaleFactor;
@property (nonatomic, strong) UIFont *regularFont;
@property (nonatomic, strong) UIFont *largeFont;

@end

@implementation ZBiMShowcasesViewController

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
    self.largeFont = [SampleAppUtilities largeFontWithScale:self.scaleFactor];
    
    [SampleAppUtilities setUpButton:self.seeAnExampleButton :self.scaleFactor];
    
    self.deepLinkingExampleLabel.font = self.largeFont;
    self.descriptionLabel.font = self.regularFont;
}

- (IBAction)seeAnExampleButtonPressed:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:deepLinkingURL]];
}

@end
