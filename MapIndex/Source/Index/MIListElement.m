//
//  LinkedListNode.c
//  SDMapView
//
//  Created by dshe on 04/14/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "MIListElement.h"

MIListElementRef MIListElementCreate(MKMapPoint point, void *payload, MIListElementRef nextElement)
{
	MIListElementRef node = malloc(sizeof(struct MIListElement));
	if (node == NULL)
	{
		printf("OUT OF MEMORY");
		abort();
	}

	node->point = point;
	node->payload = payload;
	node->nextElement = nextElement;

	return node;
}

MIListElementRef MIListElementDelete(MIListElementRef head, void *payload)
{
	return NULL;
}

MIListElementRef MIListElementDeleteAll(MIListElementRef head)
{


	return NULL;
}
