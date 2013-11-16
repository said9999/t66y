#import <Foundation/Foundation.h>
#import "Protag_Device.h"

typedef enum{
    PROXIMITY_NOT_IN_RANGE,
    PROXIMITY_IN_RANGE,
    PROXIMITY_LONG_RANGE
}ProximityStatus;

@protocol ProximityObserver <NSObject>
- (void) UpdateStatus:(ProximityStatus)status;
- (void) UpdateRSSI:(int)RSSI;
@end


@interface DeviceProximity : NSObject{
    NSTimer *_timer;
    Protag_Device *_device;
    NSMutableArray *_ObserverList;
    double double_updateInterval;
    int int_proximityCount;
}

-(void)startScanning:(Protag_Device*)device;
-(void)stopScanning;
-(void)registerObserver:(id<ProximityObserver>)observer;
-(void)deregisterObserver:(id<ProximityObserver>)observer;
-(void)detectedProximityDevice:(Protag_Device*)device withRSSI:(int)RSSI;

@end


@protocol ProximityBluetooth <NSObject>
@property (nonatomic) Protag_Device *_proximityDevice;
@property (nonatomic) DeviceProximity *_proximitydelegate;
@end