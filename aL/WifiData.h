#import <Foundation/Foundation.h>

//custom data object class used to store
@interface WifiData : NSObject
@property (nonatomic,copy) NSString *BSSID; //like mac address
@property (nonatomic,copy) NSString *SSID; //like name of the wifi
@end