//
// MIZoomOutTransition.m
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

#import "MIZoomOutTransition.h"
#import "MITransition+Subclass.h"

#import "MIMapView.h"
#import "MIAnnotation.h"
#import "MKAnnotationView+MIExtension.h"

const NSTimeInterval _MIZoomOutTransitionDuration = 0.2;

@implementation MIZoomOutTransition

- (void)performRemoveAnimation
{
	NSMutableArray *views = [[NSMutableArray alloc] initWithCapacity:self.source.count];
	for (id <MKAnnotation> sourceAnnotation in self.source)
	{
		MKAnnotationView *view = [self.mapView viewForAnnotation:sourceAnnotation];
		if (view != nil)
		{
			[views addObject:view];
		}
	}

	if (views.count == 0)
	{
		[self removeAnnotations:self.source];
		return;
	}

	[self lock];

    [UIView animateWithDuration:_MIZoomOutTransitionDuration animations:^
    {
        [views makeObjectsPerformSelector:@selector(setAlpha:) withObject:nil];

        for (MIAnnotation *target in self.target)
        {
            if ([target class] != [MIAnnotation class]) continue;

            for (MKAnnotationView *view in views)
            {
                if (![target contains:view.annotation]) continue;

                [view setAdjustedCenter:[self.mapView convertCoordinate:target.coordinate toPointToView:view.superview]];
            }
        }

    } completion:^(BOOL finished)
    {
        for (MKAnnotationView *view in views)
        {
            [view setAlpha:1.f];
        }

        [self removeAnnotations:self.source];
        [self unlock];
    }];
}

@end