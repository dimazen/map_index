//
// Created by dmitriy on 26.03.13.
//
#import "MITransaction.h"

#import "MIMapView.h"
#import "MIMapView+MITransaction.h"
#import "MITransaction+MIMapView.h"

@interface MITransaction ()

@property (nonatomic, weak) MIMapView *mapView;

@end


@implementation MITransaction

- (id)initWithTarget:(NSSet *)target source:(NSSet *)source order:(NSComparisonResult)order
{
	self = [super init];
	if (self)
	{
		_target = target;
		_source = source;
		_order = order;
	}

	return self;
}

- (void)perform
{
	[NSException raise:@"Subclass error" format:@"Subclass should override %@", NSStringFromSelector(_cmd)];
}

- (void)mapView:(MIMapView *)mapView didAddAnnotationViews:(NSArray *)views
{}

@end


@implementation MITransaction (MIMapView)

@dynamic mapView;

@end


@implementation MITransaction (Subclass)

- (void)addAnnotation:(id <MKAnnotation>)annotation
{
	[self.mapView transaction:self addAnnotation:annotation];
}

- (void)addAnnotations:(NSArray *)annotations
{
	[self.mapView transaction:self addAnnotations:annotations];
}

- (void)removeAnnotation:(id <MKAnnotation>)annotation
{
	[self.mapView transaction:self removeAnnotation:annotation];
}

- (void)removeAnnotations:(NSArray *)annotations
{
	[self.mapView transaction:self removeAnnotations:annotations];
}

- (void)lock
{
	[self.mapView lock:self];
}

- (void)unlock
{
	[self.mapView unlock:self];
}

@end