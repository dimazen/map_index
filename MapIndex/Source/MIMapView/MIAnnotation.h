//
// Created by dmitriy on 26.03.13.
//
#import <MapKit/MKAnnotation.h>

@protocol MIAnnotation <MKAnnotation>

@property (nonatomic, readonly) NSUInteger count;
- (BOOL)contains:(id <MKAnnotation>)annotation;
- (NSSet *)allAnnotations;

@end