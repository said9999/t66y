#import "Protag_Device.h"
#import "BluetoothManager.h"
#import "DeviceManager.h"
#import "NotificationGrouper.h"
#import "GPSManager.h"
#import "AccountManager.h"
#import "Alarm.h"

static NSString * const KEY_NAME = @"KEY_NAME";
static NSString * const KEY_DATELOST = @"KEY_DATELOST";
static NSString * const KEY_UUID = @"KEY_UUID";
static NSString * const KEY_LONGITUDE = @"KEY_LONGITUDE";
static NSString * const KEY_LATITUDE = @"KEY_LATITUDE";
static NSString * const KEY_ICON = @"KEY_ICON";
static NSString * const KEY_DISTANCE = @"KEY_DISTANCE";
static NSString * const KEY_MAC = @"KEY_MAC";
static NSString * const KEY_SYNCED = @"KEY_SYNCED";

//Modify the RSSI limit here
#warning retest this
int const TESTED_MAX_RSSI = -27;
int const TESTED_MIN_RSSI = -128;
int const RSSI_DISTANCE[] = {-75,-120};

@implementation Protag_Device

@synthesize str_Name,str_DateLost,str_Status,str_UUID,str_MAC;
@synthesize _longitude,_latitude;
@synthesize index_Distance;
@synthesize int_Battery,int_Status,int_Icon;
@synthesize SnoozeSeconds;
@synthesize _Notification;
@synthesize int_RSSI;
@synthesize _speedUpCharacteristic;
@synthesize _2A19Characteristic;
@synthesize _peripheral;
@synthesize bol_Synced;


