//This class is used by Protag_Device to update Location

#import "GPSManager.h"
#import "DeviceManager.h"
#import "WarningManager.h"
#import "DataManager.h"
#import "AccountManager.h"
#import "FencingManager.h"
#import "HTTPClient.h"
#import "CameraManager.h"
#import "BackupContactsManager.h"

@implementation GPSManager

//Singleton
+(id)sharedInstance{
    static GPSManager *_instance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

-(id)init{
    self = [super init];
    if(self)
    {
        //Initialize
        _LocationManager = [[CLLocationManager alloc] init];
        [_LocationManager setDelegate:self];
        _DeviceList = [[NSMutableArray alloc]init];
        [self CheckGPSStatus];
        bol_GenerateGeofencing = false;
        bol_CheckGeofence = false;
    }
    return self;
}

-(void)queue_for_update_Location:(Protag_Device *)device{
    NSLog(@"Queueing device for location update");
    if(![_DeviceList containsObject:device])
       [_DeviceList addObject:device];

    if(_DeviceList.count>0){
        [self ResetAccuracy];
        [self StartPreciseTrack];
    }
}

#pragma CLLocationManagerDelegate functions
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    //WARNING: THIS IS ONLY USED FOR iOS6 AND ABOVE
    //Updated Location
    //Most recent location is the last in the NSArray, API says will always have a size of at least 1
    NSLog(@"Updated Location, iOS6+");
    [self locationTrigger:[locations objectAtIndex:locations.count-1]];    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    //WARNING: THIS IS ONLY USED FOR iOS5 AND BELOW
    NSLog(@"Updated Location iOS5-");
    [self locationTrigger:newLocation];
}

-(void)locationTrigger:(CLLocation*)location{
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) > 15.0){
        NSLog(@"Location received too old, discarded!");
        return;
    }
    
    [self ResetAccuracy];
    [self UpdateDevices:location];
    [self UpdateTrack:location];
    
    if([[DataManager sharedInstance]Settings_Tracking] && [[AccountManager sharedAccountManager] bol_isMissing] == YES)
    {
        [self StartPreciseTrack];
    }
    
    if(bol_GenerateGeofencing)
    {
        bol_GenerateGeofencing=false;
        [self GenerateGeofence:location];
    }
    
    if(bol_CheckGeofence)
    {
        bol_CheckGeofence=false;
        [self CheckForGeofence:location];
    }

    if(bol_testTrack)
    {
        bol_testTrack=false;
        [self updatePhoneLocation:location];
    }
    
    [self optimizeTrack];
}

-(void)UpdateDevices:(CLLocation*)location{
    if(_DeviceList.count==0)
        return;
    
    //Sometimes the updates give 0,0 which should be discarded
    if([location coordinate].latitude==0 && [location coordinate].longitude==0){
        NSLog(@"Updated Coordinates invalid, retrying again");
        return;
    }
    
    if([[AccountManager sharedAccountManager] bol_isMissing] == NO){
        [_LocationManager stopUpdatingLocation];
        //Restart significant if needed
        if([[DataManager sharedInstance]Settings_Tracking])
            [self StartTracking];
        else
            [self StopTracking];
    }
    
    while(_DeviceList.count>0)
    {
        Protag_Device *device = (Protag_Device*)[_DeviceList objectAtIndex:0];
        NSLog(@"GPSController updating %@ coordinates",device.str_Name);
        [device set_latitude:[location coordinate].latitude];
        [device set_longitude:[location coordinate].longitude];
        [_DeviceList removeObjectAtIndex:0];
    }
    [[DeviceManager sharedInstance]refreshAllDeviceViews];
}

-(void)dummyCall{
    //super nonsense code just to force iOS to show authorization prompt
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized)
    {
        [_LocationManager startUpdatingLocation];
        [_LocationManager stopUpdatingLocation];
    }
}


-(void)CheckGPSStatus{  
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized)
    {
        [[WarningManager sharedInstance]AlertEvent:GPS_ALLOWED];
        if([CLLocationManager locationServicesEnabled]==true)
            [[WarningManager sharedInstance]AlertEvent:GPS_ON];
        else
            [[WarningManager sharedInstance]AlertEvent:GPS_OFF];
    }
    else
        [[WarningManager sharedInstance]AlertEvent:GPS_NOT_ALLOWED];
}

