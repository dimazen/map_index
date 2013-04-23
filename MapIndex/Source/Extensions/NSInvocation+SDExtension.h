//
// Created by dmitriy on 25.03.13.
//
#import <Foundation/Foundation.h>

@interface NSInvocation (SDExtension)

- (void)setArguments:(id)args, ... __attribute__((sentinel));

+ (NSInvocation *)invocationForTarget:(id)target
							 selector:(SEL)selector;

+ (NSInvocation *)invocationForTarget:(id)target
							 selector:(SEL)selector
							arguments:(id)args, ... __attribute__((sentinel));

@end