-(id)init_WithPeripheral:(CBPeripheral*) peripheral andMAC:(NSString*) MAC{
    if(self = [super init]){
        bol_initialized = FALSE;
        bol_Hint = TRUE;
        _peripheral = peripheral;
        bol_Synced = false;
        
        [_peripheral setDelegate:[BluetoothManager sharedInstance]];
        str_Name = peripheral.name;
        str_UUID = (NSString*)CFBridgingRelease(CFUUIDCreateString(nil,peripheral.UUID));
        
        //Converting MAC to proper values
        str_MAC = [MAC stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
        str_MAC = [str_MAC stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSMutableString *tempStr = [NSMutableString stringWithString:str_MAC];
        [tempStr insertString:@":" atIndex:2];
        [tempStr insertString:@":" atIndex:5];
        [tempStr insertString:@":" atIndex:8];
        [tempStr insertString:@":" atIndex:11];
        [tempStr insertString:@":" atIndex:14];
        str_MAC = tempStr;
        
        [self set_Status:STATUS_NOT_CONNECTED];
        str_DateLost=@"";
        int_Battery = -1;
        int_Icon = 0;
        index_Distance = 1; //default RSSI distance index
        SnoozeSeconds = 0;
        int_RSSI = INT_MIN;
        _Notification = NULL;
        _timerConnectionFailed = NULL;
        bol_initialized = TRUE;
        _speedUpCharacteristic=NULL;
        _2A19Characteristic=NULL;
    }
    return self;
}

/*
-(id)init_WithDummyValues{
    if(self = [super init]){
        bol_initialized=false;
        _peripheral = NULL;
        str_Name = @"Dummy";
        str_UUID = @"123456789";
        str_MAC = @"1234435435";
        [self set_Status:STATUS_NOT_CONNECTED];
        str_DateLost=@"";
        int_Icon = 0;
        int_Battery = 0;
        index_Distance = 1; //default RSSI distance index
        SnoozeSeconds = 0;
        bol_initialized=true;
        int_RSSI = INT_MIN;
    }
    return self;
}
*/

- (void)encodeWithCoder:(NSCoder *)encoder
{
    //Encode properties, other class variables, etc
    //Used for DataController to save
	[encoder encodeObject:self.str_Name forKey:KEY_NAME];
    [encoder encodeObject:self.str_UUID forKey:KEY_UUID];
    [encoder encodeObject:self.str_DateLost forKey:KEY_DATELOST];
    [encoder encodeObject:self.str_MAC forKey:KEY_MAC];
    [encoder encodeDouble:_longitude forKey:KEY_LONGITUDE];
    [encoder encodeDouble:_latitude forKey:KEY_LATITUDE];
    [encoder encodeInt:index_Distance forKey:KEY_DISTANCE];
    [encoder encodeInt:int_Icon forKey:KEY_ICON];
    [encoder encodeBool:bol_Synced forKey:KEY_SYNCED];
}


- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if( self != nil )
    {
        bol_initialized=false;
        bol_Hint=false;
        //decode properties, other class vars
        _peripheral=NULL; //peripheral update done by DeviceController
        str_Name = [decoder decodeObjectForKey:KEY_NAME];
        str_UUID = [decoder decodeObjectForKey:KEY_UUID];
        str_MAC = [decoder decodeObjectForKey:KEY_MAC];
        str_DateLost = [decoder decodeObjectForKey:KEY_DATELOST];
        _longitude = [decoder decodeDoubleForKey:KEY_LONGITUDE];
        _latitude = [decoder decodeDoubleForKey:KEY_LATITUDE];
        index_Distance = [decoder decodeIntForKey:KEY_DISTANCE];
        bol_Synced = [decoder decodeBoolForKey:KEY_SYNCED];
        int_Icon = [decoder decodeIntForKey:KEY_ICON];
        [self set_Status:STATUS_NOT_CONNECTED];
        _Notification=NULL;
        _timerConnectionFailed=NULL;
        bol_initialized=true;
        _speedUpCharacteristic=NULL;
        _2A19Characteristic=NULL;
        int_Battery = -1;
    }
    return self;
}

-(void)set_Status:(DeviceStatus)status{
    //int_Status now would be the previous status code
    switch (status) {
        case STATUS_SNOOZE:
            str_Status=@"Connecting in...";
            [self UpdateSnoozeStatus];
            break;
        //All other status reset SnoozeSeconds back to 0
        SnoozeSeconds=0;
        case STATUS_CONNECTED:
            //Check if not in radar mode, once it is connected have to check geofence
            if([[BluetoothManager sharedInstance]_proximityDevice]!=self)
                [[GPSManager sharedInstance]CheckForGeofence];
            str_Status=@"Secured";
            break;
        case STATUS_CONNECTING:
            str_Status=@"Connecting...";
            break;
        case STATUS_DISCONNECTED:
            str_Status=@"Manually Disconnected";
            break;
        case STATUS_DISCONNECTING:
            str_Status=@"Disconnecting...";
            break;
        case STATUS_LOST:
            str_Status=@"Unsecured";
            [self UnscheduleNotification];
            break;
        case STATUS_NOT_CONNECTED:
            str_Status=@"Not Connected";
            break;
        case STATUS_CONNECTION_FAILED:
            str_Status=@"Connection Failed";
            break;
        case STATUS_SECURE_ZONE:
            str_Status=@"In Secure Zone";
            break;
        case STATUS_RADAR:
            str_Status=@"Connected In Radar";
            break;
        default:
            str_Status=@"UNKNOWN STATUS CODE";
            break;
    }
    int_Status = status;
    if(bol_initialized == TRUE)
        [[DeviceManager sharedInstance]refreshAllDeviceViews];
}

-(int)get_StatusCode{
    return int_Status;
}

-(void)Connect{
    NSLog(@"Connect %@",str_Name);
  
    if(_peripheral==NULL){
        NSLog(@"%@ has empty Peripheral",str_Name);
        [self RegrabPeripheral];
    }
    if(_peripheral!=NULL)
    {
        if (![_peripheral isConnected])
        {
            if(int_Status!=STATUS_SECURE_ZONE)
            {
                if(_timerConnectionFailed==NULL)
                    _timerConnectionFailed = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(Connection_Failed) userInfo:nil repeats:false];
            }
            else
            {
                if(_timerConnectionFailed==NULL)
                {
                    bgSecureZoneTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
                        [self SecureZoneFailed];
                    }];
                    _timerConnectionFailed = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(SecureZoneFailed) userInfo:nil repeats:false];
                }
            }
            
            if(int_Status == STATUS_SNOOZE)
            {
                SnoozeSeconds = 0;
                [self reduce_Second];
            }
            
            [self set_Status:STATUS_CONNECTING];
            //[[[BluetoothManager sharedInstance]CentralManager]  scanForPeripheralsWithServices:[[BluetoothManager sharedInstance]get_ServiceUUIDForScan]  options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @NO}];
            //[[[BluetoothManager sharedInstance]CentralManager]  scanForPeripheralsWithServices:nil options:nil];
