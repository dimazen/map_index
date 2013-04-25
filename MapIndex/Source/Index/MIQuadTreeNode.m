//
//  QuadTreeNode.c
//  SDMapView
//
//  Created by dshe on 04/14/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "MIQuadTreeNode.h"
#import "MITypes.h"
#import "MIListElement.h"

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

	unsigned char level;
};

#pragma mark - Creation

void _MIQuadTreeNodePullPoint(MIQuadTreeNodeRef source, MIQuadTreeNodeRef target)
{
	target->listHead = source->listHead;
	source->listHead = NULL;

	target->count = source->count;
}

MIQuadTreeNodeRef _MIQuadTreeNodeCreate(MIQuadTreeNodeRef node, MKMapRect rect, unsigned char level)
{
	node->rect = rect;
	node->level = level;

	return node;
}

MIQuadTreeNodeRef MIQuadTreeNodeCreate(MKMapRect rect, unsigned char level)
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

	node->level = level;

	return node;
}

void MIQuadTreeNodeFree(MIQuadTreeNodeRef node)
{
	if (node->topLeftLeaf == NULL)
	{
		// fixme: rewrite remove due to single pointer
		MIQuadTreeNodeFree(node->topLeftLeaf);
		MIQuadTreeNodeFree(node->topRightLeaf);
		MIQuadTreeNodeFree(node->bottomLeftLeaf);
		MIQuadTreeNodeFree(node->bottomRightLeaf);
	}

	if (node->listHead != NULL)
	{
		MIListElementDeleteAll(node->listHead);
	}

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

	unsigned char level = node->level + 1;

	node->topLeftLeaf = _MIQuadTreeNodeCreate(leaves, _MIQuadTreeNodeLeafRect(node, 0), level);
	node->topRightLeaf = _MIQuadTreeNodeCreate(leaves + sizeof(struct MIQuadTreeNode), _MIQuadTreeNodeLeafRect(node, 1), level);
	node->bottomLeftLeaf = _MIQuadTreeNodeCreate(leaves + sizeof(struct MIQuadTreeNode) * 2,_MIQuadTreeNodeLeafRect(node, 2), level);
	node->bottomRightLeaf = _MIQuadTreeNodeCreate(leaves + sizeof(struct MIQuadTreeNode) * 3,_MIQuadTreeNodeLeafRect(node, 3), level);
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
	if (node->count == 0) return;

	if (node->topLeftLeaf != nil)
	{
		_MIQuadTreeNodeRemovePoint(_MIQuadTreeNodePointToLeafPtr(node, point), point, payload);
	}
	else
	{
		// fixme: add list remove
	}
}

void MIQuadTreeNodeRemovePoint(MIQuadTreeNodeRef node, MKMapPoint point, void *payload)
{
	if (!MKMapRectContainsPoint(node->rect, point)) return;

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
				callback(listHead->point, listHead->payload, NULL);
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