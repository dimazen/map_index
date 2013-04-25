//
//  Geometry.h
//  SDMapView
//
//  Created by dshe on 04/14/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#if !defined(_MapIndex_Utility_)
#define _MapIndex_Utility_

#import "MITypes.h"

MI_INLINE MKMapPoint MKMapRectCenter(MKMapRect rect)
{
	return (MKMapPoint){rect.origin.x + rect.size.width * 0.5, rect.origin.y + rect.size.height * 0.5};
}

#endif
