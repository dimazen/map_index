//
// Created by dmitriy on 24.03.13.
//
#import <Foundation/Foundation.h>

#import <MapKit/MKMapView.h>

@class MITransactionFactory, MITransaction, MISpatialIndex;

@interface MIMapView : MKMapView  <MKMapViewDelegate>
{
	struct
	{
		BOOL delegateViewForAnnotation : 1;
		BOOL delegateDidAddAnnotationViews : 1;
		BOOL delegateRegionWillChangeAnimated : 1;
		BOOL delegateRegionDidChangeAnimated : 1;
	} _flags;

	__weak id <MKMapViewDelegate> _targetDelegate;

	MISpatialIndex *_spacialIndex;
	NSUInteger _annotationsLevel;
	BOOL _transactionLock;
  	MITransaction *_transaction;

	NSMutableArray *_deferredChanges;

	__weak NSTimer *_updateAnnotationsTimer;
	CFRunLoopObserverRef _loopObserver;
}

- (void)setUpdateVisibleAnnotations;

@property (nonatomic, strong) MITransactionFactory *transactionFactory;

#pragma mark - Map Modifying

- (void)addAnnotations:(NSArray *)annotations;
- (void)addAnnotation:(id <MKAnnotation>)annotation;
- (void)removeAnnotations:(NSArray *)annotations;
- (void)removeAnnotation:(id <MKAnnotation>)annotation;
- (NSSet *)annotationsInMapRect:(MKMapRect)mapRect;

- (NSArray *)annotations;

@end