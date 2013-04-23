//
//  Geometry.h
//  SDMapView
//
//  Created by dshe on 04/14/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#if !defined(_MapIndex_Utility_)
#define _MapIndex_Utility_

#import <MapKit/MKGeometry.h>

#if !defined(MI_INLINE)
#define MI_INLINE static __inline__ __attribute__((always_inline))
#endif

#if !defined(MI_EXTERN)
#define MI_EXTERN extern
#endif

MI_INLINE MKMapPoint MKMapRectCenter(MKMapRect rect)
{
	return (MKMapPoint){rect.origin.x + rect.size.width * 0.5, rect.origin.y + rect.size.height * 0.5};
}

/**
* Traverse callback
*/
typedef void (*MITraverseCallback)(MKMapPoint point, void *payload, void *context);

#endif
