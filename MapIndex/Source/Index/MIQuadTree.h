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
#import "MIPointList.h"

typedef struct MIQuadTree *MIQuadTreeRef;

MI_EXTERN MIQuadTreeRef MIQuadTreeCreate(MKMapRect rect);
MI_EXTERN void MIQuadTreeFree(MIQuadTreeRef tree);

/**
* If point, presented in tree inserted - behaviour undefined
*/
MI_EXTERN void MIQuadTreeInsertPoint(MIQuadTreeRef tree, MIPoint point);

/**
* If point, not presented in tree removed - behaviour undefined
*/
MI_EXTERN void MIQuadTreeRemovePoint(MIQuadTreeRef tree, MIPoint point);
MI_EXTERN void MIQuadTreeRemoveAllPoints(MIQuadTreeRef tree);

MI_EXTERN void MIQuadTreeTraversLevelRectPoints(MIQuadTreeRef tree, MKMapRect rect, unsigned char level, MITraverse *traverse);
MI_EXTERN void MIQuadTreeTraversRectPoints(MIQuadTreeRef tree, MKMapRect rect, MITraverse *traverse);
MI_EXTERN void MIQuadTreeTraversPoints(MIQuadTreeRef tree, MITraverse *traverse);

MI_EXTERN bool MIQuadTreeIsDescendant(MIQuadTreeRef tree, MIQuadTreeRef root);
MI_EXTERN bool MIQuadTreeContainsPoint(MIQuadTreeRef node, MIPoint point);

#endif
