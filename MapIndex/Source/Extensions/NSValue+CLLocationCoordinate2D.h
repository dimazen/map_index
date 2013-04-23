//
// Created by dmitriy on 25.03.13.
//
#import <Foundation/Foundation.h>

#import <CoreLocation/CLLocation.h>

@interface NSValue (CLLocationCoordinate2D)

+ (instancetype)valueWithCLLocationCoordinate2D:(CLLocationCoordinate2D)coordinate2D;
- (CLLocationCoordinate2D)CLLocationCoordinate2DValue;

@end