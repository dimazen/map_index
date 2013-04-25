//
// Created by dmitriy on 24.03.13.
//
#import "MIMapView.h"
#import "MIMapView+MITransaction.h"
#import "MIAnnotation.h"

#import <MapKit/MapKit.h>

#import "MITransactionFactory.h"

#import "NSInvocation+SDExtension.h"
#import "NSMutableSet+SDCountTracking.h"
#import "MIIndex.h"
#import "MITypes.h"

const double _MIWidthInPixels = 268435456.0;
const double _MIMercatorRadius = _MIWidthInPixels / M_PI;
const NSTimeInterval _MIMapViewUpdateDelay = 0.2;

typedef void (^_MIMapViewAction)(void);

@interface MIMapView ()

- (void)initDelegateFlags;
- (void)commonInitialization;

- (void)requestModificationAction:(_MIMapViewAction)action;
- (void)flushModificationActions;

- (void)processTransaction:(MITransaction *)transaction;

- (void)updateAnnotations;

@property (nonatomic, readonly) NSUInteger zoomLevel;

@end

@implementation MIMapView

#pragma mark - Init

- (void)commonInitialization
{
	_modificationActions = [NSMutableArray new];

	_index = [MIIndex new];
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

- (void)setUpdateAnnotationsIfNeeded
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

- (NSUInteger)annotationsLevel
{
	if (_annotationsLevel == NSUIntegerMax)
	{
		_annotationsLevel = [self zoomLevel];
	}

	return _annotationsLevel;
}

- (void)updateAnnotations
{
	MIAssert2(![self isLocked], @"%p: Attemp to update annotation with active transaction: %@", (__bridge void *)self, _activeTransaction);

	[self flushModificationActions];

	MKMapRect rect = self.visibleMapRect;
	if (rect.origin.x + 10.0 > MKMapRectWorld.size.width)
	{
		rect.origin.x = 0.0;
	}

	NSMutableSet *sourceAnnotations = [[NSMutableSet alloc] initWithArray:[super annotations]];

	if (self.userLocation != nil)
	{
		[sourceAnnotations removeObject:self.userLocation];
	}

	NSUInteger level = [self zoomLevel];
	//fixme: fix me
	__block NSSet *targetAnnotations = nil;//[_tree annotationsInRect:rect maxTraversalDepth:level];

	[sourceAnnotations minusSet:targetAnnotations onCountChange:^(NSUInteger countBefore, NSUInteger countAfter)
	{
		if ((countBefore - countAfter) == targetAnnotations.count)
		{
			targetAnnotations = nil;
		}
	}];

	MITransaction *transaction = [self.transactionFactory transactionWithTarget:targetAnnotations
																		 source:sourceAnnotations
																	targetLevel:@(level)
																	sourceLevel:@(self.annotationsLevel)];

	_activeTransaction = targetAnnotations.count > 0 ? transaction : nil;

	[self processTransaction:transaction];
}

#pragma mark - Transactions

- (void)processTransaction:(MITransaction *)transaction
{
	_activeTransaction = transaction;
	_annotationsLevel = [transaction.targetLevel unsignedIntegerValue];

	[transaction invokeWithMapView:self];

	if (![self isLocked])
	{
		_activeTransaction = nil;
	}
}


- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
	if (_activeTransaction != nil && [[views lastObject] annotation] != self.userLocation)
	{
		[_activeTransaction mapView:self didAddAnnotationViews:views];
	}

	if (_flags.delegateDidAddAnnotationViews)
	{
		[_targetDelegate mapView:mapView didAddAnnotationViews:views];
	}
}

#pragma mark - Modification Actions

- (void)requestModificationAction:(_MIMapViewAction)action
{
	if (_activeTransaction == nil)
	{
		action();

		[self setUpdateAnnotationsIfNeeded];
	}
	else
	{
		[_modificationActions addObject:action];
	}
}

- (void)flushModificationActions
{
	if (_modificationActions.count == 0) return;

	NSRange processedRange = (NSRange){0, _modificationActions.count};
	for (_MIMapViewAction action in [_modificationActions copy])
	{
		action();
	}
	[_modificationActions removeObjectsInRange:processedRange];
}

#pragma mark - MKMapView Wrapper

- (void)addAnnotations:(NSArray *)annotations
{
	[self requestModificationAction:^
	{
		for (id <MKAnnotation> annotation in annotations)
		{
			// fixme: add required method to index
//			[_tree insert:annotation];
		}
	}];
}

- (void)addAnnotation:(id <MKAnnotation>)annotation
{
	[self requestModificationAction:^
	{
		// fixme: add required method to index
//		[_tree insert:annotation];
	}];
}

- (void)removeAnnotations:(NSArray *)annotations
{
	[self requestModificationAction:^
	{
		for (id <MKAnnotation> annotation in annotations)
		{
			// fixme: add required method to index
//			[_tree remove:annotation];
		}
	}];
}

- (void)removeAnnotation:(id <MKAnnotation>)annotation
{
	[self requestModificationAction:^
	{
		// fixme: add required method to index
//		[_tree remove:annotation];
	}];
}

- (NSArray *)annotations
{
	// fixme: add required method to index
//	return [[_tree allAnnotations] allObjects];
	return nil;
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
	NSInvocation *invocation = [NSInvocation invocationForTarget:self selector:@selector(setUpdateAnnotationsIfNeeded)];

	_updateAnnotationsTimer = [NSTimer scheduledTimerWithTimeInterval:_MIMapViewUpdateDelay
														   invocation:invocation
															  repeats:NO];

	if (_flags.delegateRegionDidChangeAnimated)
	{
		[_targetDelegate mapView:mapView regionDidChangeAnimated:animated];
	}
}

@end