//
// MITypes.h
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

#import <MapKit/MKGeometry.h>

static const unsigned char MIZoomDepth = 20;
static const unsigned char MIZoomDepthIncrement = 1;
static const NSUInteger MIMinimumZoomDepth = 2;
static const double MIMercatorRadius = 85445659.44705395;

#if !defined(MI_INLINE)
#define MI_INLINE static __inline__ __attribute__((always_inline))
#endif

#if !defined(MI_EXTERN)
#define MI_EXTERN extern
#endif

#if defined(DEBUG)
#define MI_ASSERT 1
#endif

#if MI_ASSERT == 1
#define MIAssert1(condition, desc, arg) NSAssert((condition), (desc), (arg))
#define MIAssert2(condition, desc, arg1, arg2) NSAssert((condition), (desc), (arg1), (arg2))
#define MIAssert3(condition, desc, arg1, arg2, arg3) NSAssert((condition), (desc), (arg1), (arg2), (arg3))
#else
#define MIAssert1(condition, desc, arg)
#define MIAssert2(condition, desc, arg1, arg2)
#define MIAssert3(condition, desc, arg1, arg2, arg3)
#endif


#if defined(DEBUG)
#define MI_C_PARAM_ASSERT 1
#endif

#if MI_C_PARAM_ASSERT == 1
#define MICParameterAssert(condition) NSCParameterAssert(condition)
#else
#define MICParameterAssert(condition)
#endif