//Function to turn off and on the corresponding significant or precise location accordingly
-(void)optimizeTrack{
    //if it does not require to stop updating location then precise location should overwrite significant location
    if(_DeviceList.count==0 && bol_testTrack==false && (![[DataManager sharedInstance]Settings_Tracking] || [[AccountManager sharedAccountManager] bol_isMissing] == FALSE)){
        [_LocationManager stopUpdatingLocation];
    
        if(![[DataManager sharedInstance]Settings_Tracking])
            [self StopTracking];
        else
            [self StartTracking];
    }else if([[DataManager sharedInstance]Settings_Tracking] && [[AccountManager sharedAccountManager] bol_isMissing] == TRUE){
        [self StartPreciseTrack];
    }
}


-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized)
        [[WarningManager sharedInstance]AlertEvent:GPS_ALLOWED];
    else
        [[WarningManager sharedInstance]AlertEvent:GPS_NOT_ALLOWED];
}

-(void)StartTracking{
    [_LocationManager startMonitoringSignificantLocationChanges];
}

-(void)StopTracking{
    [_LocationManager stopMonitoringSignificantLocationChanges];
}

-(void)StartPreciseTrack{
    //Stop significant before updating precise location
    if([[DataManager sharedInstance]Settings_Tracking])
        [self StopTracking];
    [_LocationManager startUpdatingLocation];
}

-(void)StopPreciseTrack{
    [_LocationManager stopUpdatingLocation];
    if([[DataManager sharedInstance]Settings_Tracking])
        [self StartTracking];
}

-(void)testTrack{
    if(bol_testTrack==false){
        bol_testTrack=true;
        [self StartPreciseTrack];
    }
}

-(void)ResetAccuracy{
    if(_DeviceList.count>0)
        [_LocationManager setDesiredAccuracy:kCLLocationAccuracyBestForNavigation];
    else if([[DataManager sharedInstance]Settings_Tracking])
        _LocationManager.desiredAccuracy = [[AccountManager sharedAccountManager]user_Accuracy];
}


//Used for tracking
-(void)UpdateTrack:(CLLocation*)location{
    if ([[DataManager sharedInstance]Settings_Tracking]==false)
        return;
    
    if([[AccountManager sharedAccountManager] bol_isMissing] == YES){
        [self updatePhoneLocation:location];
    }
    
    [[AccountManager sharedAccountManager]pollServerForActions];
}

-(void)updatePhoneLocation:(CLLocation *)newLocation
{
    if(newLocation==NULL)
        return;
    
	NSString *longitude = [[NSString alloc] initWithFormat:@"%f", newLocation.coordinate.longitude];
	NSString *latitude = [[NSString alloc] initWithFormat:@"%f", newLocation.coordinate.latitude];
	NSString *horizontalAccuracy = [[NSString alloc]initWithFormat:@"%f",newLocation.horizontalAccuracy];
	UIDevice *myDevice = [UIDevice currentDevice];
    
	[myDevice setBatteryMonitoringEnabled:YES];
	double dbl_batLeft = (float)[myDevice batteryLevel]*100;
	NSString *batLeft = [NSString stringWithFormat:@"%.0f",dbl_batLeft];
    
#warning to test changing accuracy to horizontalAccuracy. See if it affects the map display alot
	
	//Reminder: NSDictionary cannot contain double, must be converted to NSString
	NSDictionary * dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"sendTrack", @"action",@"iOS",@"typePhone",[[AccountManager sharedAccountManager] str_Email],@"email",[[AccountManager sharedAccountManager] str_RegID],@"regID",latitude,@"latitude",longitude,@"longitude",horizontalAccuracy,@"accuracy",batLeft,@"battery",[[AccountManager sharedAccountManager]getCurrentDate],@"dateCreate",nil];

	[[HTTPClient sharedHTTPClient] queryServerPath:@"phoneDataReceive.php" parameters:dict success:^(id jsonObject) {
        NSLog(@"Sent phone location data to server: %@",dict);
		NSLog(@"Server Reply: %@",jsonObject);
	} failure:^(NSError *error) {
		NSLog(@"Cannot send phone location to server");
	}];
}

