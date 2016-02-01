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

#import "SampleAppUtilities.h"

CGFloat smallFontSize = 12.0f;
CGFloat regularFontSize = 15.0f;
CGFloat largeFontSize = 20.0f;

@implementation SampleAppUtilities

+ (CGFloat)scaleFactor
{
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        return 2.0f;
    }
    else
    {
        return 1.0f;
    }
}

+ (CGFloat)newScaleFactor:(UITraitCollection*)traitCollection {
    CGFloat newScaleFactor = 1.0f;
    if (traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular &&
        traitCollection.verticalSizeClass == UIUserInterfaceSizeClassRegular)
    {
        newScaleFactor = 2.0f;
    }
    return newScaleFactor;
}

+ (UIFont*)smallFontWithScale:(CGFloat)scaleFactor
{
    return [UIFont fontWithName:@"BrandonGrotesque-Medium" size:smallFontSize * scaleFactor];
}

+ (UIFont*)regularFontWithScale:(CGFloat)scaleFactor
{
    return [UIFont fontWithName:@"BrandonGrotesque-Medium" size:regularFontSize * scaleFactor];
}

+ (UIFont*)largeFontWithScale:(CGFloat)scaleFactor
{
    return [UIFont fontWithName:@"BrandonGrotesque-Medium" size:largeFontSize * scaleFactor];
}

+ (void)setUpButton:(UIButton*)button :(CGFloat)scaleFactor
{
    button.layer.borderWidth = 1.0f;
    button.layer.cornerRadius = 4.0f;
    button.layer.borderColor = [UIColor colorWithRed:85.0f/255.0 green:153.0f/255.0f blue:162.0f/255.0f alpha:1.0f].CGColor;
    button.titleLabel.font = [UIFont fontWithName:@"BrandonGrotesque-Medium" size:regularFontSize * scaleFactor];
}

@end
