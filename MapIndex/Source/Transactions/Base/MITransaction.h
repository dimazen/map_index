//
// Created by dmitriy on 26.03.13.
//
#import <Foundation/Foundation.h>

@class MIMapView;

@interface MITransaction : NSObject

@property (nonatomic, strong, readonly) NSSet *target;
@property (nonatomic, strong, readonly) NSSet *source;
@property (nonatomic, readonly) NSComparisonResult order;

- (id)initWithTarget:(NSSet *)target source:(NSSet *)source order:(NSComparisonResult)order;

@end