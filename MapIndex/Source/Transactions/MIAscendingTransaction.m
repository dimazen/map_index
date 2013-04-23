//
// Created by dmitriy on 26.03.13.
//
#import "MIAscendingTransaction.h"

#import "MIMapView.h"
#import "MKMapView+SDTransforms.h"
#import "MIMapView+MITransaction.h"

#import "MICluster.h"

const NSTimeInterval _MIAscendingTransactionDuration = 0.2;

@implementation MIAscendingTransaction

- (void)invokeWithMapView:(MIMapView *)mapView
{
	[mapView removeTransactionAnnotations:[self.source allObjects]];
	[mapView addTransactionAnnotations:[self.target allObjects]];
}

- (void)mapView:(MIMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
	[mapView lock];

	[views enumerateObjectsUsingBlock:^(MKAnnotationView *view, NSUInteger idx, BOOL *stop)
	{
		id <MKAnnotation> target = view.annotation;

		[self.source enumerateObjectsUsingBlock:^(MICluster *source, BOOL *s)
		{
			if ([[source class] isSubclassOfClass:[MICluster class]] && [source contains:target])
			{
				[view setTransform:[mapView translateTransformFrom:source.coordinate
																to:target.coordinate
													 withinView:view.superview]];
			}
		}];
	}];

	[UIView animateWithDuration:_MIAscendingTransactionDuration animations:^
	{
		[views enumerateObjectsUsingBlock:^(MKAnnotationView *view, NSUInteger idx, BOOL *stop)
		{
			[view setTransform:CGAffineTransformIdentity];
		}];

	}                completion:^(BOOL finished)
	{
		[mapView unlock];
	}];
}

@end