## Map Index (MIT License)
Fast map clusterization build on top of [Region QuadTree](http://en.wikipedia.org/wiki/Quadtree).

## Requirements 
* The only supported version is iOS 6. iOS 7 support coming soon :)
* MapKit.framework

## Usage
Replace MKMapView with MIMapView instance & enjoy ;) 

To provide own annotation views for cluster use:
```objective-c
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
  if ([annotation isKindOfClass:[MIAnnotation class]])
  {
    MKAnnotationView *clusterView = ...;

    ...

    return clusterView;
  }
    
  return ...;
}

```


## Custom animation
You're able to provide <b>your own animation<b> for zoom-in, move, zoom-out. 
For these puproses MIMapView declare <br>@property (nonatomic, strong) MITransitionFactory *transitionFactory;

How to use: <br>1. Subclass <br>2. Change default transitions factory to your one

```objective-c
- (MITransition *)transitionWithTarget:(NSArray *)target source:(NSArray *)source changeType:(MIChangeType)changeType
{
	switch (changeType)
	{
		case MIChangeTypeMove:
			return transition for region change without zoom-in/zoom-out
			break;

		case MIChangeTypeZoomIn:
  		return transition for zoom-in
			break;

		case MIChangeTypeZoomOut:
			return transition for zoom-out
			break;
	}
}
```

###MITransition
This class is responsible for add/remove of target annotations.
Each instance provide target annotations (which you have to add) and source annotations (which you have to remove).

Purpose of this class is to handle annotations change animated without any pain.
###MITransition Subclass
In case of custom Transition you have to implement next methods:

```objective-c
- (void)perform
{
  // Transition invoked. 
  // For example if you're implementing zoom-in transition - you need to add target annotations
  if (self.target.count > 0)
	{
		[self addAnnotations:self.target];
	}
	else if (self.source.count > 0)
	{
    // Reason, why we're removing annotaitons here, not in - mapView:didAddAnnotationViews:  
    // Is that next method get called only if you've added some annotations. 
    // Therefore if you're going to remove source annotations later but have no new annotations - ooops:)

		[self removeAnnotations:self.source];
	}
}

- (void)mapView:(MIMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
  // This method get called only if you've added any annotations.
  // Therefore take in account any code, that should be executed here. 
} 
```

<b>Important notes:<b>
Animation usually takes longer than 0 seconds. 
To prevent map's data change during animation you can lock/unlock transition in appropriate places.
It guarantees, that target annotations still on the map (but your code deleted some of them)
Example:

```objective-c
- (void)mapView:(MIMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
  [self lock];

  [views makeObjectsPerformSelector:@selector(setAlpha:) withObject:nil];

	[UIView animateWithDuration:_MIRegularTransitionDuration animations:^
	{
		for (MKAnnotationView *view in views)
		{
			[view setAlpha:1.f];
		}

	} completion:^(BOOL finished)
	{
		[self unlock];
	}];
} 
```


###Special thanks to SuperPin: 
I've used Airports.plist & Airport.m from their DEMO. They also inspired me to rewrite my Obj-C implementation of QuadTree (which was incredibly slow). All Profiling stuff has been done in comparsion with SuperPin, so big thanks to them.
