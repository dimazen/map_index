//
// Created by dmitriy on 26.03.13.
//

#import "MIDescendingTransaction.h"
#import "MIRegularTransaction+Protected.h"

#import "MIMapView.h"
#import "MITransaction+Subclass.h"
#import "MITransaction+MIMapView.h"
#import "MIAnnotation.h"
#import "MKAnnotationView+MITranslation.h"

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

		for (MIAnnotation *targetAnnotation in self.target)
		{
			if ([targetAnnotation class] != [MIAnnotation class]) continue;

			for (MKAnnotationView *view in views)
			{
				if (![targetAnnotation contains:view.annotation]) continue;

				[view applyAnnotationTranslation:targetAnnotation inMapView:self.mapView];
			}
		}

	} completion:^(BOOL finished)
	{
		for (MKAnnotationView *view in views)
		{
			[view setAlpha:1.f];
			[view applyDefaultTranslation];
		}

		[self removeAnnotations:self.source];

		[self unlock];
	}];
}

@end