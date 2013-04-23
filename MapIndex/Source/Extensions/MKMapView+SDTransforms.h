//
// Created by dmitriy on 26.03.13.
//
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MKMapView (SDTransforms)

- (CGAffineTransform)translateTransformFrom:(CLLocationCoordinate2D)fromCoordinate
										 to:(CLLocationCoordinate2D)toCoordinate
								 withinView:(UIView *)view;

@end