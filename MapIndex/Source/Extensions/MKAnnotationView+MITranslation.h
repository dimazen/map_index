/**
 * Created with JetBrains AppCode.
 * Author: dmitriy
 * Date: 29.04.13 16:01
 */

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MKAnnotationView (MITranslation)

- (void)applyTranslationFromAnnotation:(id <MKAnnotation>)annotation inMapView:(MKMapView *)mapView;
- (void)applyDefaultTranslation;

@end