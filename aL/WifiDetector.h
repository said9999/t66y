#import <Foundation/Foundation.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import "WifiData.h"

//This class is used to detect Wifi SSID

@interface WifiDetector : NSObject

@property (nonatomic) NSMutableArray *_WifiList;

+(id)sharedInstance; //Singleton
-(void)addCurrentNetworkToList;
-(BOOL)isCurrentNetWorkOnList;
-(void)removeWifiWithBSSID:(NSString*)BSSID;
-(void)CheckWiFiStatus;

@end
