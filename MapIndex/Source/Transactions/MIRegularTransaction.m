//
// Created by dmitriy on 26.03.13.
//
#import "MIRegularTransaction.h"

#import "MIMapView+MITransaction.h"

const NSTimeInterval _SDRegularMapTransactionDuration = 0.2;

@implementation MIRegularTransaction

- (void)invokeWithMapView:(MIMapView *)mapView
{
	[mapView transaction:self addAnnotations:[self.target allObjects]];
}

- (void)mapView:(MIMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
	[mapView lock:self];

	[views makeObjectsPerformSelector:@selector(setAlpha:) withObject:nil];

	[UIView animateWithDuration:_SDRegularMapTransactionDuration animations:^
	{
		[views enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop)
		{
			[view setAlpha:1.f];
		}];

	} completion:^(BOOL finished)
	{
		[mapView transaction:self removeAnnotations:[self.source allObjects]];

		[mapView unlock:self];
	}];
}

@end