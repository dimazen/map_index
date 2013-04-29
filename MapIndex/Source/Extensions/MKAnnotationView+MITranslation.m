/**
 * Created with JetBrains AppCode.
 * Author: dmitriy
 * Date: 29.04.13 16:01
 */

#import "MKAnnotationView+MITranslation.h"
#import "MITypes.h"

@implementation MKAnnotationView (MITranslation)

- (void)applyAnnotationTranslation:(id <MKAnnotation>)annotation inMapView:(MKMapView *)mapView
{
	MIAssert1(self.superview != nil, @"%p: Nil superview", (__bridge void *)self);

	CGPoint fromPoint = [mapView convertCoordinate:annotation.coordinate toPointToView:self.superview];
	CGPoint toPoint = [mapView convertCoordinate:self.annotation.coordinate toPointToView:self.superview];

	[self setTransform:CGAffineTransformMakeTranslation(fromPoint.x - toPoint.x, fromPoint.y - toPoint.y)];
}

- (void)applyDefaultTranslation
{
	[self setTransform:CGAffineTransformIdentity];
}

@end