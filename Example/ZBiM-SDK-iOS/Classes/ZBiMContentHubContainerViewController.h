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

#import <UIKit/UIKit.h>
#import "ZBiM.h"

@interface ZBiMContentHubContainerViewController : UIViewController<UIScrollViewDelegate, UIWebViewDelegate, ZBiMContentHubContainerDelegate>

@property (nonatomic, weak) IBOutlet UIView *contentHubContainerView;
@property (nonatomic, weak) IBOutlet UIButton *closeButton;
@property (nonatomic, weak) IBOutlet UIButton *backButton;
@property (nonatomic, weak) IBOutlet UIView *navBar;
@property (nonatomic, weak) IBOutlet UISegmentedControl *tabPicker;
@property (nonatomic, weak) IBOutlet UIWebView *regularWebView;
@property (nonatomic, weak) IBOutlet UILabel *resourceTypeLabel;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) NSString *uriOverride;
@property (nonatomic, strong) NSArray *tagsOverride;

- (IBAction)backButtonPressed:(id)sender;
- (IBAction)closeButtonPressed:(id)sender;
- (IBAction)tabPickerSelectionChanged:(id)sender;

@end
