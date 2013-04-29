//
// Created by dmitriy on 26.03.13.
//
#import "MIRegularTransaction.h"

#import "MIMapView+MITransaction.h"
#import "MITransaction+Subclass.h"
#import "MITransaction+MIMapView.h"

const NSTimeInterval _MIRegularTransactionDuration = 0.2;

@interface MIRegularTransaction ()

- (void)performAddAnimation:(NSArray *)views;
- (void)performRemoveAnimation;

@end

@implementation MIRegularTransaction

#pragma mark - Animation

- (void)performRemoveAnimation
{
	NSMutableArray *views = [[NSMutableArray alloc] initWithCapacity:self.source.count];
	for (id <MKAnnotation> annotation in self.source)
	{
		MKAnnotationView *annotationView = [self.mapView viewForAnnotation:annotation];
		if (annotationView != nil)
		{
			[views addObject:annotationView];
		}
	}

	if (views.count == 0)
	{
		[self removeAnnotations:self.source];

		return;
	}

	[self lock];

	[UIView animateWithDuration:_MIRegularTransactionDuration animations:^
	{
		[views makeObjectsPerformSelector:@selector(setAlpha:) withObject:nil];

	} completion:^(BOOL finished)
	{
		for (MKAnnotationView *annotationView in views)
		{
			[annotationView setAlpha:1.f];
		}

		[self removeAnnotations:self.source];
		[self unlock];
	}];
}

- (void)performAddAnimation:(NSArray *)views
{
	[self lock];

	[views makeObjectsPerformSelector:@selector(setAlpha:) withObject:nil];

	[UIView animateWithDuration:_MIRegularTransactionDuration animations:^
	{
		for (MKAnnotationView *annotationView in views)
		{
			[annotationView setAlpha:1.f];
		}

	} completion:^(BOOL finished)
	{
		[self unlock];
	}];
}

#pragma mark - Invocation

- (void)perform
{
	if (self.target.count > 0)
	{
		[self addAnnotations:self.target];
	}
	else if (self.source.count > 0)
	{
		[self performRemoveAnimation];
	}
}

- (void)mapView:(MIMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
	[self performRemoveAnimation];
	[self performAddAnimation:views];
}

@end