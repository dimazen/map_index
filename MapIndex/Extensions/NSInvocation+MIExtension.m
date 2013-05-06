//
// NSInvocation+MIExtension.m
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