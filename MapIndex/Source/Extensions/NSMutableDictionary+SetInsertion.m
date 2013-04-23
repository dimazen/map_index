//
// Created by dmitriy on 25.03.13.
//
#import "NSMutableDictionary+SetInsertion.h"


@implementation NSMutableDictionary (SetInsertion)

- (void)addObject:(id)object toSetForKey:(id <NSCopying>)key
{
	[[self setForKey:key] addObject:object];
}

- (void)removeObject:(id)object fromSetForKey:(id)key
{
	NSMutableSet *set = [self setForKey:key];
	[set removeObject:key];

	if (set.count == 0)
	{
		[self removeObjectForKey:key];
	}
}

- (void)removeAllSetObjectsForKey:(id)key
{
	[[self setForKey:key] removeAllObjects];
	[self removeObjectForKey:key];
}

- (NSMutableSet *)setForKey:(id)key
{
	NSMutableSet *set = [self objectForKey:key];
	if (set == nil)
	{
		set = [NSMutableSet new];
		[self setObject:set forKey:key];
	}

	return set;
}

@end