#warning just added for testing, need to remove later should not be here
            
            [[BluetoothManager sharedInstance]scan];
            NSLog(@"START SCANNING");
           
            /*
            Protag_Device *device = [[DeviceManager sharedInstance]Device_With_Peripheral:_peripheral];
            NSLog(@"%d  %@",[[BluetoothManager sharedInstance]MacAddress].count,[[BluetoothManager sharedInstance]MacAddress]);
            
            for(int i =0;i<[[BluetoothManager sharedInstance]MacAddress].count;i++)
            {
                if([[[[BluetoothManager sharedInstance]MacAddress]objectAtIndex:i] isEqual:device.str_MAC])
                    [[[BluetoothManager sharedInstance]CentralManager]stopScan];
            }
            */
            [self performSelector:@selector(CallStopScan) withObject:nil afterDelay:2];
            [[[BluetoothManager sharedInstance]CentralManager] connectPeripheral:_peripheral options:nil];
            
        }
    }
}

-(void)CallStopScan
{
    [[BluetoothManager sharedInstance]stopScanning];

}

-(void)Disconnect{
    NSLog(@"Disconnect %@",str_Name);
    if (_peripheral==NULL) {
        NSLog(@"%@ has empty Peripheral",str_Name);
        [self RegrabPeripheral];
    }
    
    if(_peripheral!=NULL)
    {
        if ([_peripheral isConnected])
        {
            [self set_Status:STATUS_DISCONNECTING];
            if(_timerConnectionFailed!=NULL)
            {
                [_timerConnectionFailed invalidate];
                _timerConnectionFailed = NULL;
            }
            [[[BluetoothManager sharedInstance]CentralManager] cancelPeripheralConnection:_peripheral];
        }
    }
}

