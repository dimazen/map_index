//
// MIMapView.m
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

#import "MIMapView.h"

#import "MIMapIndex.h"
#import "MIAnnotation.h"

#import "MIMapView+MITransition.h"
#import "MITransitionFactory.h"
#import "MITransition+Subclass.h"

#import <MapKit/MKPinAnnotationView.h>
#import "MIAnnotation+Package.h"

static inline MIChangeType MIChangeTypeFromNSComparisonResult(NSComparisonResult result)
{
    switch (result)
    {
        case NSOrderedSame:
            return MIChangeTypeMove;

        case NSOrderedAscending:
            return MIChangeTypeZoomIn;

        case NSOrderedDescending:
            return MIChangeTypeZoomOut;

        default:
            return MIChangeTypeUndefined;
    }
}

const NSTimeInterval _MIMapViewUpdateDelay = 0.2;

typedef void (^_MIMapViewChange)(void);

@interface MIMapView ()

- (void)initDelegateFlags;
- (void)commonInitialization;

- (void)requestChange:(_MIMapViewChange)change;
- (void)flushDeferredChanges;

- (void)processTransition:(MITransition *)transition level:(NSUInteger)level;
- (void)finalizeTransaction:(MITransition *)transition;

- (MKMapRect)updateAnnotationsRect;
- (void)prepareAnnotationsUpdate;
- (void)updateVisibleState;

@property (nonatomic, readonly) NSUInteger zoomLevel;

@end

@implementation MIMapView

#pragma mark - Init

- (void)commonInitialization
{
	_deferredChanges = [NSMutableArray new];

	_index = [MIMapIndex new];
	_annotationsLevel = 0;
	_clusters = [NSMutableSet new];

	[self setTransitionFactory:[MITransitionFactory new]];

	[super setDelegate:self];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self != nil)
	{
		[self commonInitialization];
	}

	return self;
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self != nil)
	{
		[self commonInitialization];
	}

	return self;
}

#pragma mark - Message Forwarding

- (void)initDelegateFlags
{
	_flags.delegateDidAddAnnotationViews = [_targetDelegate respondsToSelector:@selector(mapView:didAddAnnotationViews:)];
	_flags.delegateViewForAnnotation = [_targetDelegate respondsToSelector:@selector(mapView:viewForAnnotation:)];
	_flags.delegateRegionWillChangeAnimated = [_targetDelegate respondsToSelector:@selector(mapView:regionWillChangeAnimated:)];
	_flags.delegateRegionDidChangeAnimated = [_targetDelegate respondsToSelector:@selector(mapView:regionDidChangeAnimated:)];
}

- (void)setDelegate:(id <MKMapViewDelegate>)delegate
{
	if (_targetDelegate == delegate) return;

	_targetDelegate = delegate;

	[super setDelegate:nil];
	[super setDelegate:self];

	[self initDelegateFlags];
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
	if (![super respondsToSelector:aSelector])
	{
		return [_targetDelegate respondsToSelector:aSelector];
	}

	return YES;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
	NSMethodSignature *result = [super methodSignatureForSelector:aSelector];
	if (result == nil && [_targetDelegate respondsToSelector:aSelector])
	{
		result = [(NSObject *)_targetDelegate methodSignatureForSelector:aSelector];
	}

	return result;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
	if ([_targetDelegate respondsToSelector:[anInvocation selector]])
	{
		[anInvocation invokeWithTarget:_targetDelegate];
	}
	else
	{
		[self doesNotRecognizeSelector:[anInvocation selector]];
	}
}

#pragma mark - Zoom Level

- (NSUInteger)zoomLevel
{
	double mapWidthInPixels = self.bounds.size.width;
	double zoomScale = self.region.span.longitudeDelta * MIMercatorRadius * M_PI / (180.0 * mapWidthInPixels);
	return MAX(MIMinimumZoomDepth, (NSUInteger)ceil(MIZoomDepth - log2(zoomScale)));
}

#pragma mark - Annotations Update

- (void)setNeedsUpdateVisibleState
{
    if ([self isLocked]) return;

    [MIMapView cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateVisibleState) object:nil];
    [self performSelector:@selector(updateVisibleState) withObject:nil afterDelay:0.0];
}

