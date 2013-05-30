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

#import "MIMapView+MITransaction.h"
#import "MITransactionFactory.h"
#import "MITransaction+Subclass.h"

#import <MapKit/MKPinAnnotationView.h>

#import "NSInvocation+MIExtension.h"
#import "MIAnnotation+Package.h"

#import <libkern/OSAtomic.h>

const NSTimeInterval _MIMapViewUpdateDelay = 0.2;

typedef void (^_MIMapViewChange)(void);

@interface MIMapView ()

- (void)finalizeLoopObserver;

- (void)initDelegateFlags;
- (void)commonInitialization;

- (void)requestChange:(_MIMapViewChange)change;
- (void)flushDeferredChanges;

- (void)processTransaction:(MITransaction *)transaction level:(NSUInteger)level;
- (void)finalizeTransaction:(MITransaction *)transaction;

- (MKMapRect)updateAnnotationsRect;
- (void)prepareAnnotationsUpdate;
- (void)updateAnnotations;

@property (nonatomic, readonly) NSUInteger zoomLevel;

@end

@implementation MIMapView

#pragma mark - Init

- (void)dealloc
{
	[self finalizeLoopObserver];
}

- (void)commonInitialization
{
	_deferredChanges = [NSMutableArray new];

	_index = [MIMapIndex new];
	_annotationsLevel = 0;
	_clusters = [NSMutableSet new];

	[self setTransactionFactory:[MITransactionFactory new]];

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

#pragma mark - Annotations Update Schedule

- (void)finalizeLoopObserver
{
	if (_loopObserver != NULL)
	{
		CFRunLoopRemoveObserver(CFRunLoopGetCurrent(), _loopObserver, kCFRunLoopCommonModes);
		CFRelease(_loopObserver);
		_loopObserver = NULL;
	}
}

- (void)setUpdateVisibleAnnotations
{
	if (_loopObserver == NULL && ![self isLocked])
	{
		void (^handler)(CFRunLoopObserverRef, CFRunLoopActivity) = ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity)
		{
			[self finalizeLoopObserver];
			[self updateAnnotations];
		};

		_loopObserver = CFRunLoopObserverCreateWithHandler(NULL, kCFRunLoopBeforeWaiting, false, 0, handler);
		if (_loopObserver != NULL)
		{
			CFRunLoopAddObserver(CFRunLoopGetCurrent(), _loopObserver, kCFRunLoopCommonModes);
		}
	}
}

#pragma mark - Annotations Update

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

- (void)updateAnnotations
{
	MIAssert2(![self isLocked], @"%p: Attemp to update annotation with active transaction: %@", (__bridge void *)self, _transaction);

	[self prepareAnnotationsUpdate];

	NSUInteger level = [self zoomLevel];

	__block NSMutableSet *target = [NSMutableSet new];
	[_index annotationsInMapRect:[self updateAnnotationsRect]
						   level:level + MIZoomDepthIncrement
						callback:^(NSMutableSet *clusters, NSMutableSet *points)
	{
		[_clusters setSet:clusters];

		[clusters unionSet:points];
		target = clusters;
	}];

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

	MITransaction *transaction = [self.transactionFactory transactionWithTarget:[target allObjects]
																		 source:[source allObjects]
																		  order:[@(_annotationsLevel) compare:@(level)]];
	[self processTransaction:transaction level:level];
}

#pragma mark - Transactions

- (void)processTransaction:(MITransaction *)transaction level:(NSUInteger)level
{
	_transaction = transaction;
	_annotationsLevel = level;

	_flags.transactionAddExpected = _transaction.target.count > 0;

	[transaction setMapView:self];
	[transaction perform];

	if (!_flags.transactionAddExpected && ![self isLocked])
	{
		[self finalizeTransaction:transaction];
	}
}

