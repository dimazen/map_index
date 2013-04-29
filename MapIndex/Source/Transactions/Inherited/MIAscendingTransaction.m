//
// Created by dmitriy on 26.03.13.
//
#import "MIAscendingTransaction.h"

#import "MKMapView+SDTransforms.h"
#import "MIMapView.h"
#import "MIAnnotation.h"
#import "MITransaction+Subclass.h"

const NSTimeInterval _SDAscendingMapTransactionDuration = 0.2;

@implementation MIAscendingTransaction

- (void)perform
{
	[self removeAnnotations:self.source];
	[self addAnnotations:self.target];
}

- (void)mapView:(MIMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
	//fixme: fixme
//	[self lock];
//
//	[views enumerateObjectsUsingBlock:^(MKAnnotationView *view, NSUInteger idx, BOOL *stop)
//	{
//		id <MKAnnotation> target = view.annotation;
//
//		[self.source enumerateObjectsUsingBlock:^(MIAnnotation *source, BOOL *s)
//		{
//			if ([[source class] isSubclassOfClass:[MIAnnotation class]] && [source contains:target])
//			{
//				[view setTransform:[mapView translateTransformFrom:source.coordinate
//																to:target.coordinate
//														withinView:view.superview]];
//			}
//		}];
//	}];
//
//	[UIView animateWithDuration:_SDAscendingMapTransactionDuration animations:^
//	{
//		[views enumerateObjectsUsingBlock:^(MKAnnotationView *view, NSUInteger idx, BOOL *stop)
//		{
//			[view setTransform:CGAffineTransformIdentity];
//		}];
//
//	} completion:^(BOOL finished)
//	{
//		[self unlock];
//	}];
}

@end