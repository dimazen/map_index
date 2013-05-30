//
//  ViewController.m
//  MapIndex
//

#import "ViewController.h"
#import "Airport.h"
#import "MapIndex.h"

@interface ViewController () <MKMapViewDelegate>
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

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
	MIAnnotation *annotation = (MIAnnotation *)view.annotation;
	if ([annotation class] == [MIAnnotation class])
	{
//		NSLog(@"Selected annotation: %@", [annotation allAnnotations]);
	}
}

@end