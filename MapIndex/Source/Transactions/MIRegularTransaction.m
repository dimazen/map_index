//
// Created by dmitriy on 26.03.13.
//
#import "MIRegularTransaction.h"

#import "MIMapView+MITransaction.h"

const NSTimeInterval _MIRegularTransactionDuration = 0.2;

@implementation MIRegularTransaction

- (void)invokeWithMapView:(MIMapView *)mapView
{
	[mapView addTransactionAnnotations:[self.target allObjects]];
}

- (void)mapView:(MIMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
	[mapView lock];

	[views makeObjectsPerformSelector:@selector(setAlpha:) withObject:nil];

	[UIView animateWithDuration:_MIRegularTransactionDuration animations:^
	{
		[views enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop)
		{
			[view setAlpha:1.f];
		}];

	} completion:^(BOOL finished)
	{
		[mapView removeTransactionAnnotations:[self.source allObjects]];

		[mapView unlock];
	}];
}

@end