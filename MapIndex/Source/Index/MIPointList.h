//
//  LinkedListNode.h
//  SDMapView
//
//  Created by dshe on 04/14/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "MIUtility.h"
#import "MIPoint.h"

typedef struct MIPointList *MIPointListRef;

struct MIPointList
{
	MIPoint point;

	MIPointListRef nextElement;
};

MI_INLINE void MIPointListFree(MIPointListRef list)
{
	free(list);
}

MI_EXTERN MIPointListRef MIPointListCreate(MIPoint point, MIPointListRef nextElement);

MI_EXTERN bool MIPointListContains(MIPointListRef head, void *identifier);

MI_EXTERN MIPointListRef MIPointListDelete(MIPointListRef head, void *identifier);

/**
* Returns NULL
*/
MI_EXTERN MIPointListRef MIPointListDeleteAll(MIPointListRef head);

MI_INLINE unsigned int MIPointListCount(MIPointListRef head)
{
	unsigned int count = 0;
	while (head != NULL)
	{
		count++;
		head = head->nextElement;
	}

	return count;
}