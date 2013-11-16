#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "DeviceProximity.h"

typedef enum {
    DISCOVERING_DEVICES,
    DISCOVERED_DEVICE,
    CONNECTING_DEVICE,
    CONNECTED_DEVICE,
    FAIL_CONNECT_DEVICE
}DiscoveryEvents;

//Protocol for viewcontroller to use so that we can display messages accordingly
@protocol DiscoveryObserver <NSObject>
- (void) AlertEvent:(DiscoveryEvents)event;
@end


@interface BluetoothManager : NSObject<ProximityBluetooth>{
    CBCentralManager *_CentralManager;
    NSMutableArray *_Discovered_Peripherals;
    NSMutableArray *_Discovered_MAC;
    bool bol_Scanning;
    
    NSMutableArray *_RegrabiPad;
}


@property (nonatomic, assign) id<DiscoveryObserver> _discoveryObserver;
@property (nonatomic,readonly) CBCentralManager *CentralManager;
@property (nonatomic,readonly) NSMutableArray *Discovered_Peripherals;
@property (nonatomic,retain) NSMutableArray *MacAddress;
@property (nonatomic)UILocalNotification *_localNotification;

+(id)sharedInstance;//Singleton
-(bool)is_BluetoothOn;
-(bool)is_BluetoothSupported;
-(bool)is_BluetoothAuthorized;
-(void)get_Peripherals:(NSArray*)UUID_List;
-(void)CheckBluetoothStatus;
-(bool)is_Scanning;
-(bool)is_peripheralConnected;
-(BOOL)isBluetoothBackground;
-(void)ShowBluetoothLocalNotification;
-(void)startScanning;
-(void)stopScanning;
-(void)SpeedupUpdates:(Protag_Device*)device; //speedsup or slowsdown 3s or 1s
-(NSArray*)get_ServiceUUIDForScan;
-(void)regrab_iPadPeripheral:(Protag_Device*)device;
-(NSString *)convertMacAddress:(NSString *)str;
-(void)scan;

@end
