//
//  ViewController.m
//  MapIndex
//
//  Created by dshe on 04/23/13.
//  Copyright (c) 2013 dshe. All rights reserved.
//

#import "ViewController.h"
#import "Airport.h"
#import "MIQuadTreeNode.h"

@interface ViewController ()

@end

@implementation ViewController

void VCTraverseCallback(MKMapPoint point, void *payload, void *context)
{

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSArray *airports = [Airport allAirports];
    
	MIQuadTreeNodeRef root = MIQuadTreeNodeCreate(MKMapRectWorld);
	for (Airport *airport in airports)
	{
		MIQuadTreeNodeInsertPoint(root, MKMapPointForCoordinate([airport coordinate]), (__bridge void *) airport);
	}
    
	MIQuadTreeNodeTraversAllPoints(root, VCTraverseCallback);
	MIQuadTreeNodeTraversRectPoints(root, MKMapRectWorld, 0, VCTraverseCallback, NULL);

	for (Airport *airport in airports)
	{
		NSCParameterAssert(MIQuadTreeNodeContainsPoint(root, MKMapPointForCoordinate([airport coordinate]), (__bridge void *) airport));
	}

	MIQuadTreeNodeRemoveAllPoints(root);

//	for (Airport *airport in airports)
//	{
//		MIQuadTreeNodeRemovePoint(root, MKMapPointForCoordinate([airport coordinate]), (__bridge void *)airport);
//	}

	MIQuadTreeNodeFree(root);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end