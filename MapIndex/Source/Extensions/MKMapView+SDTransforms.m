//
// Created by dmitriy on 26.03.13.
//
#import "MKMapView+SDTransforms.h"


@implementation MKMapView (SDTransforms)

- (CGAffineTransform)translateTransformFrom:(CLLocationCoordinate2D)fromCoordinate
										 to:(CLLocationCoordinate2D)toCoordinate
								 withinView:(UIView *)view
{
	CGPoint sourcePoint = [self convertCoordinate:fromCoordinate toPointToView:view];
	CGPoint targetPoint = [self convertCoordinate:toCoordinate toPointToView:view];

	CGPoint delta = (CGPoint){(sourcePoint.x - targetPoint.x), sourcePoint.y - targetPoint.y};

	return CGAffineTransformMakeTranslation(delta.x, delta.y);
}

@end