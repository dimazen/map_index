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

#pragma mark - Creation

MI_EXTERN MIQuadTreeRef MIQuadTreeCreate(MKMapRect rect);

MI_EXTERN void MIQuadTreeFree(MIQuadTreeRef tree);

MI_EXTERN MIQuadTreeRef MIQuadTreeRetain(MIQuadTreeRef tree);
MI_EXTERN void MIQuadTreeRelease(MIQuadTreeRef tree);

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

MI_EXTERN void MIQuadTreeTraversLevelRectPoints(MIQuadTreeRef tree, MKMapRect rect, unsigned int level, MITraverse *traverse);
MI_EXTERN void MIQuadTreeTraversRectPoints(MIQuadTreeRef tree, MKMapRect rect, MITraverse *traverse);
MI_EXTERN void MIQuadTreeTraversPoints(MIQuadTreeRef tree, MITraverse *traverse);

#pragma mark - Checks

MI_EXTERN bool MIQuadTreeIsDescendant(MIQuadTreeRef root, MIQuadTreeRef leaf);
MI_EXTERN bool MIQuadTreeContainsPoint(MIQuadTreeRef node, MIPoint point);

#endif
