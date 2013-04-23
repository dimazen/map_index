//
// Created by dmitriy on 26.03.13.
//
#import "MITransaction.h"

@interface MIDescendingTransaction : MITransaction

- (void)invokeWithMapView:(MIMapView *)mapView;
- (void)mapView:(MIMapView *)mapView didAddAnnotationViews:(NSArray *)views;

@end