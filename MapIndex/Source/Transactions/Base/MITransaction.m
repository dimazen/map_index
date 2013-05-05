//
// Created by dmitriy on 26.03.13.
//
#import "MITransaction.h"

#import "MIMapView.h"
#import "MIMapView+MITransaction.h"
#import "MITransaction+MIMapView.h"
#import "MITypes.h"

@interface MITransaction ()

@property (nonatomic, weak) MIMapView *mapView;

@end


@implementation MITransaction

- (id)initWithTarget:(NSArray *)target source:(NSArray *)source
{
	self = [super init];
	if (self)
	{
		_target = target;
		_source = source;
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
	MICParameterAssert(self.mapView != nil);
	[self.mapView transaction:self addAnnotation:annotation];
}

- (void)addAnnotations:(NSArray *)annotations
{
	MICParameterAssert(self.mapView != nil);
	[self.mapView transaction:self addAnnotations:annotations];
}

- (void)removeAnnotation:(id <MKAnnotation>)annotation
{
	MICParameterAssert(self.mapView != nil);
	[self.mapView transaction:self removeAnnotation:annotation];
}

- (void)removeAnnotations:(NSArray *)annotations
{
	MICParameterAssert(self.mapView != nil);
	[self.mapView transaction:self removeAnnotations:annotations];
}

- (void)lock
{
	MICParameterAssert(self.mapView != nil);
	[self.mapView lock:self];
}

- (void)unlock
{
	MICParameterAssert(self.mapView != nil);
	[self.mapView unlock:self];
}

@end