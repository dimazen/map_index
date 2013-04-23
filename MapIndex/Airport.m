//
//  Aiport.m
//  Airports
//

#import "Airport.h"

static NSDictionary* icons;

@implementation Airport

@synthesize coordinate,city,code,icon;

+(void)initialize {
    if (self == [Airport class]) {
        icons = [[NSDictionary alloc] initWithObjectsAndKeys: 
                 [UIImage imageNamed:@"small_airport"], @"small_airport", 
                 [UIImage imageNamed:@"heliport.png"], @"heliport", 
                 [UIImage imageNamed:@"big_airport.png"], @"big_airport", 
                 [UIImage imageNamed:@"seaplane_base.png"],@"seaplane_base",
                 [UIImage imageNamed:@"closed.png"],@"closed",
                 nil];
    }
}

-(id)initWithCode:(NSString*)aCode city:(NSString*)aCity latitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude type:(NSString*)aType {
    if ((self = [super init])) {
        coordinate.latitude = latitude;
        coordinate.longitude = longitude;
        
        self.code = aCode;
        self.city = aCity;
        
        icon = [icons objectForKey:aType];
        if (!icon) icon = [icons objectForKey:@"big_airport"];
    }
    return self;
}

-(NSString*)title {
    return self.code;
}

-(NSString*)subtitle {
    return self.city;
}

+(NSArray*)allAirports {
    NSString* path = [[NSBundle mainBundle] pathForResource:@"Airports" ofType:@"plist"];
    NSArray* list = (NSArray*)[NSPropertyListSerialization propertyListFromData:[NSData dataWithContentsOfFile:path]
                                                     mutabilityOption:NSPropertyListImmutable 
                                                               format:NULL 
                                                     errorDescription:NULL];
    NSMutableArray* result = [NSMutableArray array];
    for (NSDictionary* d in list) {
        CLLocationDegrees lat = [(NSNumber*)[d objectForKey:@"Latitude"] floatValue];
        CLLocationDegrees lng = [(NSNumber*)[d objectForKey:@"Longitude"] floatValue];
        [result addObject:[[self alloc] initWithCode:[d objectForKey:@"Code"] city:[d objectForKey:@"City"] latitude:lat  longitude:lng type:[d objectForKey:@"Type"]]];
    }
    return result;
}

@end
