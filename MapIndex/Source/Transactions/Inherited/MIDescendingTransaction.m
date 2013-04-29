//
// Created by dmitriy on 26.03.13.
//

#import "MIDescendingTransaction.h"
#import "MIMapView.h"
#import "MITransaction+Subclass.h"

const NSTimeInterval _SDDescendingMapTransactionDuration = 0.2;

@implementation MIDescendingTransaction

- (void)perform
{
	[self addAnnotations:self.target];
}

- (void)mapView:(MIMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
	[self lock];

	NSMutableArray *removingViews = [[NSMutableArray alloc] initWithCapacity:self.source.count];
	for (id <MKAnnotation> annotation in self.source)
	{
		UIView *view = [mapView viewForAnnotation:annotation];
		if (view != nil)
		{
			[removingViews addObject:view];
		}
	}

	[views makeObjectsPerformSelector:@selector(setAlpha:) withObject:nil];

	[UIView animateWithDuration:_SDDescendingMapTransactionDuration animations:^
	{
		[removingViews makeObjectsPerformSelector:@selector(setAlpha:) withObject:nil];

		[views enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop)
		{
			[view setAlpha:1.f];
		}];

	} completion:^(BOOL finished)
	{
		for (UIView *view in removingViews)
		{
			[view setAlpha:1.f];
		}

		[self removeAnnotations:self.source];
		[self unlock];
	}];
}

@end