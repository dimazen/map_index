/**
 * Created with JetBrains AppCode.
 * Author: dmitriy
 * Date: 23.04.13 21:13
 */

#import "MIAnnotation.h"
#import "MIAnnotation+Package.h"

@interface MIAnnotation ()
{
	CLLocationCoordinate2D _coordinate;

	MIQuadTreeRef _content;
	NSUInteger _count;
	NSMutableSet *_cachedAnnotations;

	BOOL _dataAvailable;
	BOOL _readAvailable;
}

@property (nonatomic, assign) MIQuadTreeRef content;
@property (nonatomic, assign, readonly) BOOL dataAvailable;
@property (nonatomic, assign) BOOL readAvailable;

- (void)didReceiveMemoryWarning;

@end

@implementation MIAnnotation

#pragma mark - Init

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:UIApplicationDidReceiveMemoryWarningNotification
												  object:nil];
}

- (id)init
{
	self = [super init];
	if (self != nil)
	{
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(didReceiveMemoryWarning)
													 name:UIApplicationDidReceiveMemoryWarningNotification
												   object:nil];
	}

	return self;
}

#pragma mark - Observer

- (void)didReceiveMemoryWarning
{
	_cachedAnnotations = nil;
}

#pragma mark - MKAnnotation

- (CLLocationCoordinate2D)coordinate
{
	return _coordinate;
}

#pragma mark - MIAnnotation

- (NSUInteger)count
{
	return _count;
}

- (BOOL)contains:(id <MKAnnotation>)annotation
{
	if (!(_dataAvailable && _readAvailable)) return NO;

	if ([annotation class] == [MIAnnotation class])
	{
		return MIQuadTreeIsDescendant(_content, ((MIAnnotation *)annotation)->_content);
	}

	return MIQuadTreeContainsPoint(_content, MIPointMake(MKMapPointForCoordinate([annotation coordinate]), (__bridge void *)annotation));
}

#pragma mark - Annotations Retrieving

void _MIAnnotationTraversCallback(MIPoint point, MITraverseResultType resultType, MITraverse *traverse)
{
	[((__bridge NSMutableSet *) traverse->context) addObject:(__bridge id <MKAnnotation>)point.identifier];
}

- (NSSet *)allAnnotations
{
	if (_cachedAnnotations == nil && _dataAvailable && _readAvailable)
	{
		_cachedAnnotations = [[NSMutableSet alloc] initWithCapacity:_count];

		MITraverse traverse =
		{
			.callback = _MIAnnotationTraversCallback,
			.context = (__bridge void *)_cachedAnnotations,
		};
		MIQuadTreeTraversPoints(_content, &traverse);
	}

	return _cachedAnnotations;
}

#pragma mark - Properties


#pragma mark - Content

- (void)setContent:(MIQuadTreeRef)content
{
	if (_content == content) return;

	_content = content;

	_cachedAnnotations = nil;

	if (_content != NULL)
	{
		_count = MIQuadTreeGetCount(_content);
		_coordinate = MKCoordinateForMapPoint(MIQuadTreeGetCentroid(_content));

		_dataAvailable = YES;
		_readAvailable = YES;
	}
	else
	{
		_dataAvailable = NO;
		_readAvailable = NO;
	}
}

- (BOOL)dataAvailable
{
	return _dataAvailable;
}

- (BOOL)readAvailable
{
	return _readAvailable;
}

@end

@implementation MIAnnotation (Package)

@dynamic content, dataAvailable, readAvailable;

#pragma mark - Init

- (id)initWithContent:(MIQuadTreeRef)content
{
	self = [self init];
	if (self != nil)
	{
		[self setContent:content];
	}

	return self;
}
#pragma mark - Reuse

- (void)prepareForReuse
{
	[self setContent:NULL];

	_coordinate = (CLLocationCoordinate2D){0.0, 0.0};
	_count = 0;
}

@end