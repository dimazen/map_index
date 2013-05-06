//
// MIQuadTree.h
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
#import "MIPointList.h"

typedef struct MIQuadTree *MIQuadTreeRef;

#pragma mark - Creation

MI_EXTERN MIQuadTreeRef MIQuadTreeCreate(MKMapRect rect);

MI_EXTERN void MIQuadTreeFree(MIQuadTreeRef tree);

#pragma mark - Data Access

MI_EXTERN unsigned int MIQuadTreeGetCount(MIQuadTreeRef tree);
MI_EXTERN MKMapPoint MIQuadTreeGetCentroid(MIQuadTreeRef tree);

#pragma mark - Insertion
/**
* If point, presented in tree inserted - behaviour undefined
*/
MI_EXTERN void MIQuadTreeInsertPoint(MIQuadTreeRef tree, MIPoint point);

#pragma mark - Removal
/**
* If point, not presented in tree removed - behaviour undefined
*/
MI_EXTERN void MIQuadTreeRemovePoint(MIQuadTreeRef tree, MIPoint point);
MI_EXTERN void MIQuadTreeRemoveAllPoints(MIQuadTreeRef tree);

#pragma mark - Traversal

/**
* Traverse callback
*/
typedef enum
{
	MITraverseResultPoint,
	MITraverseResultTree
} MITraverseResultType;

typedef struct MITraverse MITraverse;

typedef void (*MITraverseCallback)(MIPoint point, MITraverseResultType resultType, MITraverse *traverse);

struct MITraverse
{
	MITraverseCallback callback;
	void *context;
};

MI_EXTERN MIPoint MIQuadTreeAnyPoint(MIQuadTreeRef tree);
MI_EXTERN void MIQuadTreeTraversLevelRectPoints(MIQuadTreeRef tree, MKMapRect rect, unsigned int level, MITraverse *traverse);
MI_EXTERN void MIQuadTreeTraversRectPoints(MIQuadTreeRef tree, MKMapRect rect, MITraverse *traverse);
MI_EXTERN void MIQuadTreeTraversPoints(MIQuadTreeRef tree, MITraverse *traverse);

#pragma mark - Checks

MI_EXTERN bool MIQuadTreeIsDescendant(MIQuadTreeRef root, MIQuadTreeRef leaf);
MI_EXTERN bool MIQuadTreeContainsPoint(MIQuadTreeRef node, MIPoint point);