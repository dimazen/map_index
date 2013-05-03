//
// Created by dmitriy on 26.03.13.
//

#import "MIAscendingTransaction.h"
#import "MITransaction+Subclass.h"
#import "MIRegularTransaction+Protected.h"

#import "MIMapView.h"
#import "MIAnnotation.h"
#import "MITransaction+MIMapView.h"

const NSTimeInterval _MIAscendingTransactionDuration = 0.2;

@implementation MIAscendingTransaction

#pragma mark - Animation

- (void)performAddAnimation:(NSArray *)views
{
	[self lock];

	for (MKAnnotationView *view in views)
	{
		[view setAlpha:0.f];

		for (MIAnnotation *source in self.source)
		{
			if (!([source class] == [MIAnnotation class] && [source contains:view.annotation])) continue;

			[view setCenter:[self.mapView convertCoordinate:source.coordinate toPointToView:view.superview]];
		}
	}

	[UIView animateWithDuration:_MIAscendingTransactionDuration animations:^
	{
		for (MKAnnotationView *view in views)
		{
			[view setCenter:[self.mapView convertCoordinate:view.annotation.coordinate toPointToView:view.superview]];
			[view setAlpha:1.f];
		}

	} completion:^(BOOL finished)
	{
		[self unlock];
	}];
}

@end