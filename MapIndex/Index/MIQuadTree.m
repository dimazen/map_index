//
// MIQuadTree.m
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

#import <MapKit/MapKit.h>

#import "MIQuadTree.h"

const char _MIQuadTreePointsLimit = 1; // Point-Region QuadTree

struct MIQuadTree
{
	MIQuadTreeRef topLeftLeaf;
	MIQuadTreeRef topRightLeaf;
	MIQuadTreeRef bottomLeftLeaf;
	MIQuadTreeRef bottomRightLeaf;

	MKMapPoint centroid;
	MKMapRect rect;

	MIPointListRef pointList;
	unsigned int count;

	unsigned int level;
	MIQuadTreeRef root;
};

#pragma mark - Creation

MIQuadTreeRef _MIQuadTreeCreate(MIQuadTreeRef tree, MIQuadTreeRef root, MKMapRect rect, unsigned int level)
{
	tree->rect = rect;
	tree->level = level;
	tree->root = root;

	return tree;
}

MIQuadTreeRef MIQuadTreeCreate(MKMapRect rect)
{
	MIQuadTreeRef tree = malloc(sizeof(struct MIQuadTree));

	tree->topLeftLeaf = NULL;
	tree->topRightLeaf = NULL;
	tree->bottomLeftLeaf = NULL;
	tree->bottomRightLeaf = NULL;

	tree->rect = rect;
	tree->centroid = (MKMapPoint){0.0, 0.0};

	tree->pointList = NULL;
	tree->count = 0;

	tree->level = 0;
	tree->root = NULL;

	return tree;
}

#pragma mark - Free

void _MIQuadTreeFree(MIQuadTreeRef tree)
{
	if (tree->topLeftLeaf != NULL)
	{
		_MIQuadTreeFree(tree->topLeftLeaf);
		_MIQuadTreeFree(tree->topRightLeaf);
		_MIQuadTreeFree(tree->bottomLeftLeaf);
		_MIQuadTreeFree(tree->bottomRightLeaf);

		free(tree->topLeftLeaf);

		tree->topLeftLeaf = NULL;
		tree->topRightLeaf = NULL;
		tree->bottomLeftLeaf = NULL;
		tree->bottomRightLeaf = NULL;
	}

	if (tree->pointList != NULL)
	{
		tree->pointList = MIPointListDeleteAll(tree->pointList);
	}
}

void MIQuadTreeFree(MIQuadTreeRef tree)
{
	_MIQuadTreeFree(tree);

	free(tree);
}

#pragma mark - Transformations

MKMapRect _MIQuadTreeLeafRect(MIQuadTreeRef tree, char index)
{
	double halfWidth = tree->rect.size.width * 0.5;
	double halfHeight = tree->rect.size.height * 0.5;

	MKMapRect result = (MKMapRect){tree->rect.origin, halfWidth, halfHeight};
	if ((index & 1) > 0)
	{
		result.origin.x += halfWidth;
	}

	if ((index & 2) > 0)
	{
		result.origin.y += halfHeight;
	}

	return result;
}

MI_INLINE MIQuadTreeRef _MIQuadTreePointToLeaf(MIQuadTreeRef tree, MKMapPoint point)
{
	MKMapPoint center = MKMapRectCenter(tree->rect);

	if (point.x < center.x)
	{
		if (point.y < center.y) return tree->topLeftLeaf;

		return tree->bottomLeftLeaf;
	}
	else
	{
		if (point.y < center.y) return tree->topRightLeaf;

		return tree->bottomRightLeaf;
	}
}

unsigned int MIQuadTreeGetCount(MIQuadTreeRef tree)
{
	return tree->count;
}

MKMapPoint MIQuadTreeGetCentroid(MIQuadTreeRef tree)
{
	return tree->centroid;
}

#pragma mark - Subdivide

void _MIQuadTreeNodePullPoint(MIQuadTreeRef source, MIQuadTreeRef target)
{
	target->pointList = source->pointList;
	source->pointList = NULL;

	target->centroid = (MKMapPoint){target->pointList->point.x, target->pointList->point.y};
	target->count = _MIQuadTreePointsLimit;
}


