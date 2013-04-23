//
// Created by dmitriy on 25.03.13.
//
#import <Foundation/Foundation.h>

@interface NSMutableDictionary (SetInsertion)

- (void)addObject:(id)object toSetForKey:(id <NSCopying>)key;
- (void)removeObject:(id)object fromSetForKey:(id)key;
- (void)removeAllSetObjectsForKey:(id)key;

- (NSMutableSet *)setForKey:(id)key;

@end