- (void)finalizeTransaction:(MITransaction *)transaction
{
	if ([self isLocked])
	{
		MIAssert3(_transaction == transaction, @"%p: Invalid finalize for transaction:%@ while active:%@", (__bridge void *)self, transaction, _transaction);
	}

	[_index revokeAnnotations:transaction.source];

	_flags.transactionAddExpected = NO;

	[_transaction setMapView:nil];
	_transaction = nil;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
	if (_flags.transactionAddExpected && [[views lastObject] annotation] != self.userLocation)
	{
		MICParameterAssert(_transaction != nil);

		_flags.transactionAddExpected = NO;
		[_transaction mapView:self didAddAnnotationViews:views];
	}

	if (_flags.delegateDidAddAnnotationViews)
	{
		[_targetDelegate mapView:mapView didAddAnnotationViews:views];
	}
}

#pragma mark - Modification Actions

- (void)requestChange:(_MIMapViewChange)change
{
	if (_transaction == nil)
	{
		change();

		[self setUpdateVisibleAnnotations];
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

	static NSString * const identifier = @"annotation";
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
	[_updateAnnotationsTimer invalidate];

	if (_flags.delegateRegionWillChangeAnimated)
	{
		[_targetDelegate mapView:mapView regionWillChangeAnimated:animated];
	}
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
	NSInvocation *invocation = [NSInvocation invocationForTarget:self selector:@selector(setUpdateVisibleAnnotations)];

	_updateAnnotationsTimer = [NSTimer scheduledTimerWithTimeInterval:_MIMapViewUpdateDelay
														   invocation:invocation
															  repeats:NO];

	if (_flags.delegateRegionDidChangeAnimated)
	{
		[_targetDelegate mapView:mapView regionDidChangeAnimated:animated];
	}
}

@end



@implementation MIMapView (MITransaction)

#pragma mark - Lock

- (void)lock:(MITransaction *)transaction
{
	MIAssert1(_transaction != nil, @"%p: Invalid lock: nil transaction", (__bridge void *)self);
	MIAssert3(_transaction == transaction, @"%p: Invalid lock transaction: %@ while active:%@", (__bridge void *)self, transaction, _transaction);

	OSAtomicIncrement32(&_lockCount);
}

- (void)unlock:(MITransaction *)transaction
{
	MIAssert1([self isLocked], @"%p: Already unlocked", (__bridge void *)self);
	MIAssert1(_transaction != nil, @"%p: Invalid unlock: nil transaction", (__bridge void *)self);
	MIAssert3(_transaction == transaction, @"%p: Invalid unlock transaction: %@ while active:%@", (__bridge void *)self, transaction, _transaction);

	if (OSAtomicDecrement32(&_lockCount) == 0)
	{
		[self finalizeTransaction:transaction];

		if (_deferredChanges.count > 0)
		{
			[self setUpdateVisibleAnnotations];
		}
	}
}

- (BOOL)isLocked
{
	return _lockCount > 0;
}

#pragma mark - Transaction Actions

- (void)transaction:(MITransaction *)transaction addAnnotation:(id <MKAnnotation>)annotation
{
	if (annotation != nil)
	{
		MIAssert3(_transaction == transaction, @"%p: Invalid change transaction: %@ while active:%@", (__bridge void *)self, transaction, _transaction);
	}

	[super addAnnotation:annotation];
}

- (void)transaction:(MITransaction *)transaction addAnnotations:(NSArray *)annotations
{
	if (annotations.count > 0)
	{
		MIAssert3(_transaction == transaction, @"%p: Invalid change transaction: %@ while active:%@", (__bridge void *)self, transaction, _transaction);
	}

	[super addAnnotations:annotations];
}

- (void)transaction:(MITransaction *)transaction removeAnnotation:(id <MKAnnotation>)annotation
{
	if (annotation != nil)
	{
		MIAssert3(_transaction == transaction, @"%p: Invalid change transaction: %@ while active:%@", (__bridge void *)self, transaction, _transaction);
	}

	[super removeAnnotation:annotation];
}

- (void)transaction:(MITransaction *)transaction removeAnnotations:(NSArray *)annotations
{
	if (annotations.count > 0)
	{
		MIAssert3(_transaction == transaction, @"%p: Invalid change transaction: %@ while active:%@", (__bridge void *)self, transaction, _transaction);
	}

	[super removeAnnotations:annotations];
}

@end