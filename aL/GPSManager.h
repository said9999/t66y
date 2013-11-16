#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Protag_Device.h"
#import "FencingData.h"

@interface GPSManager : NSObject<CLLocationManagerDelegate>{
    NSMutableArray *_DeviceList;
    CLLocationManager *_LocationManager;
    BOOL bol_GenerateGeofencing;
    BOOL bol_CheckGeofence;
    BOOL bol_testTrack;
}

+(id)sharedInstance;//Singleton
-(void)queue_for_update_Location:(Protag_Device*)device;
-(void)UpdateDevices:(CLLocation*)location;
-(void)CheckGPSStatus;
-(void)ResetAccuracy;

//Used only to ask iOS for location service permission at the start
-(void)dummyCall;

//For Mobile Tracking
-(void)StartTracking;
-(void)StopTracking;
-(void)UpdateTrack:(CLLocation*)location;
-(void)updatePhoneLocation:(CLLocation *)newLocation;
-(void)testTrack;
-(void)optimizeTrack;

//For Secure Geofencing
-(void)GenerateCurrentGeofence;

-(void)StartMonitoring:(FencingData*)geofence;
-(void)StopMonitoring:(FencingData*)geofence;
-(void)StartMonitoringAll;
-(void)StopMonitoringAll;
-(void)CheckForGeofence;//use when user connects protag

//external access
-(CLLocation *)latestLocation;
@end
