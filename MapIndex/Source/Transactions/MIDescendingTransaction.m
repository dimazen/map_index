//
// Created by dmitriy on 26.03.13.
//

#import "MIDescendingTransaction.h"
#import "MIMapView.h"
#import "MIMapView+MITransaction.h"

const NSTimeInterval _MIDescendingTransactionDuration = 0.2;

@implementation MIDescendingTransaction

- (void)invokeWithMapView:(MIMapView *)mapView
{
	[mapView addTransactionAnnotations:[self.target allObjects]];
}

- (void)mapView:(MIMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
	[mapView lock];

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

	[UIView animateWithDuration:_MIDescendingTransactionDuration animations:^
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

		[mapView removeTransactionAnnotations:[self.source allObjects]];
		[mapView unlock];
	}];
}

@end