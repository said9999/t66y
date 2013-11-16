#import "DeviceManager.h"
#import "DataManager.h"
#import "BluetoothManager.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "Protag_Device.h"
#import "Alarm.h"
#import "CrowdTrackManager.h"

@implementation DeviceManager

@synthesize _currentDevices;
@synthesize _LostDevices;
@synthesize _ObserverList;
@synthesize _DetailsDevice;

//Singleton
+(id)sharedInstance{
    static DeviceManager *_instance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

-(id)init{
    if(self = [super init]){
        NSLog(@"Initializing DeviceManager");
        _ObserverList = [[NSMutableArray alloc]init];
        _currentDevices = [[DataManager sharedInstance]load_Devices];
        _LostDevices = [[NSMutableArray alloc]init];
        
        NSMutableArray* _UUIDList = [[NSMutableArray alloc]init];
        //Link with UUID with peripheral
        for(int i=0;i<_currentDevices.count;i++){
            Protag_Device *temp = (Protag_Device*)[_currentDevices objectAtIndex:i];
            //Add UUID to list
            CFUUIDRef CFUUID = CFUUIDCreateFromString(NULL,(__bridge CFStringRef)temp.str_UUID);
            [_UUIDList addObject:(__bridge id)CFUUID];
            CFRelease(CFUUID);
        }
        //Retrieve the existing peripherals, task delegated to BluetoothController
        //BluetoothController will link peripheral with the devices in memory
        [[BluetoothManager sharedInstance]get_Peripherals:_UUIDList];
        bol_SecureZone = false;

        NSLog(@"DeviceManager Initialized");
    }
    return self;
}

-(void)add_Device:(Protag_Device*)Device{
    //Allow only upto 7 device
    if(![_currentDevices containsObject:Device] && _currentDevices.count<7)
    {
        [_currentDevices addObject:Device];
        bol_SecureZone = false;
        [self refreshAllDeviceViews];
    }
}
-(void)remove_Device:(Protag_Device*)Device{
    if([_currentDevices containsObject:Device])
    {
        [Device Disconnect];
        [_currentDevices removeObject:Device];
        if(Device == _DetailsDevice)
            _DetailsDevice = NULL;
        if([_LostDevices containsObject:Device])
            [_LostDevices removeObject:Device];
        
        [[DataManager sharedInstance]save_Devices];
        [self refreshAllDeviceViews];
    }
}

-(void)update_Device_Status:(CBPeripheral*)peripheral withStatus:(int)Status;{
    for(int i=0;i<_currentDevices.count;i++){
        Protag_Device *device = [_currentDevices objectAtIndex:i];
        if([device identicalToPeripheral:peripheral])
        {
            [device set_Status:Status];
            bol_SecureZone = false;
            break;
        }
    }
    [self refreshAllDeviceViews];
}

-(void)registerObserver:(id<DeviceObserver>) Observer{
    if(![_ObserverList containsObject:Observer])
        [_ObserverList addObject:Observer];
}

-(void)deregisterObserver:(id<DeviceObserver>) Observer{
    if([_ObserverList containsObject:Observer])
        [_ObserverList removeObject:Observer];
}

-(void)refreshAllDeviceViews{
    for(int i=0;i<_ObserverList.count;i++)
    {
        [(id<DeviceObserver>)[_ObserverList objectAtIndex:i]refreshDeviceView];
    }
}

-(BOOL)has_Device_with_Peripheral:(CBPeripheral*)peripheral{
    Protag_Device *device = [self Device_With_Peripheral:peripheral];
    if(device!=NULL)
        return true;
    else 
        return false;
    return false;
}

-(Protag_Device*)Device_With_Peripheral:(CBPeripheral*)peripheral{
    for(int i=0;i<_currentDevices.count;i++){
        Protag_Device *device = [_currentDevices objectAtIndex:i];
        if([device identicalToPeripheral:peripheral])
            return device;
    }
    return NULL;
}

-(void)Clear_NonSnoozedLostDevices{
    //This will clear devices that are not on snooze
    for(int i=0;i<_LostDevices.count;i++)
    {
        Protag_Device *device = (Protag_Device*)[_LostDevices objectAtIndex:i];
        //LostDevices should only be on lost or snoozed
        if([device get_StatusCode]!=STATUS_SNOOZE && ![device isConnected])
        {
            [device Disconnect];
            [device set_Status:STATUS_LOST];
            [_LostDevices removeObjectAtIndex:i];
            i--;
            [self refreshAllDeviceViews];
        }
    }
    
   //[self RefreshDeviceTable];
}

-(void)Clear_LostDevices{
    //This will clear all lost devices
    NSLog(@"Clearing ALL Lost Device List");
    while(_LostDevices.count>0)
    {
        Protag_Device *device = (Protag_Device*)[_LostDevices objectAtIndex:0];
        [device Disconnect];
        [device set_Status:STATUS_LOST];
        [_LostDevices removeObjectAtIndex:0];
        [self refreshAllDeviceViews];
    }
    //[self RefreshDeviceTable];
}

-(void)Add_LostDevice:(Protag_Device*)_Device{
    if(![_LostDevices containsObject:_Device])
    {
        [_LostDevices addObject:_Device];
        [_Device UpdateLostInformation];
    }
    
    //Alarm will pull the lost Device names and update when neccessary
    
    [[Alarm sharedInstance]ShowAlarm];
}

-(NSString*)LostDevice_Names{
    NSString *str_temp = @"";
    for(int i =0;i<_LostDevices.count;i++)
    {
        Protag_Device *device = [_LostDevices objectAtIndex:i];
        if(device.SnoozeSeconds==0)
            str_temp = [str_temp stringByAppendingFormat:@"%@,  ",[device str_Name]] ;
    }
    return str_temp;
}

-(void)SecureZone_On{
    if(!bol_SecureZone)
    {
        NSLog(@"SecureZone turning on");
        bol_SecureZone=true;
        for(int i=0;i<_currentDevices.count;i++)
        {
            Protag_Device *device = [_currentDevices objectAtIndex:i];
            if([device get_StatusCode]==STATUS_CONNECTED)
            {
                [device Disconnect];
                [device set_Status:STATUS_SECURE_ZONE];
            }
        }
   }
}

-(void)SecureZone_Off{
    if(bol_SecureZone)
    {
        NSLog(@"SecureZone turning off");
        bol_SecureZone=false;
        for(int i=0;i<_currentDevices.count;i++)
        {
            Protag_Device *device = [_currentDevices objectAtIndex:i];
            if([device get_StatusCode]==STATUS_SECURE_ZONE)
                    [device Connect];
        }
    }
}


-(void)ConnectAll{
    NSLog(@"ConnectAll");
    for(int i=0;i<_currentDevices.count;i++)
    {
        NSLog(@"%d",i);
        Protag_Device *device = [_currentDevices objectAtIndex:i];
        [device Connect];
    }
}
-(void)DisconnectAll{
    NSLog(@"DisconnectAll");
    for(int i=0;i<_currentDevices.count;i++)
    {
        Protag_Device *device = [_currentDevices objectAtIndex:i];
        [device Disconnect];
    }
}

@end
