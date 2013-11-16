#import <Foundation/Foundation.h>
#import "Protag_Device.h"
#import "BluetoothManager.h"

@interface NotificationGrouper : NSObject{
    UILocalNotification *_LocalNotification;
    NSMutableArray *_DeviceList;
    bool bol_Unscheduling;
}

-(id)init;
-(void)add_Device:(Protag_Device*)device;
-(void)Schedule:(int)interval;//iOS interval (seconds)
-(void)Unschedule;
-(BOOL)hasPastFireDate;

@end
