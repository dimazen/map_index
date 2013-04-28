//
//  LinkedListNode.c
//  SDMapView
//
//  Created by dshe on 04/14/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "MIPointList.h"

MIPointListRef MIPointListCreate(MIPoint point, MIPointListRef nextElement)
{
	MIPointListRef list = malloc(sizeof(struct MIPointList));
	if (list == NULL)
	{
		printf("OUT OF MEMORY");
		abort();
	}

	list->point = point;
	list->nextElement = nextElement;

	return list;
}

bool MIPointListContains(MIPointListRef head, void *identifier)
{
	while (head != NULL)
	{
		if (head->point.identifier == identifier) return true;

		head = head->nextElement;
	}

	return false;
}

MIPointListRef MIPointListDelete(MIPointListRef head, void *identifier)
{
	MIPointListRef traverse = head;
	MIPointListRef previous = NULL;

	while (traverse != NULL)
	{
		if (traverse->point.identifier == identifier)
		{
			if (traverse != head)
			{
				previous->nextElement = traverse->nextElement;
			}
			else
			{
				head = traverse->nextElement;
			}

			MIPointListFree(traverse);
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

MIPointListRef MIPointListDeleteAll(MIPointListRef head)
{
	while (head != NULL)
	{
		MIPointListRef elementToRemove = head;
		head = head->nextElement;
		MIPointListFree(elementToRemove);
	}

	return NULL;
}
