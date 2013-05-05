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
}

@property (nonatomic) NSUInteger count;
@property (nonatomic) CLLocationCoordinate2D coordinate;


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

- (NSString *)title
{
	if (_title == nil && _readAvailable)
	{
		_title = [[NSString alloc] initWithFormat:@"%@ cluster: %d", NSStringFromClass([self class]), _count];
	}

	return _title;
}

- (NSString *)subtitle
{
	if (_subtitle == nil && _readAvailable)
	{
		_subtitle = [[NSString alloc] initWithFormat:@"lat:%.6f lon:%.6f", _coordinate.latitude, _coordinate.longitude];
	}

	return _subtitle;
}

#pragma mark - MIAnnotation

- (BOOL)contains:(id <MKAnnotation>)annotation
{
	if (!(_readAvailable)) return NO;

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
	if (_annotations == nil && _readAvailable)
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
	return [self class] == [object class] && self->_content == ((MIAnnotation *)object)->_content;
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
		[self setReadAvailable:YES];
		[self updateContentData];
	}
	else
	{
		[self setReadAvailable:NO];
	}
}

- (MIQuadTreeRef)content
{
	return _content;
}

- (void)setReadAvailable:(BOOL)readAvailable
{
	_readAvailable = readAvailable && _content != NULL;
}

@end

@implementation MIAnnotation (Package)

@dynamic content, readAvailable;

- (void)updateContentData
{
	if (_readAvailable)
	{
		[self setCount:MIQuadTreeGetCount(_content)];
		[self setCoordinate:MKCoordinateForMapPoint(MIQuadTreeGetCentroid(_content))];
	}
	else
	{
		[self setCount:0];
		[self setCoordinate:(CLLocationCoordinate2D){0.0, 0.0}];
	}
}

- (void)prepareForReuse
{
	[self setContent:NULL];
}

@end