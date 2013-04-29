//
// Created by dmitriy on 14.04.13.
//
#import "MISpatialIndex.h"


#import "MIQuadTree.h"
#import "MIPoint.h"
#import "MIAnnotation.h"
#import "MIAnnotation+Package.h"

@interface MISpatialIndex ()
{
	MIQuadTreeRef _tree;
	NSMutableSet *_annotations;

	NSMutableArray *_annotationsPool;
	NSMutableSet *_requestContainer;
}

- (MIAnnotation *)dequeueAnnotation;

@end

@implementation MISpatialIndex

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
		_annotationsPool = [NSMutableArray new];
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

void _MISpacialIndexAnnotationsCallback(MIPoint point, MITraverseResultType resultType, MITraverse *traverse)
{
	[(__bridge NSMutableSet *)traverse->context addObject:(__bridge id <MKAnnotation>)point.identifier];
}

- (NSSet *)annotationsInMapRect:(MKMapRect)mapRect
{
	NSMutableSet *result = [NSMutableSet new];
	MITraverse traverse =
	{
		.callback = _MISpacialIndexAnnotationsCallback,
		.context = (__bridge void *)result,
	};
	MIQuadTreeTraversRectPoints(_tree, mapRect, &traverse);

	return result;
}

#pragma mark - Level Annotations Access

void _MISpacialIndexLevelAnnotationsCallback(MIPoint point, MITraverseResultType resultType, MITraverse *traverse)
{
	MISpatialIndex *self = (__bridge MISpatialIndex *)traverse->context;
	if (resultType == MITraverseResultTree)
	{
		MIAnnotation *annotation = [self dequeueAnnotation];
		[annotation setContent:point.identifier];
		[self->_requestContainer addObject:annotation];
	}
	else
	{
		[self->_requestContainer addObject:(__bridge id <MKAnnotation>)point.identifier];
	}
}

- (NSMutableSet *)requestAnnotationsInMapRect:(MKMapRect)mapRect level:(NSUInteger)level
{
	MITraverse traverse =
	{
		.callback = _MISpacialIndexLevelAnnotationsCallback,
		.context = (__bridge void *)self,
	};

	NSMutableSet *result = [NSMutableSet new];
	_requestContainer = result;

	MIQuadTreeTraversLevelRectPoints(_tree, mapRect, level, &traverse);

	_requestContainer = nil;

	return result;
}

#pragma mark - Pool

- (MIAnnotation *)dequeueAnnotation
{
	if (_annotationsPool.count > 0)
	{
		MIAnnotation *annotation = [_annotationsPool lastObject];
		[_annotationsPool removeLastObject];

		return annotation;
	}

	return [MIAnnotation new];
}

- (void)revokeAnnotations:(NSSet *)annotations
{
	for (MIAnnotation *annotation in annotations)
	{
		if ([annotation class] == [self class])
		{
			[annotation prepareForReuse];
			[_annotationsPool addObject:annotation];
		}
	}
}

@end