//
// Created by dmitriy on 14.04.13.
//
#import "MIIndex.h"
#import "NSMutableSet+SDCountTracking.h"
#import "MIQuadTree.h"

@interface MIIndex ()
{
	MIQuadTreeRef _tree;
	NSMutableSet *_annotations;
}

@end

@implementation MIIndex

- (void)dealloc
{
	MIQuadTreeFree(_tree);
}

- (id)init
{
	self = [super init];
	if (self != nil)
	{
		_tree = MIQuadTreeCreate(MKMapRectWorld);
		_annotations = [NSMutableSet new];
	}

	return self;
}

@end