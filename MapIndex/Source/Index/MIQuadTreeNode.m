//
//  QuadTreeNode.c
//  SDMapView
//
//  Created by dshe on 04/14/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "MIQuadTreeNode.h"

const char _MIQuadTreeNodePointsLimit = 1;

struct MIQuadTreeNode
{
	MIQuadTreeNodeRef topLeftLeaf;
	MIQuadTreeNodeRef topRightLeaf;
	MIQuadTreeNodeRef bottomLeftLeaf;
	MIQuadTreeNodeRef bottomRightLeaf;

	MKMapPoint centroid;
	MKMapRect rect;

	MIListElementRef listHead;
	unsigned int count;

	unsigned int level;

	MIQuadTreeNodeRef parent;
};

#pragma mark - Creation

void _MIQuadTreeNodePullPoint(MIQuadTreeNodeRef source, MIQuadTreeNodeRef target)
{
	target->listHead = source->listHead;
	source->listHead = NULL;

	target->count = source->count;
}

MIQuadTreeNodeRef _MIQuadTreeNodeCreate(MIQuadTreeNodeRef node, MIQuadTreeNodeRef parent, MKMapRect rect, unsigned int level)
{
	node->rect = rect;
	node->level = level;
	node->parent = parent;

	return node;
}

MIQuadTreeNodeRef MIQuadTreeNodeCreate(MKMapRect rect)
{
	MIQuadTreeNodeRef node = malloc(sizeof(struct MIQuadTreeNode));

	node->topLeftLeaf = NULL;
	node->topRightLeaf = NULL;
	node->bottomLeftLeaf = NULL;
	node->bottomRightLeaf = NULL;

	node->rect = rect;
	node->centroid = (MKMapPoint){0.0, 0.0};

	node->listHead = NULL;
	node->count = 0;

	node->level = 0;

	node->parent = NULL;

	return node;
}

void _MIQuadTreeNodeFree(MIQuadTreeNodeRef node)
{
	if (node->topLeftLeaf != NULL)
	{
		_MIQuadTreeNodeFree(node->topLeftLeaf);
		_MIQuadTreeNodeFree(node->topRightLeaf);
		_MIQuadTreeNodeFree(node->bottomLeftLeaf);
		_MIQuadTreeNodeFree(node->bottomRightLeaf);

		free(node->topLeftLeaf);
	}

	if (node->listHead != NULL)
	{
		MIListElementDeleteAll(node->listHead);
	}
}

void MIQuadTreeNodeFree(MIQuadTreeNodeRef node)
{
	_MIQuadTreeNodeFree(node);

	free(node);
}

#pragma mark - Private

