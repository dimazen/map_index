//
// Created by dmitriy on 26.03.13.
//

#import "MIDescendingTransaction.h"
#import "MIMapView.h"
#import "MIMapView+MITransaction.h"

const NSTimeInterval _SDDescendingMapTransactionDuration = 0.2;

@implementation MIDescendingTransaction

- (void)invokeWithMapView:(MIMapView *)mapView
{
	[mapView transaction:self addAnnotations:[self.target allObjects]];
}

- (void)mapView:(MIMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
	[mapView lock:self];

	NSMutableSet *removingViews = [[NSMutableSet alloc] initWithCapacity:self.source.count];
	[self.source enumerateObjectsUsingBlock:^(id <MKAnnotation> obj, BOOL *stop)
	{
		UIView *view = [mapView viewForAnnotation:obj];
		if (view != nil)
		{
			[removingViews addObject:view];
		}
	}];

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
		[removingViews enumerateObjectsUsingBlock:^(UIView *view, BOOL *stop)
		{
			[view setAlpha:1.f];
		}];

		[mapView transaction:self removeAnnotations:[self.source allObjects]];
		[mapView unlock:self];
	}];
}

@end