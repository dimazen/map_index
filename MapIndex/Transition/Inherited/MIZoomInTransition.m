//
// MIZoomInTransition.m
//
// Copyright (c) 2013 Shemet Dmitriy
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "MIZoomInTransition.h"
#import "MITransition+Subclass.h"

#import "MIMapView.h"
#import "MIAnnotation.h"
#import "MKAnnotationView+MIExtension.h"

const NSTimeInterval _MIZoomInTransitionDuration = 0.2;

@implementation MIZoomInTransition

#pragma mark - Animation

- (void)performAddAnimation:(NSArray *)views
{
	[self lock];

	for (MKAnnotationView *view in views)
	{
		[view setAlpha:0.f];

		for (MIAnnotation *source in self.source)
		{
			if (!([source class] == [MIAnnotation class] && [source contains:view.annotation])) continue;

			[view setAdjustedCenter:[self.mapView convertCoordinate:source.coordinate toPointToView:view.superview]];
		}
	}

    [UIView animateWithDuration:_MIZoomInTransitionDuration animations:^
    {
        for (MKAnnotationView *view in views)
        {
            [view setAdjustedCenter:[self.mapView convertCoordinate:view.annotation.coordinate
                                                      toPointToView:view.superview]];
            [view setAlpha:1.f];
        }

    } completion:^(BOOL finished)
    {
        [self unlock];
    }];
}

@end