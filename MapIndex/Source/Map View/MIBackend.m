//
// Created by dmitriy on 14.04.13.
//
#import "MIBackend.h"


#import "MIQuadTree.h"

@interface MIBackend ()
{
	MIQuadTreeRef _tree;
	NSMutableSet *_annotations;
}

@end

@implementation MIBackend

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
		[_annotations removeObject:annotation];
		if (_annotations.count < countBefore )
		{
			MIQuadTreeRemovePoint(_tree, MIPointMake(MKMapPointForCoordinate([annotation coordinate]),(__bridge void *)annotation));
		}
	}
}

- (void)removeAnnotation:(id <MKAnnotation>)annotation
{
	NSUInteger countBefore = _annotations.count;
	[_annotations removeObject:annotation];
	if (_annotations.count < countBefore )
	{
		MIQuadTreeRemovePoint(_tree, MIPointMake(MKMapPointForCoordinate([annotation coordinate]),(__bridge void *)annotation));
	}
}

#pragma mark - Annotations Access

- (NSArray *)annotations
{
	return [_annotations allObjects];
}

void _MIIndexAnnotationsInMapRect(MIPoint point, MITraverseResultType resultType, MITraverse *traverse)
{
	[(__bridge NSMutableSet *)traverse->context addObject:(__bridge id <MKAnnotation>)point.identifier];
}

- (NSSet *)annotationsInMapRect:(MKMapRect)mapRect
{
	NSMutableSet *result = [NSMutableSet new];
	MITraverse traverse =
	{
		.callback = _MIIndexAnnotationsInMapRect,
		.context = (__bridge void *)result,
	};
	MIQuadTreeTraversRectPoints(_tree, mapRect, &traverse);

	return result;
}

void _MIIndexAnnotationsInMapRectLevel(MIPoint point, MITraverseResultType resultType, MITraverse *traverse)
{
	NSMutableSet *set = (__bridge NSMutableSet *)traverse->context;
	if (resultType == MITraverseResultTree)
	{

	}
	else
	{

	}
}

- (NSSet *)annotationsInMapRect:(MKMapRect)mapRect level:(NSUInteger)level
{
	NSMutableSet *result = [NSMutableSet new];
	MITraverse traverse =
	{
		.callback = _MIIndexAnnotationsInMapRect,
		.context = (__bridge void *)result,
	};

	MIQuadTreeTraversLevelRectPoints(_tree, mapRect, level, &traverse);

	return result;
}

@end