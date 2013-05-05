/**
 * Created with JetBrains AppCode.
 * Author: dmitriy
 * Date: 23.04.13 21:13
 */

#import <MapKit/MKAnnotation.h>

#import "MIAnnotation.h"
#import "MIQuadTree.h"

@interface MIAnnotation : NSObject <MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

@property (nonatomic, readonly) NSUInteger count;
- (BOOL)contains:(id <MKAnnotation>)annotation;
- (NSSet *)allAnnotations;
- (id <MKAnnotation>)anyAnnotation;

@end