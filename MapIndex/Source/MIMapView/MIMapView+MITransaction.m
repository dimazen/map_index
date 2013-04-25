/**
 * Created with JetBrains AppCode.
 * Author: dmitriy
 * Date: 19.04.13 11:27
 */

#import "MIMapView+MITransaction.h"

#import "MITransaction.h"
#import "MITypes.h"

@implementation MIMapView (MITransaction)

#pragma mark - Lock

- (void)lock:(MITransaction *)lockTransaction
{
	MIAssert1(!_flags.locked, @"%p: Already locked", (__bridge void *)self);
	MIAssert1(_activeTransaction != nil, @"%p: Invalid lock: nil transaction", (__bridge void *)self);
	MIAssert3(_activeTransaction == lockTransaction, @"%p: Invalid lock transaction: %@ while active:%@", (__bridge void *)self, lockTransaction, _activeTransaction);

	_flags.locked = YES;
}

- (void)unlock:(MITransaction *)lockTransaction
{
	MIAssert1(_flags.locked, @"%p: Already unlocked", (__bridge void *)self);
	MIAssert1(_activeTransaction != nil, @"%p: Invalid unlock: nil transaction", (__bridge void *)self);
	MIAssert3(_activeTransaction == lockTransaction, @"%p: Invalid unlock transaction: %@ while active:%@", (__bridge void *)self, lockTransaction, _activeTransaction);

	_flags.locked = NO;

	_activeTransaction = nil;

	if (_modificationActions.count > 0)
	{
		[self setUpdateAnnotationsIfNeeded];
	}
}

- (BOOL)isLocked
{
	return _flags.locked;
}

#pragma mark - Transaction Actions

- (void)transaction:(MITransaction *)transaction addAnnotation:(id <MKAnnotation>)annotation
{
	if (annotation != nil)
	{
		MIAssert3(_activeTransaction == transaction, @"%p: Invalid change transaction: %@ while active:%@", (__bridge void *)self, transaction, _activeTransaction);
	}

	[super addAnnotation:annotation];
}

- (void)transaction:(MITransaction *)transaction addAnnotations:(NSArray *)annotations
{
	if (annotations.count > 0)
	{
		MIAssert3(_activeTransaction == transaction, @"%p: Invalid change transaction: %@ while active:%@", (__bridge void *)self, transaction, _activeTransaction);
	}

	[super addAnnotations:annotations];
}

- (void)transaction:(MITransaction *)transaction removeAnnotation:(id <MKAnnotation>)annotation
{
	if (annotation != nil)
	{
		MIAssert3(_activeTransaction == transaction, @"%p: Invalid change transaction: %@ while active:%@", (__bridge void *)self, transaction, _activeTransaction);
	}

	[super removeAnnotation:annotation];
}

- (void)transaction:(MITransaction *)transaction removeAnnotations:(NSArray *)annotations
{
	if (annotations.count > 0)
	{
		MIAssert3(_activeTransaction == transaction, @"%p: Invalid change transaction: %@ while active:%@", (__bridge void *)self, transaction, _activeTransaction);
	}

	[super removeAnnotations:annotations];
}

@end