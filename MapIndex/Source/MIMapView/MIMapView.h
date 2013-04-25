//
// Created by dmitriy on 24.03.13.
//
#import <Foundation/Foundation.h>

#import <MapKit/MKMapView.h>

@class MITransactionFactory, MITransaction, MIIndex;

@interface MIMapView : MKMapView  <MKMapViewDelegate>
{
	struct
	{
		BOOL delegateViewForAnnotation : 1;
		BOOL delegateDidAddAnnotationViews : 1;
		BOOL delegateRegionWillChangeAnimated : 1;
		BOOL delegateRegionDidChangeAnimated : 1;

		BOOL locked : 1;
	} _flags;

	__weak id <MKMapViewDelegate> _targetDelegate;

	MIIndex *_index;
	NSUInteger _annotationsLevel;

  	MITransaction *_activeTransaction;

	NSMutableArray *_modificationActions;

	__weak NSTimer *_updateAnnotationsTimer;
	CFRunLoopObserverRef _loopObserver;
}

- (void)setUpdateAnnotationsIfNeeded;

@property (nonatomic, strong) MITransactionFactory *transactionFactory;

@end