#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface FencingData : NSObject{
    CLRegion* _Region;
}
@property (nonatomic) NSString *LocationName;
@property (nonatomic) double Latitude;
@property (nonatomic) double Longitude;
@property (nonatomic) double Radius;

-(id)initWithName:(NSString*) name WithLat:(double)latitude WithLong:(double)longitude WithRadius: (double)radius;
-(CLRegion*)getRegion;

@end
