//
// Created by dmitriy on 26.03.13.
//
#import "MIAscendingTransaction.h"

#import "MKMapView+SDTransforms.h"
#import "MIMapView.h"
#import "MIMapView+MITransaction.h"
#import "MICluster.h"

const NSTimeInterval _SDAscendingMapTransactionDuration = 0.2;

@implementation MIAscendingTransaction

- (void)invokeWithMapView:(MIMapView *)mapView
{
	[mapView transaction:self removeAnnotations:[self.source allObjects]];
	[mapView transaction:self addAnnotations:[self.target allObjects]];
}

- (void)mapView:(MIMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
	[mapView lock:self];

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

	[UIView animateWithDuration:_SDAscendingMapTransactionDuration animations:^
	{
		[views enumerateObjectsUsingBlock:^(MKAnnotationView *view, NSUInteger idx, BOOL *stop)
		{
			[view setTransform:CGAffineTransformIdentity];
		}];

	} completion:^(BOOL finished)
	{
		[mapView unlock:self];
	}];
}

@end