-(void)Connection_Failed{
    if(_timerConnectionFailed!=NULL)
    {
        [_timerConnectionFailed invalidate];
        _timerConnectionFailed = NULL;
    }
    
    if(_peripheral!=NULL && ![_peripheral isConnected])
    {
        NSLog(@"Connection Failed %@",str_Name);
        bol_initialized = TRUE;
       
        if(![[[DeviceManager sharedInstance]_LostDevices]containsObject:self])
        {
            //If was not connected before hand
            if(int_Status == STATUS_CONNECTING)
            {
                UIAlertView *message = [[UIAlertView alloc]initWithTitle:@"Device Status" message:[NSString stringWithFormat:@"Failed to Connect. Make Sure %@ is On",str_Name] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [message show];
            }
            [self set_Status:STATUS_CONNECTION_FAILED];
            if([[Alarm sharedInstance]isInBackground])
                [[Alarm sharedInstance]ShowLocalNotification];
       }
       else
       {
            [[DeviceManager sharedInstance]Add_LostDevice:self];//it will not add, it will just cause it to ring the alarm
       }
       [[[BluetoothManager sharedInstance]CentralManager] cancelPeripheralConnection:_peripheral];
    }else if ([_peripheral isConnected]){
        //Don't care which Status it is in
        [self set_Status:STATUS_CONNECTED];
    }
}

//Used when user exits secure zone
-(void)SecureZoneFailed{
    if(_timerConnectionFailed!=NULL)
    {
        [_timerConnectionFailed invalidate];
        _timerConnectionFailed = NULL;
    }
    if(int_Status == STATUS_CONNECTING && ![self isConnected]){
        [self Disconnect];
        [[DeviceManager sharedInstance]Add_LostDevice:self];
    }
    [[UIApplication sharedApplication]endBackgroundTask:bgSecureZoneTask];
}
//This RSSI is from Protag
-(int)get_RSSI{
    return int_RSSI;
}


//This RSSI is from Phone
-(int)get_PhoneRSSI{
    if([_peripheral isConnected])
    {
        [_peripheral readRSSI];
        return _peripheral.RSSI.intValue;
    }
    return INT_MIN;
}

-(double)RSSItoDistance{
    double double_EstimatedMaxDistance = 8;// in meters

    double double_RSSItoDistanceFactor = double_EstimatedMaxDistance/(TESTED_MAX_RSSI-TESTED_MIN_RSSI);
    if(int_RSSI!=INT_MIN){
        double tempDouble = (TESTED_MAX_RSSI-int_RSSI)*double_RSSItoDistanceFactor;
        if(tempDouble>0)
            return tempDouble;
        else
            return 0;
    }
    else
        return 0;
}


//Updated by the Protag device every 3 seconds unless speedUp(1 sec)
-(void)update_RSSI:(int)RSSI{
    int_RSSI = RSSI;
    [[DeviceManager sharedInstance]refreshAllDeviceViews];
    
    //Stronger RSSI means closer
    if(int_RSSI!=INT_MIN &&
       int_RSSI<RSSI_DISTANCE[index_Distance]){
        NSLog(@"RSSI is lesser than the set Distance, adding to lost device");
        if(int_Status != STATUS_RADAR){
        //if RSSI is lesser than preset RSSI distance, it would mean that  it is further away from the indicated distance
        [self Disconnect];
        [[DeviceManager sharedInstance]Add_LostDevice:self];
        }
    }    
}

-(void)update_Battery:(int)Battery{
    int_Battery = Battery;
#warning warn user of low battery level next time after android catches up
    //Secure zone
    NSLog(@"Status in Battery %@",self.str_Status);
    if(int_Status != STATUS_RADAR)
    {
        if([[WifiDetector sharedInstance]isCurrentNetWorkOnList])
            [[DeviceManager sharedInstance]SecureZone_On];
    }
    [[DeviceManager sharedInstance]refreshAllDeviceViews];
}

-(void)Set_Peripheral:(CBPeripheral*) peripheral{
    if([self isEqualUUID:peripheral])
        _peripheral = peripheral;
    else
        NSLog(@"Tried to set a peripheral with a different UUID");
}

-(BOOL)isEqualUUID:(CBPeripheral*) peripheral{
    if(peripheral==NULL || peripheral.UUID==NULL)
    {
        [self RegrabPeripheral];
        return false;
    }
    
    NSLog(@"Checking for equal UUID");
    NSLog(@"str_UUID: %@ compare with %@",str_UUID,(NSString*)CFBridgingRelease(CFUUIDCreateString(nil,peripheral.UUID)));
    
    return [str_UUID isEqualToString:(NSString*)CFBridgingRelease(CFUUIDCreateString(nil,peripheral.UUID))];
}

-(BOOL)identicalToPeripheral:(CBPeripheral*) peripheral{
    if(_peripheral!=NULL && ([_peripheral isEqual:peripheral] || [self isEqualUUID:peripheral]))
        return true;
    else
        return false;
}

-(BOOL)isConnected{
    if(_peripheral == NULL)
        return false;
    else if(_peripheral.state == CBPeripheralStateConnected)
        return true;
    else
        return false;
}


#pragma AlarmContainer functions
////////////////////////////////////////////////////////////////////////

-(void)Set_Minutes:(int)minutes
{
    //Alarm sets minutes after this device is pushed into Lost Devices
    //This function used for user to set snooze timing
    if(minutes>0)
    {
        SnoozeSeconds=minutes*60;
        [self set_Status:STATUS_SNOOZE];
        NSLog(@"Set_Minutes in Seconds: %i",SnoozeSeconds);
    }
}

//used by NStimer to reduce (does not work in background)
-(void)reduce_Second{
    //Reduced by Alarm
    if(SnoozeSeconds>0)
        SnoozeSeconds--;
    else
        [self UnscheduleNotification];
    [self UpdateSnoozeStatus];
    
    //Ringing of alarm when this is 0 is checked by Alarm, not this device
}

//only used when app comes from background to active
-(void)reduce_Seconds:(int)seconds{
    if(int_Status==STATUS_SNOOZE)
    {
        NSLog(@"reduce_seconds %d",seconds);
        SnoozeSeconds = SnoozeSeconds-seconds;
        if(SnoozeSeconds<=0)
        {
            SnoozeSeconds=0;
            [self UnscheduleNotification];
        }
        [self UpdateSnoozeStatus];
    }
}


#pragma End of AlarmContainer Methods
/////////////////////////////////////////////////////////////////////////


-(void)UpdateSnoozeStatus{
    if(int_Status==STATUS_SNOOZE)
    {
        str_Status=@"Connecting in ";
        int seconds = SnoozeSeconds%60;
        int totalminutes = SnoozeSeconds/60;
        int hours = totalminutes/60;
        int minutes = totalminutes%60;
        
        if(hours>0)
            str_Status=[NSString stringWithFormat:@"%@%ih ",str_Status,hours];
        if(minutes>0)
            str_Status=[NSString stringWithFormat:@"%@%im ",str_Status,minutes];
        if(seconds>0)
            str_Status=[NSString stringWithFormat:@"%@%is",str_Status,seconds];
        
        str_Status=[NSString stringWithFormat:@"%@...",str_Status];
        
        [[DeviceManager sharedInstance]refreshAllDeviceViews];
    }
}

-(void)DismissSnooze{
    //attempt to reconnect again
    if(int_Status == STATUS_SNOOZE)
    {
        [[[DeviceManager sharedInstance]_LostDevices]removeObject:self];
        [self set_Status:STATUS_LOST];
    }
}

-(void)UpdateLostInformation{
    NSLog(@"%@ updating lost information",str_Name);
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [self setStr_DateLost:[formatter stringFromDate:[NSDate date]]];
    [[GPSManager sharedInstance]queue_for_update_Location:self];
    
    if(bol_Synced)
        [[AccountManager sharedAccountManager]syncProtag:self];
}

-(void)UnscheduleNotification{
    if(_Notification!=NULL)
    {
        NSLog(@"%@ UnscheduleNotification",str_Name);
        [_Notification Unschedule];
        _Notification=NULL;
    }
}

-(void)RegrabPeripheral{
    if([self is_iPad])
    {
        NSLog(@"Regrab Peripheral for iPad device");
        [[BluetoothManager sharedInstance]regrab_iPadPeripheral:self];
        return;
    }
    NSMutableArray* _UUIDList = [[NSMutableArray alloc]init];
    //Link with UUID with peripheral
    CFUUIDRef CFUUID = CFUUIDCreateFromString(NULL,(__bridge CFStringRef)str_UUID);
    [_UUIDList addObject:(__bridge id)CFUUID];
    CFRelease(CFUUID);
    //Retrieve the existing peripherals, task delegated to BluetoothController
    //BluetoothController will link peripheral with the devices in memory
    [[BluetoothManager sharedInstance]get_Peripherals:_UUIDList];
}

-(void)toggleSpeedUp{
    [[BluetoothManager sharedInstance]SpeedupUpdates:self];
}


//Check whether to set notify value to true or false
-(void)check_NotifyCharacteristic{
#warning have to check if notify set to false, can the connection maintain
    if(_2A19Characteristic!=NULL)
    {
        //Max distance is at index 1
        if(index_Distance<1){
            NSLog(@"Set Notify to true");
            [_peripheral setNotifyValue:true forCharacteristic:_2A19Characteristic];
        }else{
            NSLog(@"Set Notify to false");
            [_peripheral setNotifyValue:false forCharacteristic:_2A19Characteristic];
            [_peripheral readValueForCharacteristic:_2A19Characteristic];
        }
    }


}

//Hint Wizard
-(BOOL)get_Hint{
    return bol_Hint;
}
-(void)set_Hint:(BOOL)hint{
    bol_Hint=hint;
}

-(void)toggleSync{
    bol_Synced = !bol_Synced;
    
    if(bol_Synced)
        [[AccountManager sharedAccountManager]syncProtag:self];
    
    [[DeviceManager sharedInstance]refreshAllDeviceViews];
}


-(BOOL)is_iPad{
    return [str_MAC isEqualToString:@"00:00:00:00:00:00"];
}

@end
