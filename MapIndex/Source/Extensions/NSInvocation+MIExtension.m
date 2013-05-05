//
// Created by dmitriy on 25.03.13.
//
#import "NSInvocation+MIExtension.h"

@implementation NSInvocation (MIExtension)

- (void)setArguments:(id)args, ... __attribute__((sentinel))
{
	va_list list;
	va_start(list, args);

	NSInteger index = 2;
	while (args != nil)
	{
		[self setArgument:&args atIndex:index++];
		args = va_arg(list, id);
	}

	va_end(list);
}

+ (NSInvocation *)invocationForTarget:(id)target
							 selector:(SEL)selector
{
	NSMethodSignature *methodSignature = [target methodSignatureForSelector:selector];
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
	[invocation setTarget:target];
	[invocation setSelector:selector];

	return invocation;
}

+ (NSInvocation *)invocationForTarget:(id)target
							 selector:(SEL)selector
							arguments:(id)args, ... __attribute__((sentinel))
{
	NSInvocation *invocation = [self invocationForTarget:target selector:selector];

	va_list list;
	va_start(list, args);

	NSInteger index = 2;
	while (args != nil)
	{
		[invocation setArgument:&args atIndex:index++];
		args = va_arg(list, id);
	}

	va_end(list);

	return invocation;
}

@end