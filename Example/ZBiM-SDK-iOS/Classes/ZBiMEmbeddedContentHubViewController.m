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

#import "ZBiMEmbeddedContentHubViewController.h"
#import "SampleAppUtilities.h"
#import "ZBiM.h"

@interface ZBiMEmbeddedContentHubViewController ()

@property (nonatomic, assign) CGFloat scaleFactor;

@property (nonatomic, strong) NSString *uriToLoad;
@property (nonatomic, strong) id<ZBiMContentHubDelegate> contentHub;

@end

@implementation ZBiMEmbeddedContentHubViewController

- (void)setUri:(NSString *)uriToLoad
{
    self.uriToLoad = uriToLoad;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.contentHub = [ZBiM presentHubWithUri:self.uriToLoad
                                   parentView:self.contentHubContainerView
                         parentViewController:self
                                   completion:^(BOOL success, NSError *error) {
                                       if (!success)
                                       {
                                           NSLog(@"Failed presenting an embedded content hub with URI override. Error: %@", error);
                                       }
                                   }];
    
    self.contentHubContainerView.layer.borderWidth = 1.0f;
    self.contentHubContainerView.layer.borderColor = [UIColor colorWithRed:85.0f/255.0 green:153.0f/255.0f blue:162.0f/255.0f alpha:1.0f].CGColor;
    
    self.scaleFactor = [SampleAppUtilities scaleFactor];
    
    [self updateButton];
}

// For information about this method look at ZBiMViewController
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
    CGFloat newScaleFactor = [SampleAppUtilities newScaleFactor:self.traitCollection];
    
    if (newScaleFactor != self.scaleFactor)
    {
        self.scaleFactor = newScaleFactor;
        [self updateButton];
    }
}

-(void)updateButton {
    [SampleAppUtilities setUpButton:self.backButton :self.scaleFactor];
}

-(IBAction)backButtonPressed:(id)sender
{
    NSError *error = nil;
    
    if (![self.contentHub dismiss:&error])
    {
        NSLog(@"Failed dismissing embedded Content Hub. Error: %@", error);
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
