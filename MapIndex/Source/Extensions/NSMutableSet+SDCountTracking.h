//
// Created by dmitriy on 30.03.13.
//
#import <Foundation/Foundation.h>

typedef void (^SDTrackingCallback)(NSUInteger countBefore, NSUInteger countAfter);

@interface NSMutableSet (SDCountTracking)

- (void)addObject:(id)object onCountChange:(SDTrackingCallback)onChange;
- (void)removeObject:(id)object onCountChange:(SDTrackingCallback)onChange;
- (void)removeAllObjectsOnCountChange:(SDTrackingCallback)onCountChange;
- (void)addObjectsFromArray:(NSArray *)array onCountChange:(SDTrackingCallback)onChange;
- (void)unionSet:(NSSet *)otherSet onCountChange:(SDTrackingCallback)onChange;
- (void)minusSet:(NSSet *)otherSet onCountChange:(SDTrackingCallback)onChange;

@end