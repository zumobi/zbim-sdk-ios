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

#import "ZBiMProductPageViewController.h"
#import "SampleAppUtilities.h"

@interface ZBiMProductPageViewController ()

@property (nonatomic, assign) CGFloat scaleFactor;
@property (nonatomic, strong) UIFont *regularFont;

@end

@implementation ZBiMProductPageViewController
{
    NSURL *_urlToOpen;
}

- (instancetype)initWithURL:(NSURL *) url
{
    self = [super initWithNibName:@"ZBiMProductPageViewController" bundle:nil];
    if (self)
    {
        _urlToOpen = url;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.scaleFactor = [SampleAppUtilities scaleFactor];
    
    [self updateFonts];
}

- (void)setURL:(NSURL *)url
{
    _urlToOpen = url;
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
    
    self.closeButton.titleLabel.font = self.regularFont;
    self.descriptionTextView.font = self.regularFont;
}

- (IBAction)closeButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
