#import <Foundation/Foundation.h>
#import "Protag_Device.h"

@protocol DeviceObserver <NSObject>
- (void) refreshDeviceView;
@end

@interface DeviceManager : NSObject{
    bool bol_SecureZone;
}

@property (nonatomic,retain) NSMutableArray *_currentDevices;
@property (nonatomic,retain) NSMutableArray *_LostDevices;
@property (nonatomic,retain) NSMutableArray *_ObserverList;
@property (nonatomic) Protag_Device *_DetailsDevice;



-(void)registerObserver:(id<DeviceObserver>) Observer;
-(void)deregisterObserver:(id<DeviceObserver>) Observer;
-(void)add_Device:(Protag_Device*)Device;
-(void)remove_Device:(Protag_Device*)Device;
-(void)update_Device_Status:(CBPeripheral*)peripheral withStatus:(int)Status;
-(BOOL)has_Device_with_Peripheral:(CBPeripheral*)peripheral;
-(Protag_Device*)Device_With_Peripheral:(CBPeripheral*)peripheral;
-(void)refreshAllDeviceViews;
-(void)Clear_LostDevices;
-(void)Clear_NonSnoozedLostDevices;
-(void)Add_LostDevice:(Protag_Device*)_Device;
-(NSString*)LostDevice_Names;
-(void)SecureZone_On;
-(void)SecureZone_Off;
-(void)ConnectAll;
-(void)DisconnectAll;


+(id)sharedInstance; //Singleton

@end
