//
// MITransaction.m
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

#import "MITransaction.h"

#import "MIMapView.h"
#import "MIMapView+MITransaction.h"
#import "MITypes.h"

@implementation MITransaction

- (id)initWithTarget:(NSArray *)target source:(NSArray *)source
{
	self = [super init];
	if (self)
	{
		_target = target;
		_source = source;
	}

	return self;
}

- (void)perform
{
	[NSException raise:@"Subclass error" format:@"Subclass should override %@", NSStringFromSelector(_cmd)];
}

- (void)mapView:(MIMapView *)mapView didAddAnnotationViews:(NSArray *)views
{}

@end

@implementation MITransaction (Subclass)

- (void)addAnnotation:(id <MKAnnotation>)annotation
{
	MICParameterAssert(self.mapView != nil);
	[self.mapView transaction:self addAnnotation:annotation];
}

- (void)addAnnotations:(NSArray *)annotations
{
	MICParameterAssert(self.mapView != nil);
	[self.mapView transaction:self addAnnotations:annotations];
}

- (void)removeAnnotation:(id <MKAnnotation>)annotation
{
	MICParameterAssert(self.mapView != nil);
	[self.mapView transaction:self removeAnnotation:annotation];
}

- (void)removeAnnotations:(NSArray *)annotations
{
	MICParameterAssert(self.mapView != nil);
	[self.mapView transaction:self removeAnnotations:annotations];
}

- (void)lock
{
	MICParameterAssert(self.mapView != nil);
	[self.mapView lock:self];
}

- (void)unlock
{
	MICParameterAssert(self.mapView != nil);
	[self.mapView unlock:self];
}

@end