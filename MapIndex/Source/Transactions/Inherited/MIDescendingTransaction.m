//
// Created by dmitriy on 26.03.13.
//

#import "MIDescendingTransaction.h"
#import "MITransaction+Subclass.h"
#import "MIRegularTransaction+Protected.h"

#import "MIMapView.h"
#import "MIAnnotation.h"
#import "MITransaction+MIMapView.h"

const NSTimeInterval _MIDescendingTransactionDuration = 0.2;

@implementation MIDescendingTransaction

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

	[UIView animateWithDuration:_MIDescendingTransactionDuration animations:^
	{
		[views makeObjectsPerformSelector:@selector(setAlpha:) withObject:nil];

		for (MIAnnotation *target in self.target)
		{
			if ([target class] != [MIAnnotation class]) continue;

			for (MKAnnotationView *view in views)
			{
				if (![target contains:view.annotation]) continue;

				[view setCenter:[self.mapView convertCoordinate:target.coordinate toPointToView:view.superview]];
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