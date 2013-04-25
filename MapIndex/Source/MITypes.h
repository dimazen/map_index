//
//  MITypes.h
//  MapIndex
//
//  Created by dshe on 04/23/13.
//  Copyright (c) 2013 dshe. All rights reserved.
//

#if !defined(_MITypes_H_)
#define _MITypes_H_

#import <MapKit/MKGeometry.h>

static const unsigned char MIZoomDepth = 20;

#if !defined(MI_INLINE)
#define MI_INLINE static __inline__ __attribute__((always_inline))
#endif

#if !defined(MI_EXTERN)
#define MI_EXTERN extern
#endif

#define MI_ASSERT
#if defined(MI_ASSERT)
#define MIAssert1(condition, desc, arg) NSAssert((condition), (desc), (arg))
#define MIAssert2(condition, desc, arg1, arg2) NSAssert((condition), (desc), (arg1), (arg2))
#define MIAssert3(condition, desc, arg1, arg2, arg3) NSAssert((condition), (desc), (arg1), (arg2), (arg3))
#else
#define MIAssert1(condition, desc, arg)
#define MIAssert2(condition, desc, arg1, arg2)
#define MIAssert3(condition, desc, arg1, arg2, arg3)
#endif

/**
* Traverse callback
*/
typedef void (*MITraverseCallback)(MKMapPoint point, void *payload, void *context);

#endif
