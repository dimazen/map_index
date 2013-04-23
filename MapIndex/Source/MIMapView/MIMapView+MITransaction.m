/**
 * Created with JetBrains AppCode.
 * Author: dmitriy
 * Date: 19.04.13 11:27
 */

#import "MIMapView+MITransaction.h"

@implementation MIMapView (MITransaction)

#pragma mark - Lock

- (void)lock
{
	NSAssert(!_flags.locked, @"%@: Already locked", self);
	NSAssert(_activeTransaction != nil, @"%@: Invalid lock: nil transaction", self);
	_flags.locked = YES;
}

- (void)unlock
{
	NSAssert(_flags.locked, @"%@: Already unlocked", self);
	NSAssert(_activeTransaction != nil, @"%@: Invalid unlock: nil transaction", self);

	_flags.locked = NO;

	_activeTransaction = nil;

	if (_modificationActions.count > 0)
	{
		[self setNeedsUpdateAnnotations];
	}
}

- (BOOL)isLocked
{
	return _flags.locked;
}

#pragma mark - Transaction Actions

- (void)addTransactionAnnotation:(id <MKAnnotation>)annotation
{
	[super addAnnotation:annotation];
}

- (void)addTransactionAnnotations:(NSArray *)annotations
{
	[super addAnnotations:annotations];
}

- (void)removeTransactionAnnotation:(id <MKAnnotation>)annotation
{
	[super removeAnnotation:annotation];
}

- (void)removeTransactionAnnotations:(NSArray *)annotations
{
	[super removeAnnotations:annotations];
}

@end