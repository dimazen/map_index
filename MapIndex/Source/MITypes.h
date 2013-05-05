//
//  MITypes.h
//  MapIndex
//
//  Created by dshe on 04/23/13.
//  Copyright (c) 2013 dshe. All rights reserved.
//

#import <MapKit/MKGeometry.h>

static const unsigned char MIZoomDepth = 20;
static const double MIMercatorRadius = 85445659.44705395;

#if !defined(MI_INLINE)
#define MI_INLINE static __inline__ __attribute__((always_inline))
#endif

#if !defined(MI_EXTERN)
#define MI_EXTERN extern
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

#if MI_C_PARAM_ASSERT == 1
#define MICParameterAssert(condition) NSCParameterAssert(condition)
#else
#define MICParameterAssert(condition)
#endif


#import "MIPoint.h"

/**
* Traverse callback
*/
typedef enum
{
	MITraverseResultPoint,
	MITraverseResultTree
} MITraverseResultType;

typedef struct MITraverse MITraverse;

typedef void (*MITraverseCallback)(MIPoint point, MITraverseResultType resultType, MITraverse *traverse);

struct MITraverse
{
	MITraverseCallback callback;
	void *context;
};