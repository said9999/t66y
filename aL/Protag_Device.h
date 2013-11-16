#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "Alarm.h"
#import "WifiDetector.h"
@class NotificationGrouper;//circular dependency, used this to fix

extern int const RSSI_DISTANCE[];

typedef enum {
    STATUS_CONNECTED,
    STATUS_NOT_CONNECTED,
    STATUS_CONNECTION_FAILED,
    STATUS_CONNECTING,
    STATUS_DISCONNECTING,
    STATUS_DISCONNECTED,
    STATUS_SNOOZE,
    STATUS_LOST,
    STATUS_SECURE_ZONE,
    STATUS_RADAR
} DeviceStatus;

@interface Protag_Device : NSObject<AlarmContainer,UIAlertViewDelegate>{
    bool bol_initialized;
    UIBackgroundTaskIdentifier bgSecureZoneTask;//Used for secure zone

    NSTimer *_timerConnectionFailed;
    bool bol_Hint;    
}

@property (nonatomic,copy) NSString *str_Name;
@property (nonatomic,copy) NSString *str_DateLost;
@property (nonatomic,copy) NSString *str_UUID;
@property (nonatomic,copy) NSString *str_MAC;
@property (nonatomic) int int_Icon;
@property (nonatomic) int int_Battery;
@property (nonatomic) double _longitude;
@property (nonatomic) double _latitude;
@property (nonatomic,retain) NotificationGrouper *_Notification;
@property (nonatomic,copy) NSString *str_Status;
@property (nonatomic) int int_Status;
@property (nonatomic) int index_Distance;
@property (nonatomic) int SnoozeSeconds;
@property (nonatomic) int int_RSSI;
@property (nonatomic) BOOL bol_Synced;
@property (nonatomic,retain) CBCharacteristic *_speedUpCharacteristic;
@property (nonatomic,retain) CBCharacteristic *_2A19Characteristic;
@property (nonatomic,retain) CBPeripheral *_peripheral;

-(id)init_WithPeripheral:(CBPeripheral*) peripheral andMAC:(NSString*) MAC;
-(id)init_WithDummyValues;
-(void)set_Status:(DeviceStatus)status;
-(int)get_StatusCode;
-(BOOL)identicalToPeripheral:(CBPeripheral*) peripheral;
-(BOOL)isEqualUUID:(CBPeripheral*) peripheral;

-(void)Set_Peripheral:(CBPeripheral*) peripheral;
-(void)Connect;
-(void)Connection_Failed;
-(void)Disconnect;
-(BOOL)isConnected;
-(int)get_RSSI;
-(int)get_PhoneRSSI;
-(void)update_RSSI:(int)RSSI;
-(void)update_Battery:(int)Battery;
-(double)RSSItoDistance;
-(void)UpdateSnoozeStatus;
-(void)DismissSnooze;
-(void)UpdateLostInformation;
-(void)UnscheduleNotification;
-(void)RegrabPeripheral;
-(void)toggleSpeedUp;
-(void)toggleSync;
-(void)check_NotifyCharacteristic;
-(void)CallStopScan;
//iPad
-(BOOL)is_iPad;

//Hint wizard
-(BOOL)get_Hint;
-(void)set_Hint:(BOOL)hint;

@end