- (MKMapRect)updateAnnotationsRect
{
	MKMapRect rect = self.visibleMapRect;
	if (rect.origin.x + 10.0 > MKMapRectWorld.size.width)
	{
		rect.origin.x = 0.0;
	}

	return rect;
}

- (void)prepareAnnotationsUpdate
{
	[self flushDeferredChanges];

	if (_flags.removalHandlingRequired)
	{
		_flags.removalHandlingRequired = NO;
		[_clusters makeObjectsPerformSelector:@selector(setReadAvailable:) withObject:nil];
	}
}

- (void)updateVisibleState
{    
	MIAssert2(![self isLocked], @"%p: Attemp to update annotation with active transition: %@", (__bridge void *)self, _transition);

	[self prepareAnnotationsUpdate];

	NSUInteger level = [self zoomLevel];
	NSMutableSet *requestClusters = nil;
	NSMutableSet *requestPoints = nil;

	[_index annotationsInMapRect:[self updateAnnotationsRect]
	                       level:level + MIZoomDepthIncrement
		                clusters:&requestClusters
				          points:&requestPoints];

	[_clusters setSet:requestClusters];

	NSMutableSet *target = requestClusters;
	[target unionSet:requestPoints];
	NSMutableSet *source = [[NSMutableSet alloc] initWithArray:[super annotations]];
	if (self.userLocation != nil)
	{
		[source removeObject:self.userLocation];
	}

	for (MIAnnotation *annotation in [source copy])
	{
		MIAnnotation *member = [target member:annotation];
		if (member != nil)
		{
			if ([member class] == [MIAnnotation class])
			{
				[member setReadAvailable:YES];
				[member updateContentData];
			}

			[source removeObject:member];
			[target removeObject:member];
		}
	}

    MIChangeType changeType = MIChangeTypeFromNSComparisonResult([@(_annotationsLevel) compare:@(level)]);
	MITransition *transition = [self.transitionFactory transitionWithTarget:[target allObjects]
                                                                     source:[source allObjects]
                                                                 changeType:changeType];
    [self processTransition:transition level:level];
}

#pragma mark - Transactions

- (void)processTransition:(MITransition *)transition level:(NSUInteger)level
{
	_transition = transition;
	_annotationsLevel = level;

	_flags.transitionAddExpected = _transition.target.count > 0;

	[transition setMapView:self];
	[transition perform];

	if (!_flags.transitionAddExpected && ![self isLocked])
	{
        [self finalizeTransaction:transition];
	}
}

- (void)finalizeTransaction:(MITransition *)transition
{
	if ([self isLocked])
	{
		MIAssert3(_transition == transition, @"%p: Invalid finalize for transaction:%@ while active:%@", (__bridge void *)self, transition, _transition);
	}

	[_index revokeAnnotations:transition.source];

	_flags.transitionAddExpected = NO;

	[_transition setMapView:nil];
	_transition = nil;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
	if (_flags.transitionAddExpected && [[views lastObject] annotation] != self.userLocation)
	{
		MICParameterAssert(_transition != nil);

		_flags.transitionAddExpected = NO;
		[_transition mapView:self didAddAnnotationViews:views];
	}

	if (_flags.delegateDidAddAnnotationViews)
	{
		[_targetDelegate mapView:mapView didAddAnnotationViews:views];
	}
}

#pragma mark - Modification Actions

- (void)requestChange:(_MIMapViewChange)change
{
	if (_transition == nil)
	{
		change();

        [self setNeedsUpdateVisibleState];
	}
	else
	{
		[_deferredChanges addObject:change];
	}
}

- (void)flushDeferredChanges
{
	if (_deferredChanges.count == 0) return;

	NSRange processedRange = (NSRange){0, _deferredChanges.count};
	for (_MIMapViewChange action in [_deferredChanges copy])
	{
		action();
	}
	[_deferredChanges removeObjectsInRange:processedRange];
}

#pragma mark - MKMapView Wrapper

- (void)addAnnotations:(NSArray *)annotations
{
	[self requestChange:^
	{
		[_index addAnnotations:annotations];
	}];
}

- (void)addAnnotation:(id <MKAnnotation>)annotation
{
	[self requestChange:^
	{
		[_index addAnnotation:annotation];
	}];
}

