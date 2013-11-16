#import "WifiData.h"

@implementation WifiData
@synthesize BSSID;
@synthesize SSID;

NSString * const KEY_SSID = @"KEY_SSID";
NSString * const KEY_BSSID = @"KEY_BSSID";

- (void)encodeWithCoder:(NSCoder *)encoder
{
    //Encode properties, other class variables, etc
    //Used for DataController to save
	[encoder encodeObject:self.SSID forKey:KEY_SSID];
    [encoder encodeObject:self.BSSID forKey:KEY_BSSID];
}


- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if( self != nil )
    {
        SSID = [decoder decodeObjectForKey:KEY_SSID];
        BSSID = [decoder decodeObjectForKey:KEY_BSSID];
    }
    return self;
}


@end
