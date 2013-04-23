//
//  LinkedListNode.c
//  SDMapView
//
//  Created by dshe on 04/14/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "MIListNode.h"

MIListNode * MIListNodeCreate(MKMapPoint point, void *payload)
{
	MIListNode *node = malloc(sizeof(MIListNode));
	if (node == NULL)
	{
		printf("OUT OF MEMORY");
		abort();
	}

	node->point = point;
	node->payload = payload;

	node->nextNode = NULL;

	return node;
}