void _MIQuadTreeSubdivide(MIQuadTreeRef tree)
{
	void *leaves = calloc(4, sizeof(struct MIQuadTree));

	unsigned int level = tree->level + 1;

	tree->topLeftLeaf = _MIQuadTreeCreate(leaves, tree, _MIQuadTreeLeafRect(tree, 0), level);
	tree->topRightLeaf = _MIQuadTreeCreate(leaves + sizeof(struct MIQuadTree), tree, _MIQuadTreeLeafRect(tree, 1), level);
	tree->bottomLeftLeaf = _MIQuadTreeCreate(leaves + sizeof(struct MIQuadTree) * 2, tree, _MIQuadTreeLeafRect(tree, 2), level);
	tree->bottomRightLeaf = _MIQuadTreeCreate(leaves + sizeof(struct MIQuadTree) * 3, tree, _MIQuadTreeLeafRect(tree, 3), level);
}

#pragma mark - Insertion

void _MIQuadTreeInsertPoint(MIQuadTreeRef tree, MIPoint point)
{
	tree->count++;

	tree->centroid.x += (point.x - tree->centroid.x) / tree->count;
	tree->centroid.y += (point.y - tree->centroid.y) / tree->count;

	MICParameterAssert(MKMapRectContainsPoint(tree->rect, tree->centroid));

	if (tree->topLeftLeaf != NULL)
	{
		_MIQuadTreeInsertPoint(_MIQuadTreePointToLeaf(tree, (MKMapPoint){point.x, point.y}), point);

		return;
	}

	if (_MIQuadTreePointsLimit < (tree->count) && tree->level < MIZoomDepth)
	{
		_MIQuadTreeSubdivide(tree);

		if (tree->pointList != NULL)
		{
			_MIQuadTreeNodePullPoint(tree, _MIQuadTreePointToLeaf(tree, (MKMapPoint){tree->pointList->point.x, tree->pointList->point.y}));
		}

		_MIQuadTreeInsertPoint(_MIQuadTreePointToLeaf(tree, (MKMapPoint){point.x, point.y}), point);
	}
	else
	{
		tree->pointList = MIPointListCreate(point, tree->pointList);
		MICParameterAssert(tree->count == MIPointListCount(tree->pointList));
	}
}

void MIQuadTreeInsertPoint(MIQuadTreeRef tree, MIPoint point)
{
	if (!MKMapRectContainsPoint(tree->rect, (MKMapPoint){point.x, point.y})) return;

	_MIQuadTreeInsertPoint(tree, point);
}

#pragma mark - Remove

void _MIQuadTreeRemovePoint(MIQuadTreeRef tree, MIPoint point)
{
	MICParameterAssert((long long) tree->count - 1 >= 0);

	tree->count--;

	if (tree->count > 0)
	{
		tree->centroid.x -= (point.x - tree->centroid.x ) / tree->count;
		tree->centroid.y -= (point.y - tree->centroid.y) / tree->count;
	}
	else
	{
		tree->centroid.x = 0.0;
		tree->centroid.y = 0.0;

		_MIQuadTreeFree(tree);

		return;
	}

	if (tree->topLeftLeaf != nil)
	{
		_MIQuadTreeRemovePoint(_MIQuadTreePointToLeaf(tree, (MKMapPoint){point.x, point.y}), point);
	}
	else
	{
		MICParameterAssert(MIPointListContains(tree->pointList, point.identifier));
		tree->pointList = MIPointListDelete(tree->pointList, point.identifier);
	}
}

void MIQuadTreeRemovePoint(MIQuadTreeRef tree, MIPoint point)
{
	if (tree->count == 0 || !MKMapRectContainsPoint(tree->rect, (MKMapPoint){point.x, point.y})) return;

	_MIQuadTreeRemovePoint(tree, point);
}

void MIQuadTreeRemoveAllPoints(MIQuadTreeRef tree)
{
	_MIQuadTreeFree(tree);

	tree->centroid = (MKMapPoint){0.0, 0.0};
	tree->count = 0;
}

#pragma mark - Traversing

MIPoint MIQuadTreeAnyPoint(MIQuadTreeRef tree)
{
	if (tree->count == 0) return (MIPoint){0.0, 0.0, NULL};

	if (tree->topLeftLeaf != NULL)
	{
		if (tree->topLeftLeaf->count > 0)
		{
			return MIQuadTreeAnyPoint(tree->topLeftLeaf);
		}
		else if (tree->topRightLeaf->count > 0)
		{
			return MIQuadTreeAnyPoint(tree->topRightLeaf);
		}
		else if (tree->bottomLeftLeaf->count > 0)
		{
			return MIQuadTreeAnyPoint(tree->bottomLeftLeaf);
		}
		else if (tree->bottomRightLeaf->count > 0)
		{
			return MIQuadTreeAnyPoint(tree->bottomRightLeaf);
		}
	}

	MICParameterAssert(tree->pointList != NULL);

	return tree->pointList->point;
}

