//
//  MIPoint.h
//  MapIndex
//
//  Created by dshe on 04/28/13.
//  Copyright (c) 2013 dshe. All rights reserved.
//

#import "MITypes.h"

struct MIPoint
{
	double x;
	double y;

	void *identifier;
};

typedef struct MIPoint MIPoint;

MI_INLINE MIPoint MIPointMake(MKMapPoint coordinate, void *identifier)
{
	return (MIPoint){coordinate.x, coordinate.y, identifier};
}