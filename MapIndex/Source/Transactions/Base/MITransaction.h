//
// Created by dmitriy on 26.03.13.
//
#import <Foundation/Foundation.h>

@class MIMapView;

@interface MITransaction : NSObject

@property (nonatomic, weak, readonly) MIMapView *mapView;

@property (nonatomic, strong, readonly) NSArray *target;
@property (nonatomic, strong, readonly) NSArray *source;
@property (nonatomic, readonly) NSComparisonResult order;

- (id)initWithTarget:(NSArray *)target source:(NSArray *)source order:(NSComparisonResult)order;

@end