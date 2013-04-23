//
// Created by dmitriy on 25.03.13.
//
#import "NSValue+CLLocationCoordinate2D.h"


@implementation NSValue (CLLocationCoordinate2D)

+ (instancetype)valueWithCLLocationCoordinate2D:(CLLocationCoordinate2D)coordinate2D
{
	return [[NSValue alloc] initWithBytes:&coordinate2D objCType:@encode(CLLocationCoordinate2D)];
}

- (CLLocationCoordinate2D)CLLocationCoordinate2DValue
{
	CLLocationCoordinate2D coordinate2D;
	[self getValue:&coordinate2D];

	return coordinate2D;
}

@end