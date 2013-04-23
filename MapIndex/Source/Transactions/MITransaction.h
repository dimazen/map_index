//
// Created by dmitriy on 26.03.13.
//
#import <Foundation/Foundation.h>

@class MIMapView;

@interface MITransaction : NSObject

@property (nonatomic, copy, readonly) NSSet *target;
@property (nonatomic, copy, readonly) NSSet *source;
@property (nonatomic, strong, readonly) NSNumber *targetLevel;
@property (nonatomic, strong, readonly) NSNumber *sourceLevel;
@property (nonatomic, readonly) NSComparisonResult order;

- (id)initWithTarget:(NSSet *)target
			  source:(NSSet *)source
		 targetLevel:(NSNumber *)targetLevel
		 sourceLevel:(NSNumber *)sourceLevel;

+ (id)transactionWithTarget:(NSSet *)target
					 source:(NSSet *)source
				targetLevel:(NSNumber *)targetLevel
				sourceLevel:(NSNumber *)sourceLevel;


- (void)invokeWithMapView:(MIMapView *)mapView;
- (void)mapView:(MIMapView *)mapView didAddAnnotationViews:(NSArray *)views;

@end