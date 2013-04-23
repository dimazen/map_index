//
//  QuadTreeNode.h
//  SDMapView
//
//  Created by dshe on 04/14/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#if !defined(_MI_QuadTreeNode_)
#define _MI_QuadTreeNode_

#import "MIUtility.h"
#import "MIListNode.h"

typedef struct _MIQuadTreeNode MIQuadTreeNode;

struct _MIQuadTreeNode
{
	MIQuadTreeNode *topLeftLeaf;
	MIQuadTreeNode *topRightLeaf;
	MIQuadTreeNode *bottomLeftLeaf;
	MIQuadTreeNode *bottomRightLeaf;

	MKMapPoint centroid;
	MKMapRect rect;

	MIListNode *list;

	unsigned int count;

	unsigned char level;
};

MI_EXTERN MIQuadTreeNode * MIQuadTreeNodeCreate(MKMapRect rect, unsigned char level);
MI_EXTERN void MIQuadTreeNodeFree(MIQuadTreeNode *node);

MI_EXTERN void MIQuadTreeNodeInsertPoint(MIQuadTreeNode *node, MKMapPoint point, void *payload);
MI_EXTERN void MIQuadTreeNodeRemovePoint(MIQuadTreeNode *node, MKMapPoint point, void *payload);

MI_EXTERN void MIQuadTreeNodeTraversRectPoints(MIQuadTreeNode *node, MKMapRect rect, unsigned char traversLevel, MITraverseCallback callback, void *context);
MI_EXTERN void MIQuadTreeNodeTraversAllPoints(MIQuadTreeNode *node, MITraverseCallback callback);

#endif
