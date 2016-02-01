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
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR  THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "ZBiMContentHubContainerViewController.h"
#import "SampleAppUtilities.h"
#import "ZBiM.h"

@interface ZBiMContentHubContainerViewController ()

@property (nonatomic, assign) CGFloat scaleFactor;
@property (nonatomic, strong) UIFont *smallFont;
@property (nonatomic, strong) UIFont *regularFont;

@end

@implementation ZBiMContentHubContainerViewController
{
    id<ZBiMContentHubDelegate> _contentHub;
    float _lastContentOffsetY;
    NSMutableArray *_navBarConstraints;
    BOOL _togglingOverlay;
    BOOL _mustRestoreStatusBarVisibility;
    BOOL _scrollingDown;
    NSString *_navBarHiddenVConstraint;
    BOOL _contentHubShowingDetailsPage;
}

NSString * const _navBarVisibleVConstraint = @"V:|-0-[_navBar]";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_navBar);
    _navBarConstraints = [NSMutableArray arrayWithArray: [NSLayoutConstraint constraintsWithVisualFormat:_navBarVisibleVConstraint
                                                                                                 options:0
                                                                                                 metrics:nil
                                                                                                   views:views]];
    
    [self.navBar.superview addConstraints:_navBarConstraints];

    if (self.uriOverride)
    {
        _contentHub = [ZBiM presentHubWithUri:self.uriOverride
                                   parentView:self.contentHubContainerView
                         parentViewController:self
                                   completion:^(BOOL success, NSError *error) {
                                       if (!success)
                                       {
                                           NSLog(@"Failed presenting an embedded content hub with URI override. Error: %@", error);
                                       }
                                   }];
    }
    else if (self.tagsOverride)
    {
        _contentHub = [ZBiM presentHubWithTags:self.tagsOverride
                                    parentView:self.contentHubContainerView
                          parentViewController:self
                                    completion:^(BOOL success, NSError *error) {
                                        if (!success)
                                        {
                                            NSLog(@"Failed presenting an embedded content hub with tags override. Error: %@", error);
                                        }
                                    }];
    }
    else
    {
        _contentHub = [ZBiM presentHubWithParentView:self.contentHubContainerView
                                parentViewController:self
                                          completion:^(BOOL success, NSError *error) {
                                              if (!success)
                                              {
                                                  NSLog(@"Failed presenting an embedded content hub. Error: %@", error);
                                              }
                                          }];
    }

    [_contentHub setScrollDelegate:self];
    
    if ([ZBiM colorScheme] == ZBiMColorSchemeLight)
    {
        self.view.backgroundColor = [UIColor whiteColor];
        self.navBar.backgroundColor = [UIColor whiteColor];
    }
    
    // By default we show the Content Hub
    self.regularWebView.hidden = YES;
    
    // Sign up to receive a notification when the Content Hub
    // loads a different piece of content, e.g. hub, channel or
    // article. This can be useful in the case where Content Hub
    // is presented in an embedded mode and the application needs
    // to adjust the parent view, e.g. hide a nav bar when showing
    // hub, but show it when article gets loaded.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleContentTypeChanged:) name:ZBiMContentTypeChanged object:[ZBiM class]];
    
    self.scaleFactor = [SampleAppUtilities scaleFactor];
    
    [self updateFonts];
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
    self.smallFont = [SampleAppUtilities smallFontWithScale:self.scaleFactor];
    
    [SampleAppUtilities setUpButton:self.closeButton :self.scaleFactor];
    [SampleAppUtilities setUpButton:self.backButton :self.scaleFactor];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:self.regularFont forKey:NSFontAttributeName];
    [self.tabPicker setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [self.tabPicker setContentPositionAdjustment:UIOffsetMake(0, 2) forSegmentType:UISegmentedControlSegmentAny barMetrics:UIBarMetricsDefault];
    
    self.contentHubContainerView.layer.borderWidth = 1.0f;
    self.contentHubContainerView.layer.borderColor = [UIColor colorWithRed:85.0f/255.0 green:153.0f/255.0f blue:162.0f/255.0f alpha:1.0f].CGColor;
    self.resourceTypeLabel.font = self.smallFont;
    self.titleLabel.font = self.smallFont;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // If status bar is not hidden already, make a not that it was
    // visible upon navigating to view (so its visibility can be
    // restored upon navigating away from view) and hide it.
    if (![[UIApplication sharedApplication] isStatusBarHidden])
    {
        _mustRestoreStatusBarVisibility = YES;
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Restore status bar's visibility in case it was hidden
    // upon view appearing on screen.
    if (_mustRestoreStatusBarVisibility)
    {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        _mustRestoreStatusBarVisibility = NO;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _navBarHiddenVConstraint = [NSString stringWithFormat:@"V:|-(-%d)-[_navBar]", (int)_navBar.frame.size.height];
}

- (BOOL) prefersStatusBarHidden
{
    return YES;
}

- (void)backButtonPressed:(id)sender
{
    // Back button pressed. Route the action as appropriate,
    // depending on whether Content Hub or Regular Web View
    // is currently being presented.
    if (self.tabPicker.selectedSegmentIndex == 0)
    {
        // Showing Content Hub
        [_contentHub goBack];
    }
    else
    {
        // Showing regualr web view
        [self.regularWebView goBack];
    }
}

- (void)closeButtonPressed:(id)sender
{
    // Close button pressed. Start by dismissing the container view.
    [self dismissViewControllerAnimated:YES completion:^{
        // Only the Content Hub mode requires special cleanup action.
        if (self.tabPicker.selectedSegmentIndex == 0)
        {
            // Showing Content Hub
            NSError *error = nil;
            if (![_contentHub dismiss:&error])
            {
                NSLog(@"Failed dismissing content hub. Error: %@", error);
            }
        }
    }];
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

- (void)handleContentTypeChanged:(NSNotification *)notification
{
    NSLog(@"New content presented. URL: %@, title: %@, type: %@", notification.userInfo[ZBiMResourceURL], notification.userInfo[ZBiMResourceTitle], notification.userInfo[ZBiMResourceType]);

    self.resourceTypeLabel.text = notification.userInfo[ZBiMResourceType];
    [self updateBackButton];

    NSString *title = notification.userInfo[ZBiMResourceTitle];
    if (title && title.length > 0)
    {
        self.titleLabel.text = [NSString stringWithFormat:@"%@", title];
    }
    else
    {
        self.titleLabel.text = nil;
    }
    
    if ([notification.userInfo[ZBiMResourceType] isEqualToString:ZBiMResourceTypeArticle])
    {
        _contentHubShowingDetailsPage = YES;
        
        if (![NSThread isMainThread])
        {
            dispatch_async(dispatch_get_main_queue(), ^
            {
                [self showNavBar];
            });
        }
        else
        {
            [self showNavBar];
        }
        return;
    }
    
    if (_contentHubShowingDetailsPage)
    {
        _scrollingDown = NO;
    }
    
    _contentHubShowingDetailsPage = NO;
}

#pragma mark ZBiMContentHubContainerDelegate methods

// The closeContentHub method provides a way for an embedded
// Content Hub to communicate back to its parent (container)
// view controller, telling it that it needs to be dismissed.
// What that means is up to the parent view controller. Here
// we choose to dismiss the Content Hub as well as the parent
// view controller itself. Alternatively we could have dismissed
// the Content Hub, and nil the strong reference to it, but kept
// the parent view controller. Or we could have dismissed the
// Content Hub, but kept the strong reference, so it can be
// displayed again later.

- (void)closeContentHub
{
    NSError *error = nil;
    if (![_contentHub dismiss:&error])
    {
        NSLog(@"Failed dimissing Content Hub. Error: %@", error);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)updateControls {
    [self updateBackButton];
}

#pragma mark UIWebViewDelegate methods

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self updateBackButton];
}

#pragma mark UIScrollViewDelegate methods

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    BOOL userInitiatedDirectionChanged = NO;
    
    // Determine scrolling direction
    if (_lastContentOffsetY > scrollView.contentOffset.y)
    {
        // Scrolling up.
        if (_scrollingDown && scrollView.isTracking)
        {
            userInitiatedDirectionChanged = YES;
            _scrollingDown = NO;
        }
    }
    else if (_lastContentOffsetY < scrollView.contentOffset.y)
    {
        // Scrolling down.
        if (!_scrollingDown && scrollView.isTracking)
        {
            userInitiatedDirectionChanged = YES;
            _scrollingDown = YES;
        }
    }
    
    if (userInitiatedDirectionChanged)
    {
        if (_scrollingDown && !self.navBar.isHidden)
        {
            [self hideNavBar];
        }
        else if (!_scrollingDown && self.navBar.isHidden)
        {
            [self showNavBar];
        }
    }
    
    _lastContentOffsetY = (int) scrollView.contentOffset.y;
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(scrollView.contentOffset.y == 0.0f)
    {
        [self showNavBar];
    }
}

- (void) showNavBar
{
    if(!_togglingOverlay && self.navBar.frame.origin.y != 0.0f)
    {
        _togglingOverlay = YES;
        
        [self.navBar.layer removeAllAnimations];
        [self.navBar setHidden:NO];
        
        NSDictionary *views = NSDictionaryOfVariableBindings(_navBar);
        
        if (_navBarConstraints)
        {
            [self.navBar.superview removeConstraints:_navBarConstraints];
        }
        _navBarConstraints = [NSMutableArray arrayWithArray:[NSLayoutConstraint constraintsWithVisualFormat:_navBarVisibleVConstraint
                                                                                                        options:0
                                                                                                        metrics:nil
                                                                                                          views:views]];
        
        [self.navBar.superview  addConstraints:_navBarConstraints];
        
        [self.navBar setNeedsUpdateConstraints];
        
        __weak ZBiMContentHubContainerViewController *weakSelf = self;
        [UIView animateWithDuration:0.25f
                         animations:^
                         {
                             if (weakSelf)
                             {
                                 [weakSelf.view layoutIfNeeded];
                             }
                         }
                         completion:^(BOOL finished)
                         {
                             _togglingOverlay = NO;
                         }
         ];
    }
}

- (void) hideNavBar
{
    if (_contentHubShowingDetailsPage || self.tabPicker.selectedSegmentIndex > 0)
    {
        // We are either on an Aritcle (Detail) view, where we
        // want to turn off the nav bar toggle visibility animation
        // or Content Hub is not being shown at all. In either case
        // the hide nav bar animation is not applicable.
        return;
    }
    
    if (!_togglingOverlay)
    {
        _togglingOverlay = YES;
        NSDictionary *views = NSDictionaryOfVariableBindings(_navBar);
        if (_navBarConstraints)
        {
            [self.navBar.superview removeConstraints:_navBarConstraints];
        }
        
        _navBarConstraints = [NSMutableArray arrayWithArray: [NSLayoutConstraint constraintsWithVisualFormat:_navBarHiddenVConstraint
                                                                                                     options:0
                                                                                                     metrics:nil
                                                                                                       views:views]];
        
        [self.navBar.superview addConstraints:_navBarConstraints];
        [self.navBar setNeedsUpdateConstraints];
        
        __weak ZBiMContentHubContainerViewController *weakSelf = self;
        
        [UIView animateWithDuration:0.25f
                         animations:^
                         {
                             if (weakSelf)
                             {
                                 [weakSelf.view layoutIfNeeded];
                             }
                         }
                         completion:^(BOOL finished)
                         {
                             if (!weakSelf)
                             {
                                 return;
                             }
                             
                             [weakSelf.navBar setHidden:YES];
                             _togglingOverlay = NO;
                         }
         ];
    }
}

- (void)updateBackButton
{
    if (self.tabPicker.selectedSegmentIndex == 0) {
        self.backButton.enabled = _contentHub.canGoBack;
    } else {
        self.backButton.enabled = self.regularWebView.canGoBack;
    }
}

- (IBAction)tabPickerSelectionChanged:(id)sender
{
    if (self.tabPicker.selectedSegmentIndex == 0)
    {
        // User requested showing the Content Hub.
        // Start by hiding the Regular Web View, if any.
        self.regularWebView.hidden = YES;
        
        // Present the Content Hub, using the dedicated
        // public interface for presenting an already
        // existing Content Hub.
        [ZBiM presentExistingContentHub:_contentHub completion:^(BOOL success, NSError *error) {
            if (!success)
            {
                NSLog(@"Failed presenting content hub");
            }
        }];
    }
    else
    {
        [self showNavBar];
        
        NSError *error = nil;
        
        // User requested showing the Regular Web View.
        // Start by hiding the Content Hub. _contentHub
        // is a strong reference and is what's going to
        // keep the Content Hub around in memory so it
        // can be presented again in the future.
        if (![_contentHub dismiss:&error])
        {
            NSLog(@"Failed dismissing Content Hub. Error: %@", error);
        }
        
        // Create a new web view if one has not been
        // created already.
        if (!self.regularWebView.request.URL)
        {
            [self.regularWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.zumobi.com"]]];
        }
        
        // Show the web view by adding it to the view hierarchy.
        self.regularWebView.hidden = NO;
    }
    
    [self updateBackButton];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
