//
// Created by dmitriy on 26.03.13.
//
#import <Foundation/Foundation.h>

#import "MITransaction.h"

@interface MITransactionFactory : NSObject

- (MITransaction *)transactionWithTarget:(NSArray *)target source:(NSArray *)source order:(NSComparisonResult)order;

@end