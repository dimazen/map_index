//
// MIMapIndex.m
//
// Copyright (c) 2013 Shemet Dmitriy
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "MIMapIndex.h"


#import "MIQuadTree.h"
#import "MIAnnotation.h"
#import "MIAnnotation+Package.h"

@interface MIMapIndex ()
{
	MIQuadTreeRef _tree;
	NSMutableSet *_annotations;

	NSMutableArray *_annotationsPool;

	NSMutableSet *_clustersContainer;
	NSMutableSet *_pointsContainer;
}

- (void)didReceiveMemoryWarning;

- (MIAnnotation *)dequeueAnnotation;

@end

@implementation MIMapIndex

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidReceiveMemoryWarningNotification
                                                  object:nil];
    
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
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveMemoryWarning)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
	}

	return self;
}

#pragma mark - Memory Warning 

- (void)didReceiveMemoryWarning
{
    [_annotationsPool removeAllObjects];
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
	[self addAnnotations:@[annotation]];
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
	[self removeAnnotations:@[annotation]];
}

#pragma mark - Annotations Access

- (NSArray *)annotations
{
	return [_annotations allObjects];
}

void _MIMapIndexAnnotationsCallback(MIPoint point, MITraverseResultType resultType, MITraverse *traverse)
{
	[(__bridge NSMutableSet *)traverse->context addObject:(__bridge id <MKAnnotation>)point.identifier];
}

- (NSSet *)annotationsInMapRect:(MKMapRect)mapRect
{
	NSMutableSet *result = [NSMutableSet new];
	MITraverse traverse =
	{
		.callback = _MIMapIndexAnnotationsCallback,
		.context = (__bridge void *)result,
	};
	MIQuadTreeTraversRectPoints(_tree, mapRect, &traverse);

	return result;
}

#pragma mark - Level Annotations Access

void _MIMapIndexLevelAnnotationsCallback(MIPoint point, MITraverseResultType resultType, MITraverse *traverse)
{
	MIMapIndex *self = (__bridge MIMapIndex *)traverse->context;

	if (resultType == MITraverseResultTree)
	{
		MIAnnotation *annotation = [self dequeueAnnotation];
		[annotation setContent:point.identifier];
		[self->_clustersContainer addObject:annotation];
	}
	else
	{
		[self->_pointsContainer addObject:(__bridge id <MKAnnotation>) point.identifier];
	}
}

- (void)annotationsInMapRect:(MKMapRect)mapRect
                       level:(NSUInteger)level
	                clusters:(NSMutableSet **)clusters
			          points:(NSMutableSet **)points
{
	MITraverse traverse =
	{
		.callback = _MIMapIndexLevelAnnotationsCallback,
		.context = (__bridge void *)self,
	};

	*clusters = [NSMutableSet new];
	_clustersContainer = *clusters;
	*points = [NSMutableSet new];
	_pointsContainer = *points;

	MIQuadTreeTraversLevelRectPoints(_tree, mapRect, level, &traverse);

	_clustersContainer = nil;
	_pointsContainer = nil;
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

- (void)revokeAnnotations:(NSArray *)annotations
{
	for (MIAnnotation *annotation in annotations)
	{
		if ([annotation class] == [MIAnnotation class])
		{
			[annotation setContent:NULL];
			[_annotationsPool addObject:annotation];
		}
	}
}

@end