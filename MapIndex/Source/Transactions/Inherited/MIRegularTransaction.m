//
// Created by dmitriy on 26.03.13.
//
#import "MIRegularTransaction.h"
#import "MIRegularTransaction+Protected.h"

#import "MIMapView+MITransaction.h"
#import "MITransaction+Subclass.h"
#import "MITypes.h"

const NSTimeInterval _MIRegularTransactionDuration = 0.2;

@implementation MIRegularTransaction

#pragma mark - Invocation

- (void)perform
{
	[self addAnnotations:self.target];
	[self removeAnnotations:self.source];

	return;

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
	return;

	MIAssert1(views.count > 0, @"%p: Empty views array", (__bridge void *)self);

	[self performRemoveAnimation];
	[self performAddAnimation:views];
}

@end

@implementation MIRegularTransaction (Protected)

- (void)performRemoveAnimation
{
	NSMutableArray *views = [[NSMutableArray alloc] initWithCapacity:self.source.count];
	for (id <MKAnnotation> annotation in self.source)
	{
		MKAnnotationView *view = [self.mapView viewForAnnotation:annotation];
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

	[self lock];

	[UIView animateWithDuration:_MIRegularTransactionDuration animations:^
	{
		[views makeObjectsPerformSelector:@selector(setAlpha:) withObject:nil];

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

- (void)performAddAnimation:(NSArray *)views
{
	[self lock];

	[views makeObjectsPerformSelector:@selector(setAlpha:) withObject:nil];

	[UIView animateWithDuration:_MIRegularTransactionDuration animations:^
	{
		for (MKAnnotationView *view in views)
		{
			[view setAlpha:1.f];
		}

	} completion:^(BOOL finished)
	{
		[self unlock];
	}];
}

@end