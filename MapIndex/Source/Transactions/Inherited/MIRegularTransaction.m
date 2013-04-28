//
// Created by dmitriy on 26.03.13.
//
#import "MIRegularTransaction.h"

#import "MIMapView+MITransaction.h"
#import "MITransaction+Subclass.h"

const NSTimeInterval _SDRegularMapTransactionDuration = 0.2;

@implementation MIRegularTransaction

- (void)perform
{
	//fixme: if there will be no annotations to add, then source annotations wouldn't be remove
	[self addAnnotations:[self.target allObjects]];
}

- (void)mapView:(MIMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
	[self lock];

	[views makeObjectsPerformSelector:@selector(setAlpha:) withObject:nil];

	[UIView animateWithDuration:_SDRegularMapTransactionDuration animations:^
	{
		[views enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop)
		{
			[view setAlpha:1.f];
		}];

	} completion:^(BOOL finished)
	{
		[self removeAnnotations:[self.source allObjects]];
		[self unlock];
	}];
}

@end