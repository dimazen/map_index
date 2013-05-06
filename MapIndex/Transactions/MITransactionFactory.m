//
// MITransactionFactory.m
//
// Copyright (c) 2013 Shemet Dmitriy
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "MITransactionFactory.h"

#import "MIRegularTransaction.h"
#import "MIAscendingTransaction.h"
#import "MIDescendingTransaction.h"

@implementation MITransactionFactory

- (MITransaction *)transactionWithTarget:(NSArray *)target source:(NSArray *)source order:(NSComparisonResult)order
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

	return [[transactionClass alloc] initWithTarget:target source:source];
}

@end