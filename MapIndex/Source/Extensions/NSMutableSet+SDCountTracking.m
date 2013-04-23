//
// Created by dmitriy on 30.03.13.
//
#import "NSMutableSet+SDCountTracking.h"

static inline void _NSMutableSetSDCountTracking(NSMutableSet *set, void (^mutation)(void), SDTrackingCallback changeCallback)
{
	NSUInteger countBefore = set.count;
	mutation();
	NSUInteger countAfter = set.count;

	if (countAfter != countBefore)
	{
		changeCallback(countBefore, countAfter);
	}
}

@implementation NSMutableSet (SDCountTracking)

- (void)addObject:(id)object onCountChange:(SDTrackingCallback)onChange
{
	_NSMutableSetSDCountTracking(self, ^
	{
		[self addObject:object];

	}, onChange);
}

- (void)removeObject:(id)object onCountChange:(SDTrackingCallback)onChange
{
	_NSMutableSetSDCountTracking(self, ^
	{
		[self removeObject:object];

	}, onChange);
}

- (void)removeAllObjectsOnCountChange:(SDTrackingCallback)onChange
{
	_NSMutableSetSDCountTracking(self, ^
	{
		[self removeAllObjects];

	}, onChange);
}

- (void)addObjectsFromArray:(NSArray *)array onCountChange:(SDTrackingCallback)onChange
{
	_NSMutableSetSDCountTracking(self, ^
	{
		[self addObjectsFromArray:array];

	}, onChange);
}

- (void)unionSet:(NSSet *)otherSet onCountChange:(SDTrackingCallback)onChange
{
	_NSMutableSetSDCountTracking(self, ^
	{
		[self unionSet:otherSet];

	}, onChange);
}

- (void)minusSet:(NSSet *)otherSet onCountChange:(SDTrackingCallback)onChange
{
	_NSMutableSetSDCountTracking(self, ^
	{
		[self minusSet:otherSet];

	}, onChange);
}

@end