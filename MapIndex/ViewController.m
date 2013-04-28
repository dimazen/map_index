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
	[view removeAnnotations:airports];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end