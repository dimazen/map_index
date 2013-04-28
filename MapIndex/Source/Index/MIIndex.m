//
// Created by dmitriy on 14.04.13.
//
#import "MIIndex.h"

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

#pragma mark - Index Modifying

- (void)addAnnotations:(NSArray *)annotations
{
	for (id <MKAnnotation> annotation in annotations)
	{
		NSUInteger countBefore = _annotations.count;
		[_annotations addObject:annotation];
		if (countBefore < _annotations.count)
		{
			MIQuadTreeInsertPoint(_tree, MIPointMake(MKMapPointForCoordinate([annotation coordinate]),(__bridge void *)annotation));
		}
	}
}

- (void)addAnnotation:(id <MKAnnotation>)annotation
{
	NSUInteger countBefore = _annotations.count;
	[_annotations addObject:annotation];
	if (countBefore < _annotations.count)
	{
		MIQuadTreeInsertPoint(_tree, MIPointMake(MKMapPointForCoordinate([annotation coordinate]),(__bridge void *)annotation));
	}
}

- (void)removeAnnotations:(NSArray *)annotations
{
	for (id <MKAnnotation> annotation in annotations)
	{
		NSUInteger countBefore = _annotations.count;
		[_annotations addObject:annotation];
		if (_annotations.count < countBefore )
		{
			MIQuadTreeInsertPoint(_tree, MIPointMake(MKMapPointForCoordinate([annotation coordinate]),(__bridge void *)annotation));
		}
	}
}

- (void)removeAnnotation:(id <MKAnnotation>)annotation
{
	NSUInteger countBefore = _annotations.count;
	[_annotations addObject:annotation];
	if (_annotations.count < countBefore )
	{
		MIQuadTreeInsertPoint(_tree, MIPointMake(MKMapPointForCoordinate([annotation coordinate]),(__bridge void *)annotation));
	}
}

- (NSSet *)annotationsInMapRect:(MKMapRect)mapRect
{
	
}

- (NSArray *)annotations
{
	return [_annotations allObjects];
}

@end