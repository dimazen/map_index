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
#import "MIMapView.h"

@interface ViewController ()

@end

@implementation ViewController

void VCTraverseCallback(MIPoint point, MITraverseResultType resultType, MITraverse *traverse)
{

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSArray *airports = [Airport allAirports];

	MIMapView *view = [MIMapView new];
	[view addAnnotations:airports];

//	MIQuadTreeRef root = MIQuadTreeCreate(MKMapRectWorld);
//	for (Airport *airport in airports)
//	{
//		MIQuadTreeInsertPoint(root, MIPointMake(MKMapPointForCoordinate(airport.coordinate), (__bridge void *)airport));
//	}
//
//	MITraverse traverse = {.callback = VCTraverseCallback, .context = (__bridge void *)self};
//	MIQuadTreeTraversRectPoints(root, MKMapRectWorld, &traverse);
//	MIQuadTreeTraversLevelRectPoints(root, MKMapRectWorld, 7, &traverse);
//	MIQuadTreeTraversPoints(root, &traverse);

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end