void MIQuadTreeTraversLevelRectPoints(MIQuadTreeRef tree, MKMapRect rect, unsigned int level, MITraverse *traverse)
{
	if (tree->count == 0 || !MKMapRectIntersectsRect(tree->rect, rect)) return;

	if (tree->topLeftLeaf != NULL && tree->level < level)
	{
		MIQuadTreeTraversLevelRectPoints(tree->topLeftLeaf, rect, level, traverse);
		MIQuadTreeTraversLevelRectPoints(tree->topRightLeaf, rect, level, traverse);
		MIQuadTreeTraversLevelRectPoints(tree->bottomLeftLeaf, rect, level, traverse);
		MIQuadTreeTraversLevelRectPoints(tree->bottomRightLeaf, rect, level, traverse);

		return;
	}

	if (tree->count > _MIQuadTreePointsLimit)
	{
		traverse->callback((MIPoint){tree->centroid.x, tree->centroid.y, tree}, MITraverseResultTree, traverse);
	}
	else if (MKMapRectContainsPoint(rect, (MKMapPoint){tree->pointList->point.x, tree->pointList->point.y}))
	{
		traverse->callback(tree->pointList->point, MITraverseResultPoint, traverse);
	}
}

void MIQuadTreeTraversRectPoints(MIQuadTreeRef tree, MKMapRect rect, MITraverse *traverse)
{
	if (tree->count == 0 || !MKMapRectIntersectsRect(tree->rect, rect)) return;

	if (tree->topLeftLeaf != NULL)
	{
		MIQuadTreeTraversRectPoints(tree->topLeftLeaf, rect, traverse);
		MIQuadTreeTraversRectPoints(tree->topRightLeaf, rect, traverse);
		MIQuadTreeTraversRectPoints(tree->bottomLeftLeaf, rect, traverse);
		MIQuadTreeTraversRectPoints(tree->bottomRightLeaf, rect, traverse);

		return;
	}

	MICParameterAssert(tree->pointList != NULL);

	MIPointListRef head = tree->pointList;
	while (head != NULL)
	{
		if (MKMapRectContainsPoint(tree->rect, (MKMapPoint){head->point.x, head->point.y}))
		{
			traverse->callback(head->point, MITraverseResultPoint, traverse);
			head = head->nextElement;
		}
	}
}

void MIQuadTreeTraversPoints(MIQuadTreeRef tree, MITraverse *traverse)
{
	if (tree->count == 0) return;

	if (tree->topLeftLeaf != NULL)
	{
		MIQuadTreeTraversPoints(tree->topLeftLeaf, traverse);
		MIQuadTreeTraversPoints(tree->topRightLeaf, traverse);
		MIQuadTreeTraversPoints(tree->bottomLeftLeaf, traverse);
		MIQuadTreeTraversPoints(tree->bottomRightLeaf, traverse);

		return;
	}

	MICParameterAssert(tree->pointList != NULL);

	MIPointListRef head = tree->pointList;
	while (head != NULL)
	{
		traverse->callback(head->point, MITraverseResultPoint, traverse);
		head = head->nextElement;
	}
}

#pragma mark - Containment

bool MIQuadTreeIsDescendant(MIQuadTreeRef root, MIQuadTreeRef leaf)
{
	if (!MKMapRectContainsRect(root->rect, leaf->rect)) return false;

	while (leaf != NULL)
	{
		if (leaf == root) return true;

		leaf = leaf->root;
	}

	return false;
}

bool _MIQuadTreeContainsPoint(MIQuadTreeRef node, MIPoint point)
{
	if (node->topLeftLeaf != NULL)
	{
		return _MIQuadTreeContainsPoint(_MIQuadTreePointToLeaf(node, (MKMapPoint){point.x, point.y}), point);
	}

	return MIPointListContains(node->pointList, point.identifier);
}

bool MIQuadTreeContainsPoint(MIQuadTreeRef node, MIPoint point)
{
	if (node->count == 0 || !MKMapRectContainsPoint(node->rect, (MKMapPoint){point.x, point.y})) return false;

	return _MIQuadTreeContainsPoint(node, point);
}