//For Secure Geofencing
-(void)GenerateCurrentGeofence{
    //requires time to grab the current location
    if(bol_GenerateGeofencing==false){
        bol_GenerateGeofencing=true;
        [self StartPreciseTrack];
    }
}


//Creates a geofence with the given location parameters
-(void)GenerateGeofence:(CLLocation*)location{
    //reverseGeolocation (finding location name)
#warning reverseGeolocation only supported in most countries, not all
    CLGeocoder *geoCoder = [[CLGeocoder alloc]init];
    [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        NSString *locationName = @"Secure Geofence";
        
        if([placemarks count]>0){
            CLPlacemark *tempPlacemark = [placemarks objectAtIndex:0];
            
            if(tempPlacemark.areasOfInterest.count>0)
                locationName = [tempPlacemark.areasOfInterest objectAtIndex:0];
            else
                locationName = tempPlacemark.thoroughfare;
        }
        
        FencingData *tempdata = [[FencingData alloc]initWithName:locationName WithLat:location.coordinate.latitude  WithLong:location.coordinate.longitude WithRadius:200];
        
        NSLog(@"Generated new secure zone location");
        [[FencingManager sharedInstance]updateCurrentRegion:tempdata];
        
        [self optimizeTrack];
    }];
}

-(void)StartMonitoring:(FencingData*)geofence{
    NSLog(@"Start Monitoring geofence");
    [_LocationManager startMonitoringForRegion:[geofence getRegion]];
}
-(void)StopMonitoring:(FencingData*)geofence{
    NSLog(@"Stop Monitoring geofence");
    [_LocationManager stopMonitoringForRegion:[geofence getRegion]];
}

-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region{
    NSLog(@"Entering Secure Geofence");
    [[DeviceManager sharedInstance]SecureZone_On];
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region{
    NSLog(@"Exiting Secure Geofence");
    [[GPSManager sharedInstance]CheckForGeofence];
}

-(void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error{
    if(error!=NULL)
    {
        NSLog(@"Region Error: %@",error);
        for(int i=0;i<[[FencingManager sharedInstance]_FencingList].count;i++)
        {
            FencingData *tempData = [[[FencingManager sharedInstance]_FencingList]objectAtIndex:i];
            if([[tempData LocationName]isEqualToString:[region identifier]])
            {
                NSLog(@"Region that had error: %@",[tempData LocationName]);
            }
        }
    }
}

-(void)StartMonitoringAll{
    for(int i=0;i<[[FencingManager sharedInstance]_FencingList].count;i++)
    {
        FencingData *tempData = [[[FencingManager sharedInstance]_FencingList]objectAtIndex:i];
        [self StartMonitoring:tempData];
    }
}

-(void)StopMonitoringAll{
    NSLog(@"Stop Monitoring All Regions");
#warning removes all object from the list, timebeing commented for confirmation
 //   [[[FencingManager sharedInstance]_FencingList]removeAllObjects];
    NSArray *tempArray = [_LocationManager.monitoredRegions allObjects];
    
    for(int i=0;i<tempArray.count;i++)
        [_LocationManager stopMonitoringForRegion:[tempArray objectAtIndex:i]];
}

-(void)CheckForGeofence{
    NSLog(@"Check for Geofence");
    if(bol_CheckGeofence==false && [[FencingManager sharedInstance]_FencingList].count==0)
        return;
    
    bol_CheckGeofence = true;
    
    [self StartPreciseTrack];
}

//Private function
-(void)CheckForGeofence:(CLLocation*)location{
    NSLog(@"Check if current location is inside any geofence");
    for(int i=0;i<[[FencingManager sharedInstance]_FencingList].count;i++)
    {
        FencingData *tempData = [[[FencingManager sharedInstance]_FencingList]objectAtIndex:i];
        
        if([[tempData getRegion]containsCoordinate:[location coordinate]]){
            NSLog(@"Is in geofence: %@",[tempData LocationName]);
           [[DeviceManager sharedInstance]SecureZone_On];
            return;
        }
    }
    
    NSLog(@"Not in any geofence");
    [[DeviceManager sharedInstance]SecureZone_Off];
}

- (CLLocation *)latestLocation{
    return [_LocationManager location];
}

@end
