//
// MIMapView.h
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

#import <Foundation/Foundation.h>
#import <MapKit/MKMapView.h>

@class MITransitionFactory, MITransition, MIMapIndex;

@interface MIMapView : MKMapView  <MKMapViewDelegate>
{
	struct
	{
		BOOL delegateViewForAnnotation : 1;
		BOOL delegateDidAddAnnotationViews : 1;
		BOOL delegateRegionWillChangeAnimated : 1;
		BOOL delegateRegionDidChangeAnimated : 1;
		BOOL removalHandlingRequired : 1;
		BOOL transitionAddExpected : 1;
	} _flags;

	__weak id <MKMapViewDelegate> _targetDelegate;

	MIMapIndex *_index;

	NSUInteger _annotationsLevel;
	NSMutableSet *_clusters;

	NSInteger _lockCount;
  	MITransition *_transition;

	NSMutableArray *_deferredChanges;
}

- (void)setNeedsUpdateVisibleState;

@property (nonatomic, strong) MITransitionFactory *transitionFactory;

#pragma mark - Map Modifying

- (void)addAnnotations:(NSArray *)annotations;
- (void)addAnnotation:(id <MKAnnotation>)annotation;
- (void)removeAnnotations:(NSArray *)annotations;
- (void)removeAnnotation:(id <MKAnnotation>)annotation;
- (NSSet *)annotationsInMapRect:(MKMapRect)mapRect;

- (NSArray *)annotations;

@end