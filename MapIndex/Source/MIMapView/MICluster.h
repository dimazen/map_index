/**
 * Created with JetBrains AppCode.
 * Author: dmitriy
 * Date: 23.04.13 21:13
 */

#import "MIAnnotation.h"
#import "MIQuadTree.h"

@interface MICluster : NSObject <MIAnnotation>

- (id)initWithTree:(MIQuadTreeRef)tree;

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

@property (nonatomic, readonly) NSUInteger count;
- (BOOL)contains:(id <MKAnnotation>)annotation;
- (NSSet *)allAnnotations;

@end