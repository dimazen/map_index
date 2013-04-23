//
//  QuadTreeNode.c
//  SDMapView
//
//  Created by dshe on 04/14/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "MIQuadTreeNode.h"
#import "MITypes.h"

const char _MIQuadTreeNodePointsLimit = 1;

#pragma mark - Creation

void _MIQuadTreeNodePullPoint(MIQuadTreeNode *source, MIQuadTreeNode *target)
{
	target->list = source->list;
	source->list = NULL;

	target->count = source->count;
}

MIQuadTreeNode * _MIQuadTreeNodeCreate(MIQuadTreeNode *node, MKMapRect rect, unsigned char level)
{
	node->rect = rect;
	node->level = level;

	return node;
}

MIQuadTreeNode * MIQuadTreeNodeCreate(MKMapRect rect, unsigned char level)
{
	MIQuadTreeNode *node = malloc(sizeof(MIQuadTreeNode));

	node->topLeftLeaf = NULL;
	node->topRightLeaf = NULL;
	node->bottomLeftLeaf = NULL;
	node->bottomRightLeaf = NULL;

	node->rect = rect;
	node->centroid = (MKMapPoint){0.0, 0.0};

	node->list = NULL;

	node->count = 0;

	node->level = level;

	return node;
}

void MIQuadTreeNodeFree(MIQuadTreeNode *node)
{
	if (node->topLeftLeaf == NULL)
	{
		MIQuadTreeNodeFree(node->topLeftLeaf);
		MIQuadTreeNodeFree(node->topRightLeaf);
		MIQuadTreeNodeFree(node->bottomLeftLeaf);
		MIQuadTreeNodeFree(node->bottomRightLeaf);
	}

	MIListNode *listNode = node->list;
	while (listNode != NULL)
	{
		MIListNode *tempPtr = listNode;
		listNode = listNode->nextNode;

	}

	free(node);
}

#pragma mark - Private

MKMapRect _MIQuadTreeNodeLeafRect(MIQuadTreeNode *node, char index)
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

void _MIQuadTreeNodeSubdivide(MIQuadTreeNode *node)
{
	static size_t leavesSize = sizeof(MIQuadTreeNode) * 4;
	void *leaves = malloc(leavesSize);
	memset(leaves, 0, leavesSize);

	unsigned char level = node->level + 1;

	node->topLeftLeaf = _MIQuadTreeNodeCreate(leaves, _MIQuadTreeNodeLeafRect(node, 0), level);
	node->topRightLeaf = _MIQuadTreeNodeCreate(leaves + sizeof(MIQuadTreeNode), _MIQuadTreeNodeLeafRect(node, 1), level);
	node->bottomLeftLeaf = _MIQuadTreeNodeCreate(leaves + sizeof(MIQuadTreeNode) * 2,_MIQuadTreeNodeLeafRect(node, 2), level);
	node->bottomRightLeaf = _MIQuadTreeNodeCreate(leaves + sizeof(MIQuadTreeNode) * 3,_MIQuadTreeNodeLeafRect(node, 3), level);
}

MI_INLINE MIQuadTreeNode *_MIQuadTreeNodePointToLeafPtr(MIQuadTreeNode *node, MKMapPoint point)
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

void _MIQuadTreeNodeInsertPoint(MIQuadTreeNode *node, MKMapPoint point, void *payload)
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

		if (node->list != NULL)
		{
			_MIQuadTreeNodePullPoint(node, _MIQuadTreeNodePointToLeafPtr(node, node->list->point));
		}

		_MIQuadTreeNodeInsertPoint(_MIQuadTreeNodePointToLeafPtr(node, point), point, payload);
	}
	else
	{
		MIListNode *listNode = MIListNodeCreate(point, payload);
		listNode->nextNode = node->list;
		node->list = listNode;
	}
}

void MIQuadTreeNodeInsertPoint(MIQuadTreeNode *node, MKMapPoint point, void *payload)
{
	if (!MKMapRectContainsPoint(node->rect, point)) return;

	_MIQuadTreeNodeInsertPoint(node, point, payload);
}

void MIQuadTreeNodeRemovePoint(MIQuadTreeNode *node, MKMapPoint point, void *payload)
{

}

#pragma mark - Visiting

void MIQuadTreeNodeTraversRectPoints(MIQuadTreeNode *node, MKMapRect rect, unsigned char traversLevel, MITraverseCallback callback, void *context)
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
		MIListNode *listNode = node->list;
		while (listNode != NULL)
		{
			if (MKMapRectContainsPoint(node->rect, listNode->point))
			{
				callback(listNode->point, listNode->payload, NULL);
				listNode = listNode->nextNode;
			}
		}
	}
}

void MIQuadTreeNodeTraversAllPoints(MIQuadTreeNode *node, MITraverseCallback callback)
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
		MIListNode *listNode = node->list;
		while (listNode != NULL)
		{
			callback(listNode->point, listNode->payload, NULL);
			listNode = listNode->nextNode;
		}
	}
}


