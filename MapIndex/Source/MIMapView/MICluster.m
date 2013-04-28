/**
 * Created with JetBrains AppCode.
 * Author: dmitriy
 * Date: 23.04.13 21:13
 */

#import "MICluster.h"

@interface MICluster ()
{
	CLLocationCoordinate2D _coordinate;
	NSUInteger _count;
	MIQuadTreeRef _tree;
}

@end

@implementation MICluster

#pragma mark - Init

- (id)initWithTree:(MIQuadTreeRef)tree
{
	self = [super init];
	if (self != nil)
	{
		_tree = tree;
		_count = MIQuadTreeGetCount(_tree);
		_coordinate = MKCoordinateForMapPoint(MIQuadTreeGetCentroid(_tree));
	}
}

#pragma mark - MKAnnotation

- (CLLocationCoordinate2D)coordinate
{
	return _coordinate;
}

#pragma mark - MIAnnotation

- (NSUInteger)count
{
	return _count;
}

- (BOOL)contains:(id <MKAnnotation>)annotation
{
	if ([annotation isKindOfClass:[self class]])
	{
		return MIQuadTreeIsDescendant(_tree, ((MICluster *)annotation)->_tree);
	}

	return NO;
}

- (NSSet *)allAnnotations
{
	return nil;
}

@end