//
// Created by dmitriy on 26.03.13.
//
#import <Foundation/Foundation.h>

#import "MITransaction.h"

@interface MITransactionFactory : NSObject

- (MITransaction *)transactionWithTarget:(NSSet *)target
								  source:(NSSet *)source
							 targetLevel:(NSNumber *)targetLevel
							 sourceLevel:(NSNumber *)sourceLevel;

@end