//
// Created by dmitriy on 26.03.13.
//
#import "MITransactionFactory.h"

#import "MIRegularTransaction.h"
#import "MIAscendingTransaction.h"
#import "MIDescendingTransaction.h"

@implementation MITransactionFactory

- (MITransaction *)transactionWithTarget:(NSSet *)target source:(NSSet *)source order:(NSComparisonResult)order
{
	Class transactionClass = nil;
	switch (order)
	{
		case NSOrderedSame:
			transactionClass = [MIRegularTransaction class];
			break;

		case NSOrderedAscending:
			transactionClass = [MIAscendingTransaction class];
			break;

		case NSOrderedDescending:
			transactionClass = [MIDescendingTransaction class];
			break;
	}

	return [[transactionClass alloc] initWithTarget:target source:source order:order];
}

@end