- (void)removeAnnotations:(NSArray *)annotations
{
	[self requestChange:^
	{
		[_index removeAnnotations:annotations];
		_flags.removalHandlingRequired = YES;
	}];
}

- (void)removeAnnotation:(id <MKAnnotation>)annotation
{
	[self requestChange:^
	{
		[_index removeAnnotation:annotation];
		_flags.removalHandlingRequired = YES;
	}];
}

- (NSSet *)annotationsInMapRect:(MKMapRect)mapRect
{
	return [_index annotationsInMapRect:mapRect];
}

- (NSArray *)annotations
{
	return [_index annotations];
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
	MKAnnotationView *view = nil;
	if (_flags.delegateViewForAnnotation)
	{
		view = [_targetDelegate mapView:mapView viewForAnnotation:annotation];
	}

	if (view != nil) return view;

	if (annotation == (id <MKAnnotation>)self.userLocation) return nil;

	static NSString * const identifier = @"mapIndexAnnotation";
	view = [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
	if (view == nil)
	{
		view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
		[view setCanShowCallout:YES];
	}
	else
	{
		[view setAnnotation:annotation];
	}

	[(MKPinAnnotationView *)view setPinColor:
		[annotation class] == [MIAnnotation class] ?
		MKPinAnnotationColorGreen :
		MKPinAnnotationColorRed];

	return view;
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    [MIMapView cancelPreviousPerformRequestsWithTarget:self selector:@selector(setNeedsUpdateVisibleState) object:nil];

	if (_flags.delegateRegionWillChangeAnimated)
	{
		[_targetDelegate mapView:mapView regionWillChangeAnimated:animated];
	}
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [MIMapView cancelPreviousPerformRequestsWithTarget:self selector:@selector(setNeedsUpdateVisibleState) object:nil];
    [self performSelector:@selector(setNeedsUpdateVisibleState) withObject:nil afterDelay:_MIMapViewUpdateDelay];

	if (_flags.delegateRegionDidChangeAnimated)
	{
		[_targetDelegate mapView:mapView regionDidChangeAnimated:animated];
	}
}

@end



@implementation MIMapView (MITransition)

#pragma mark - Lock

- (void)lock:(MITransition *)transition
{
	MIAssert1(_transition != nil, @"%p: Invalid lock: nil transaction", (__bridge void *)self);
	MIAssert3(_transition == transition, @"%p: Invalid lock transition: %@ while active:%@", (__bridge void *)self, transition, _transition);

    _lockCount++;
}

- (void)unlock:(MITransition *)transition
{
	MIAssert1([self isLocked], @"%p: Already unlocked", (__bridge void *)self);
	MIAssert1(_transition != nil, @"%p: Invalid unlock: nil transition", (__bridge void *)self);
	MIAssert3(_transition == transition, @"%p: Invalid unlock transition: %@ while active:%@", (__bridge void *)self, transition, _transition);

    _lockCount--;

    if (_lockCount == 0)
	{
        [self finalizeTransaction:transition];

		if (_deferredChanges.count > 0)
		{
            [self setNeedsUpdateVisibleState];
		}
	}
}

- (BOOL)isLocked
{
	return _lockCount > 0;
}

#pragma mark - Transaction Actions

- (void)transition:(MITransition *)transition addAnnotation:(id <MKAnnotation>)annotation
{
    MIAssert3(_transition == transition, @"%p: Invalid change transition: %@ while active:%@", (__bridge void *)self, transition, _transition);

	[super addAnnotation:annotation];
}

- (void)transition:(MITransition *)transition addAnnotations:(NSArray *)annotations
{
    MIAssert3(_transition == transition, @"%p: Invalid change transition: %@ while active:%@", (__bridge void *)self, transition, _transition);

	[super addAnnotations:annotations];
}

- (void)transition:(MITransition *)transition removeAnnotation:(id <MKAnnotation>)annotation
{
    MIAssert3(_transition == transition, @"%p: Invalid change transition: %@ while active:%@", (__bridge void *)self, transition, _transition);

	[super removeAnnotation:annotation];
}

- (void)transition:(MITransition *)transition removeAnnotations:(NSArray *)annotations
{
    MIAssert3(_transition == transition, @"%p: Invalid change transition: %@ while active:%@", (__bridge void *)self, transition, _transition);

	[super removeAnnotations:annotations];
}

@end