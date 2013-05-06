//
// MIPointList.h
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