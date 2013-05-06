//
// MIRegularTransaction.m
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

#import "MIRegularTransaction.h"
#import "MIRegularTransaction+Protected.h"

#import "MIMapView+MITransaction.h"
#import "MITransaction+Subclass.h"
#import "MITypes.h"

const NSTimeInterval _MIRegularTransactionDuration = 0.2;

@implementation MIRegularTransaction

#pragma mark - Invocation

- (void)perform
{
	if (self.target.count > 0)
	{
		[self addAnnotations:self.target];
	}
	else if (self.source.count > 0)
	{
		[self performRemoveAnimation];
	}
}

- (void)mapView:(MIMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
	MIAssert1(views.count > 0, @"%p: Empty views array", (__bridge void *)self);

	[self performRemoveAnimation];
	[self performAddAnimation:views];
}

@end

@implementation MIRegularTransaction (Protected)

- (void)performRemoveAnimation
{
	NSMutableArray *views = [[NSMutableArray alloc] initWithCapacity:self.source.count];
	for (id <MKAnnotation> annotation in self.source)
	{
		MKAnnotationView *view = [self.mapView viewForAnnotation:annotation];
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

	[UIView animateWithDuration:_MIRegularTransactionDuration animations:^
	{
		[views makeObjectsPerformSelector:@selector(setAlpha:) withObject:nil];

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

- (void)performAddAnimation:(NSArray *)views
{
	[self lock];

	[views makeObjectsPerformSelector:@selector(setAlpha:) withObject:nil];

	[UIView animateWithDuration:_MIRegularTransactionDuration animations:^
	{
		for (MKAnnotationView *view in views)
		{
			[view setAlpha:1.f];
		}

	} completion:^(BOOL finished)
	{
		[self unlock];
	}];
}

@end