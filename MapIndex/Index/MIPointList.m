//
// MIPointList.m
//
// Copyright (c) 2013 Shemet Dmitriy
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

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
