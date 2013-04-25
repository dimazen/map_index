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

bool MIListElementContainsPoint(MIListElementRef head, void *payload)
{
	while (head != NULL)
	{
		if (head->payload == payload) return true;

		head = head->nextElement;
	}

	return false;
}

MIListElementRef MIListElementDelete(MIListElementRef head, void *payload)
{
	MIListElementRef traverse = head;
	MIListElementRef previous = NULL;

	while (traverse != NULL)
	{
		if (traverse->payload == payload)
		{
			if (traverse != head)
			{
				previous->nextElement = traverse->nextElement;
			}
			else
			{
				head = traverse->nextElement;
			}

			MIListElementFree(traverse);
			break;
		}
		else
		{
			previous = traverse;
			traverse = traverse->nextElement;
		}
	}

	return head;
}

MIListElementRef MIListElementDeleteAll(MIListElementRef head)
{
	while (head != NULL)
	{
		MIListElementRef elementToRemove = head;
		head = head->nextElement;
		MIListElementFree(elementToRemove);
	}

	return NULL;
}
