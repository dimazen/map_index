//
// Created by dmitriy on 26.03.13.
//
#import "MITransaction.h"

@interface MIRegularTransaction : MITransaction

- (void)perform;
- (void)mapView:(MIMapView *)mapView didAddAnnotationViews:(NSArray *)views;

@end