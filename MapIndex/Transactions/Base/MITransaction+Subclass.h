/**
 * Created with JetBrains AppCode.
 * Author: dmitriy
 * Date: 28.04.13 16:54
 */

#import <Foundation/Foundation.h>
#import "MITransaction.h"

@protocol MKAnnotation;

@interface MITransaction (Subclass)

- (void)perform;
- (void)mapView:(MIMapView *)mapView didAddAnnotationViews:(NSArray *)views;

- (void)addAnnotation:(id <MKAnnotation>)annotation;
- (void)addAnnotations:(NSArray *)annotations;
- (void)removeAnnotation:(id <MKAnnotation>)annotation;
- (void)removeAnnotations:(NSArray *)annotations;

- (void)lock;
- (void)unlock;

@end