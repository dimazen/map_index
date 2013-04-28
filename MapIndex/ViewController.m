//
//  ViewController.m
//  MapIndex
//
//  Created by dshe on 04/23/13.
//  Copyright (c) 2013 dshe. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "ViewController.h"
#import "Airport.h"
#import "MIQuadTree.h"

@interface ViewController ()

@end

@implementation ViewController

void VCTraverseCallback(MIPoint point, void *context)
{

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSArray *airports = [Airport allAirports];
    
	MIQuadTreeRef root = MIQuadTreeCreate(MKMapRectWorld);
	for (Airport *airport in airports)
	{
		MIQuadTreeInsertPoint(root, MIPointMake(MKMapPointForCoordinate(airport.coordinate), (__bridge void *)airport));
	}
    
//	MIQuadTreeTraversPoints(root, VCTraverseCallback);
	MIQuadTreeTraversRectPoints(root, MKMapRectWorld, 0, VCTraverseCallback, NULL);

//	for (Airport *airport in airports)
//	{
//		NSCParameterAssert(MIQuadTreeContainsPoint(root, MIPointMake(MKMapPointForCoordinate(airport.coordinate), (__bridge void *)airport)));
//	}
//
//	MIQuadTreeRemoveAllPoints(root);

//	for (Airport *airport in airports)
//	{
//		MIQuadTreeNodeRemovePoint(root, MKMapPointForCoordinate([airport coordinate]), (__bridge void *)airport);
//	}

	MIQuadTreeFree(root);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end