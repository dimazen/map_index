/**
 * Created with JetBrains AppCode.
 * Author: dmitriy
 * Date: 28.04.13 17:48
 */

#import "MIMapView+MITransaction.h"

#import "MITypes.h"
#import "MITransaction+MIMapView.h"

@implementation MIMapView (MITransaction)

#pragma mark - Lock

- (void)lock:(MITransaction *)transaction
{
	MIAssert1(!_transactionLock, @"%p: Already locked", (__bridge void *)self);
	MIAssert1(_transaction != nil, @"%p: Invalid lock: nil transaction", (__bridge void *)self);
	MIAssert3(_transaction == transaction, @"%p: Invalid lock transaction: %@ while active:%@", (__bridge void *)self, transaction, _transaction);

	_transactionLock = YES;
}

- (void)unlock:(MITransaction *)transaction
{
	MIAssert1(_transactionLock, @"%p: Already unlocked", (__bridge void *)self);
	MIAssert1(_transaction != nil, @"%p: Invalid unlock: nil transaction", (__bridge void *)self);
	MIAssert3(_transaction == transaction, @"%p: Invalid unlock transaction: %@ while active:%@", (__bridge void *)self, transaction, _transaction);

	_transactionLock = NO;

	[_transaction setMapView:nil];
	_transaction = nil;

	if (_deferredChanges.count > 0)
	{
		[self setUpdateVisibleAnnotations];
	}
}

- (BOOL)isLocked
{
	return _transactionLock;
}

#pragma mark - Transaction Actions

- (void)transaction:(MITransaction *)transaction addAnnotation:(id <MKAnnotation>)annotation
{
	if (annotation != nil)
	{
		MIAssert3(_transaction == transaction, @"%p: Invalid change transaction: %@ while active:%@", (__bridge void *)self, transaction, _transaction);
	}

	[super addAnnotation:annotation];
}

- (void)transaction:(MITransaction *)transaction addAnnotations:(NSArray *)annotations
{
	if (annotations.count > 0)
	{
		MIAssert3(_transaction == transaction, @"%p: Invalid change transaction: %@ while active:%@", (__bridge void *)self, transaction, _transaction);
	}

	[super addAnnotations:annotations];
}

- (void)transaction:(MITransaction *)transaction removeAnnotation:(id <MKAnnotation>)annotation
{
	if (annotation != nil)
	{
		MIAssert3(_transaction == transaction, @"%p: Invalid change transaction: %@ while active:%@", (__bridge void *)self, transaction, _transaction);
	}

	[super removeAnnotation:annotation];
}

- (void)transaction:(MITransaction *)transaction removeAnnotations:(NSArray *)annotations
{
	if (annotations.count > 0)
	{
		MIAssert3(_transaction == transaction, @"%p: Invalid change transaction: %@ while active:%@", (__bridge void *)self, transaction, _transaction);
	}

	[super removeAnnotations:annotations];
}

@end