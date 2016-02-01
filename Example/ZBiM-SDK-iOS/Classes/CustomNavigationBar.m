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

#import "ZBiMAppDelegate.h"
#import "CustomNavigationBar.h"
#import "SampleAppUtilities.h"

@implementation CustomNavigationBar

- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize navigationBarSize = [super sizeThatFits:size];
    navigationBarSize.height = navigationBarSize.height * [SampleAppUtilities scaleFactor];

    return navigationBarSize;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    for (UIView *view in [self subviews])
    {
        if ([NSStringFromClass([view class]) isEqualToString:@"_UINavigationBarBackIndicatorView"])
        {
            CGRect frame = [view frame];
            view.frame = CGRectMake(frame.origin.x, frame.origin.y - (22 * ([SampleAppUtilities scaleFactor] - 1)), frame.size.width, frame.size.height);
        }
    }
}

-(UINavigationItem *)popNavigationItemAnimated:(BOOL)animated
{
    return [super popNavigationItemAnimated:NO];
}

@end
