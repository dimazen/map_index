//
// Created by dmitriy on 14.04.13.
//
#import <Foundation/Foundation.h>

#import <MapKit/MKGeometry.h>
#import <MapKit/MKAnnotation.h>

@protocol MKAnnotation;

@interface MISpatialIndex : NSObject

- (void)addAnnotations:(NSArray *)annotations;
- (void)addAnnotation:(id <MKAnnotation>)annotation;
- (void)removeAnnotations:(NSArray *)annotations;
- (void)removeAnnotation:(id <MKAnnotation>)annotation;

- (NSArray *)annotations;
- (NSSet *)annotationsInMapRect:(MKMapRect)mapRect;

- (NSMutableSet *)requestAnnotationsInMapRect:(MKMapRect)mapRect level:(NSUInteger)level;
- (void)revokeAnnotations:(NSSet *)annotations;

@end