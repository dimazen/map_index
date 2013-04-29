//
//  ViewController.m
//  MapIndex
//
//  Created by dshe on 04/23/13.
//  Copyright (c) 2013 dshe. All rights reserved.
//

#import "ViewController.h"
#import "Airport.h"
#import "MIQuadTree.h"
#import "MIMapView.h"

@interface ViewController ()
{
    __weak IBOutlet MIMapView *_mapView;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^
    {
        NSArray *airports = [Airport allAirports];
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [_mapView addAnnotations:airports];
        });
    });
}

- (void)viewDidUnload
{
	[super viewDidUnload];

	_mapView = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end