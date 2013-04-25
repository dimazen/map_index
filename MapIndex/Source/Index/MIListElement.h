//
//  LinkedListNode.h
//  SDMapView
//
//  Created by dshe on 04/14/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "MIUtility.h"

typedef struct MIListElement *MIListElementRef;

struct MIListElement
{
	MKMapPoint point;
	void *payload;

	MIListElementRef nextElement;
};

MI_INLINE void MIListElementFree(MIListElementRef listElement)
{
	free(listElement);
}

MI_EXTERN MIListElementRef MIListElementCreate(MKMapPoint point, void *payload, MIListElementRef nextElement);

MI_EXTERN bool MIListElementContainsPoint(MIListElementRef head, void *payload);

MI_EXTERN MIListElementRef MIListElementDelete(MIListElementRef head, void *payload);

/**
* Returns NULL
*/
MI_EXTERN MIListElementRef MIListElementDeleteAll(MIListElementRef head);

MI_INLINE unsigned int MIListElementCount(MIListElementRef head)
{
	unsigned int count = 0;
	while (head != NULL)
	{
		count++;
		head = head->nextElement;
	}

	return count;
}