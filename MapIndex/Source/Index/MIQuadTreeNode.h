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
#import "MIListElement.h"

typedef struct MIQuadTreeNode *MIQuadTreeNodeRef;

MI_EXTERN MIQuadTreeNodeRef MIQuadTreeNodeCreate(MKMapRect rect, unsigned char level);
MI_EXTERN void MIQuadTreeNodeFree(MIQuadTreeNodeRef node);

MI_EXTERN void MIQuadTreeNodeInsertPoint(MIQuadTreeNodeRef node, MKMapPoint point, void *payload);
MI_EXTERN void MIQuadTreeNodeRemovePoint(MIQuadTreeNodeRef node, MKMapPoint point, void *payload);

MI_EXTERN void MIQuadTreeNodeTraversRectPoints(MIQuadTreeNodeRef node, MKMapRect rect, unsigned char traversLevel, MITraverseCallback callback, void *context);
MI_EXTERN void MIQuadTreeNodeTraversAllPoints(MIQuadTreeNodeRef node, MITraverseCallback callback);

#endif
