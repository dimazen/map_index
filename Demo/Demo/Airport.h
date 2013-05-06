//
//  Airport.h
//  Airports
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Airport : NSObject<MKAnnotation> {
    CLLocationCoordinate2D coordinate;
    UIImage* icon;
}

@property(nonatomic,copy) NSString *city, *code;
@property(nonatomic) CLLocationCoordinate2D coordinate;
@property(nonatomic,readonly) UIImage *icon;

+(NSArray*)allAirports;

@end
