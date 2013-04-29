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

	NSString *_title;
	NSString *_subtitle;
	NSMutableSet *_annotations;

	BOOL _dataAvailable;
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

#pragma mark - Memory Warning

- (void)didReceiveMemoryWarning
{
	_annotations = nil;
	_title = nil;
	_subtitle = nil;
}

#pragma mark - MKAnnotation

- (CLLocationCoordinate2D)coordinate
{
	return _coordinate;
}

- (NSString *)title
{
	if (_title == nil && _dataAvailable && _readAvailable)
	{
		_title = [[NSString alloc] initWithFormat:@"%@ cluster: %d", NSStringFromClass([self class]), _count];
	}

	return _title;
}

- (NSString *)subtitle
{
	if (_subtitle == nil && _dataAvailable && _readAvailable)
	{
		_subtitle = [[NSString alloc] initWithFormat:@"lat:%.6f lon:%.6f", _coordinate.latitude, _coordinate.longitude];
	}

	return _subtitle;
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

void _MIAnnotationTraversCallback(MIPoint point, MITraverseResultType resultType, MITraverse *traverse)
{
	[((__bridge NSMutableSet *) traverse->context) addObject:(__bridge id <MKAnnotation>)point.identifier];
}

- (NSSet *)allAnnotations
{
	if (_annotations == nil && _dataAvailable && _readAvailable)
	{
		_annotations = [[NSMutableSet alloc] initWithCapacity:_count];

		MITraverse traverse =
		{
			.callback = _MIAnnotationTraversCallback,
			.context = (__bridge void *) _annotations,
		};
		MIQuadTreeTraversPoints(_content, &traverse);
	}

	return _annotations;
}

#pragma mark - Equality

- (BOOL)isEqual:(id)object
{
	return [self class] == [object class] &&
		self->_content == ((MIAnnotation *)object)->_content;
}

- (NSUInteger)hash
{
	return (NSUInteger)_content;
}

#pragma mark - Properties & Flags

- (void)setContent:(MIQuadTreeRef)content
{
	if (_content == content) return;

	_content = content;

	_annotations = nil;
	_title = nil;
	_subtitle = nil;

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

- (void)setReadAvailable:(BOOL)readAvailable
{
	_readAvailable = readAvailable & _dataAvailable;
}

- (BOOL)dataAvailable
{
	return _dataAvailable;
}

@end

@implementation MIAnnotation (Package)

@dynamic content, dataAvailable, readAvailable;

- (void)prepareForReuse
{
	[self setContent:NULL];

	_coordinate = (CLLocationCoordinate2D){0.0, 0.0};
	_count = 0;
}

@end