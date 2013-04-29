//
// Created by dmitriy on 26.03.13.
//
#import "MIAscendingTransaction.h"
#import "MIRegularTransaction+Protected.h"

#import "MKAnnotationView+MITranslation.h"
#import "MIAnnotation.h"

#import "MITransaction+Subclass.h"
#import "MITransaction+MIMapView.h"

const NSTimeInterval _MIAscendingTransactionDuration = 0.2;

@implementation MIAscendingTransaction

#pragma mark - Animation

- (void)performAddAnimation:(NSArray *)views
{
	[self lock];

	for (MKAnnotationView *annotationView in views)
	{
		[annotationView setAlpha:0.f];

		for (MIAnnotation *sourceAnnotation in self.source)
		{
			if ([sourceAnnotation class] == [MIAnnotation class] && [sourceAnnotation contains:annotationView.annotation])
			{
				[annotationView applyAnnotationTranslation:sourceAnnotation inMapView:(id) self.mapView];
			}
		}
	}

	[UIView animateWithDuration:_MIAscendingTransactionDuration animations:^
	{
		for (MKAnnotationView *annotationView in views)
		{
			[annotationView applyDefaultTranslation];
			[annotationView setAlpha:1.f];
		}

	} completion:^(BOOL finished)
	{
		[self unlock];
	}];
}

#pragma mark - Invocation


@end