//
//  LinkedListNode.h
//  SDMapView
//
//  Created by dshe on 04/14/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "MIUtility.h"

struct MIListNode
{
	MKMapPoint point;
	void *payload;

	struct MIListNode *nextNode;
};

typedef struct MIListNode MIListNode;

MI_EXTERN MIListNode * MIListNodeCreate(MKMapPoint point, void *payload);
