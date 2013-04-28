//
// Created by dmitriy on 24.03.13.
//
#import "MIMapView.h"

#import "MIBackend.h"
#import "MIAnnotation.h"

#import "MIMapView+MITransaction.h"
#import "MITransactionFactory.h"
#import "MITransaction+MIMapView.h"
#import "MITransaction+Subclass.h"

#import <MapKit/MKPinAnnotationView.h>
#import <MapKit/MapKit.h>

#import "NSInvocation+SDExtension.h"
#import "NSMutableSet+SDCountTracking.h"

const double _MIWidthInPixels = 268435456.0;
const double _MIMercatorRadius = _MIWidthInPixels / M_PI;
const NSTimeInterval _MIMapViewUpdateDelay = 0.2;

typedef void (^_MIMapViewChange)(void);

@interface MIMapView ()

- (void)initDelegateFlags;
- (void)commonInitialization;

- (void)requestChange:(_MIMapViewChange)change;
- (void)flushDeferredChanges;

- (void)processTransaction:(MITransaction *)transaction level:(NSUInteger)level;

- (void)updateAnnotations;

@property (nonatomic, readonly) NSUInteger zoomLevel;

@end

@implementation MIMapView

#pragma mark - Init

- (void)commonInitialization
{
	_deferredChanges = [NSMutableArray new];

	_backend = [MIBackend new];
	_annotationsLevel = 0;

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
	double zoomScale = self.region.span.longitudeDelta * _MIMercatorRadius * M_PI / (180.0 * mapWidthInPixels);
	return (NSUInteger)ceil(MIZoomDepth - log2(zoomScale));
}

#pragma mark - Annotations Update Schedule

- (void)setUpdateVisibleAnnotations
{
	if (_loopObserver == NULL && ![self isLocked])
	{
		void (^handler)(CFRunLoopObserverRef, CFRunLoopActivity) = ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity)
		{
			CFRunLoopRemoveObserver(CFRunLoopGetCurrent(), observer, kCFRunLoopCommonModes);
			CFRelease(observer);
			_loopObserver = NULL;

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

- (void)updateAnnotations
{
	MIAssert2(![self isLocked], @"%p: Attemp to update annotation with active transaction: %@", (__bridge void *)self, _transaction);

	[self flushDeferredChanges];

	MKMapRect rect = self.visibleMapRect;
	if (rect.origin.x + 10.0 > MKMapRectWorld.size.width)
	{
		rect.origin.x = 0.0;
	}

	NSMutableSet *source = [[NSMutableSet alloc] initWithArray:[super annotations]];
	if (self.userLocation != nil)
	{
		[source removeObject:self.userLocation];
	}

	NSUInteger level = [self zoomLevel];

	__block NSSet *target = [_backend annotationsInMapRect:rect level:level];
	[source minusSet:target onCountChange:^(NSUInteger countBefore, NSUInteger countAfter)
	{
		if ((countBefore - countAfter) == target.count)
		{
			target = nil;
		}
	}];

	NSComparisonResult order = [@(level) compare:@(_annotationsLevel)];
	MITransaction *transaction = [self.transactionFactory transactionWithTarget:target source:source order:order];

	[self processTransaction:transaction level:level];
}

#pragma mark - Transactions

- (void)processTransaction:(MITransaction *)transaction level:(NSUInteger)level
{
	_transaction = transaction;
	_annotationsLevel = level;

	[_transaction setMapView:self];
	[_transaction perform];

	if (![self isLocked])
	{
		[_transaction setMapView:nil];
		_transaction = nil;
	}
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
	if (_transaction != nil && [[views lastObject] annotation] != self.userLocation)
	{
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
		[_backend addAnnotations:annotations];
	}];
}

- (void)addAnnotation:(id <MKAnnotation>)annotation
{
	[self requestChange:^
	{
		[_backend addAnnotation:annotation];
	}];
}

- (void)removeAnnotations:(NSArray *)annotations
{
	[self requestChange:^
	{
		[_backend removeAnnotations:annotations];
	}];
}

- (void)removeAnnotation:(id <MKAnnotation>)annotation
{
	[self requestChange:^
	{
		[_backend removeAnnotation:annotation];
	}];
}

- (NSSet *)annotationsInMapRect:(MKMapRect)mapRect
{
	return [_backend annotationsInMapRect:mapRect];
}

- (NSArray *)annotations
{
	return [_backend annotations];
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

	// default implementation
	if (annotation == self.userLocation) return nil;

	static NSString *identifier = @"annotation";
	view = [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
	if (view == nil)
	{
		view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
	}
	else
	{
		[view setAnnotation:annotation];
	}

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