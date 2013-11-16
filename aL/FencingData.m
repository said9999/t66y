#import "FencingData.h"

@implementation FencingData
@synthesize Latitude;
@synthesize Longitude;
@synthesize Radius;
@synthesize LocationName;

NSString * const KEY_FENCING_LOCATIONNAME = @"KEY_FENCING_LOCATIONNAME";
NSString * const KEY_FENCING_LATITUDE = @"KEY_FENCING_LATITUDE";
NSString * const KEY_FENCING_LONGITUDE = @"KEY_FENCING_LONGITUDE";
NSString * const KEY_FENCING_RADIUS = @"KEY_FENCING_RADIUS";

-(id)initWithName:(NSString*) name WithLat:(double)latitude WithLong:(double)longitude WithRadius: (double)radius{
    if(self = [super init])
    {
        self.LocationName=name;
        self.Latitude=latitude;
        self.Longitude=longitude;
        
        //Documentation say minimum distance 200 meters
        self.Radius=radius;
        
        CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
        
        _Region = [[CLRegion alloc]initCircularRegionWithCenter:centerCoordinate radius:radius identifier:name];
    }
    return self;
}

-(CLRegion*)getRegion{
    return _Region;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    //Encode properties, other class variables, etc
    //Used for DataController to save
	[encoder encodeObject:self.LocationName forKey:KEY_FENCING_LOCATIONNAME];
    [encoder encodeDouble:self.Longitude forKey:KEY_FENCING_LONGITUDE];
    [encoder encodeDouble:self.Latitude forKey:KEY_FENCING_LATITUDE];
    [encoder encodeDouble:self.Radius forKey:KEY_FENCING_RADIUS];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if( self != nil )
    {
        LocationName = [decoder decodeObjectForKey:KEY_FENCING_LOCATIONNAME];
        Latitude = [decoder decodeDoubleForKey:KEY_FENCING_LATITUDE];
        Longitude = [decoder decodeDoubleForKey:KEY_FENCING_LONGITUDE];
        Radius = [decoder decodeDoubleForKey:KEY_FENCING_RADIUS];
        
        CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(Latitude, Longitude);
        
        _Region = [[CLRegion alloc]initCircularRegionWithCenter:centerCoordinate radius:Radius identifier:LocationName];
    }
    return self;
}


@end