MKMapRect _MIQuadTreeNodeLeafRect(MIQuadTreeNodeRef node, char index)
{
	MKMapRect rect = node->rect;

	double halfWidth = rect.size.width * 0.5;
	double halfHeight = rect.size.height * 0.5;

	MKMapRect result = (MKMapRect){rect.origin, halfWidth, halfHeight};
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

void _MIQuadTreeNodeSubdivide(MIQuadTreeNodeRef node)
{
	static size_t leavesSize = sizeof(struct MIQuadTreeNode) * 4;
	void *leaves = malloc(leavesSize);
	memset(leaves, 0, leavesSize);

	unsigned int level = node->level + 1;

	node->topLeftLeaf = _MIQuadTreeNodeCreate(leaves, node, _MIQuadTreeNodeLeafRect(node, 0), level);
	node->topRightLeaf = _MIQuadTreeNodeCreate(leaves + sizeof(struct MIQuadTreeNode), node, _MIQuadTreeNodeLeafRect(node, 1), level);
	node->bottomLeftLeaf = _MIQuadTreeNodeCreate(leaves + sizeof(struct MIQuadTreeNode) * 2, node, _MIQuadTreeNodeLeafRect(node, 2), level);
	node->bottomRightLeaf = _MIQuadTreeNodeCreate(leaves + sizeof(struct MIQuadTreeNode) * 3, node, _MIQuadTreeNodeLeafRect(node, 3), level);
}

MI_INLINE MIQuadTreeNodeRef _MIQuadTreeNodePointToLeafPtr(MIQuadTreeNodeRef node, MKMapPoint point)
{
	MKMapPoint center = MKMapRectCenter(node->rect);

	if (point.x < center.x)
	{
		if (point.y < center.y) return node->topLeftLeaf;

		return node->bottomLeftLeaf;
	}
	else
	{
		if (point.y < center.y) return node->topRightLeaf;

		return node->bottomRightLeaf;
	}
}

#pragma mark - Modification

void _MIQuadTreeNodeInsertPoint(MIQuadTreeNodeRef node, MKMapPoint point, void *payload)
{
	node->centroid.x += (point.x - node->centroid.x) / (node->count + 1);
	node->centroid.y = (point.y - node->centroid.y) / (node->count + 1);

	node->count++;

	if (node->topLeftLeaf != NULL)
	{
		_MIQuadTreeNodeInsertPoint(_MIQuadTreeNodePointToLeafPtr(node, point), point, payload);

		return;
	}

	if (_MIQuadTreeNodePointsLimit < (node->count) && node->level < MIZoomDepth)
	{
		_MIQuadTreeNodeSubdivide(node);

		if (node->listHead != NULL)
		{
			_MIQuadTreeNodePullPoint(node, _MIQuadTreeNodePointToLeafPtr(node, node->listHead->point));
		}

		_MIQuadTreeNodeInsertPoint(_MIQuadTreeNodePointToLeafPtr(node, point), point, payload);
	}
	else
	{
		node->listHead = MIListElementCreate(point, payload, node->listHead);
	}
}

void MIQuadTreeNodeInsertPoint(MIQuadTreeNodeRef node, MKMapPoint point, void *payload)
{
	if (!MKMapRectContainsPoint(node->rect, point)) return;

	_MIQuadTreeNodeInsertPoint(node, point, payload);
}

void _MIQuadTreeNodeRemovePoint(MIQuadTreeNodeRef node, MKMapPoint point, void *payload)
{
	NSCParameterAssert(node->count > 0);

	if (node->topLeftLeaf != nil)
	{
		_MIQuadTreeNodeRemovePoint(_MIQuadTreeNodePointToLeafPtr(node, point), point, payload);
	}
	else
	{
		MIListElementDelete(node->listHead, payload);
	}
}

void MIQuadTreeNodeRemovePoint(MIQuadTreeNodeRef node, MKMapPoint point, void *payload)
{
	if (!MKMapRectContainsPoint(node->rect, point) || node->count == 0) return;

	_MIQuadTreeNodeRemovePoint(node, point, payload);
}

#pragma mark - Visiting

void MIQuadTreeNodeTraversRectPoints(MIQuadTreeNodeRef node, MKMapRect rect, unsigned char traversLevel, MITraverseCallback callback, void *context)
{
	if (node->count == 0 || !MKMapRectIntersectsRect(node->rect, rect)) return;

	if (node->topLeftLeaf != NULL)
	{
		MIQuadTreeNodeTraversRectPoints(node->topLeftLeaf, rect, 0, callback, NULL);
		MIQuadTreeNodeTraversRectPoints(node->topRightLeaf, rect, 0, callback, NULL);
		MIQuadTreeNodeTraversRectPoints(node->bottomLeftLeaf, rect, 0, callback, NULL);
		MIQuadTreeNodeTraversRectPoints(node->bottomRightLeaf, rect, 0, callback, NULL);
	}
	else
	{
		MIListElementRef listHead = node->listHead;
		while (listHead != NULL)
		{
			if (MKMapRectContainsPoint(node->rect, listHead->point))
			{
				callback(listHead->point, listHead->payload, context);
				listHead = listHead->nextElement;
			}
		}
	}
}

void MIQuadTreeNodeTraversAllPoints(MIQuadTreeNodeRef node, MITraverseCallback callback)
{
	if (node->count == 0) return;

	if (node->topLeftLeaf != NULL)
	{
		MIQuadTreeNodeTraversAllPoints(node->topLeftLeaf, callback);
		MIQuadTreeNodeTraversAllPoints(node->topRightLeaf, callback);
		MIQuadTreeNodeTraversAllPoints(node->bottomLeftLeaf, callback);
		MIQuadTreeNodeTraversAllPoints(node->bottomRightLeaf, callback);
	}
	else
	{
		MIListElementRef listHead = node->listHead;
		while (listHead != NULL)
		{
			callback(listHead->point, listHead->payload, NULL);
			listHead = listHead->nextElement;
		}
	}
}

#pragma mark - Containment

bool MIQuadTreeNodeIsDescendant(MIQuadTreeNodeRef node, MIQuadTreeNodeRef parent)
{
	if (!MKMapRectContainsRect(parent->rect, node->rect)) return false;

	while (node != NULL)
	{
		if (node == parent) return true;

		node = node->parent;
	}

	return false;
}

bool _MIQuadTreeNodeContainsPoint(MIQuadTreeNodeRef node, MKMapPoint point, void *payload)
{
	if (node->topLeftLeaf != NULL)
	{
		return _MIQuadTreeNodeContainsPoint(_MIQuadTreeNodePointToLeafPtr(node, point), point, payload);
	}

	return MIListElementContainsPoint(node->listHead, payload);
}

bool MIQuadTreeNodeContainsPoint(MIQuadTreeNodeRef node, MKMapPoint point, void *payload)
{
	if (!MKMapRectContainsPoint(node->rect, point) || node->count == 0) return false;

	return _MIQuadTreeNodeContainsPoint(node, point, payload);
}