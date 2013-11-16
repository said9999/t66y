#import "WifiDetector.h"
#import "DataManager.h"
#import "Protag_Device.h"
#import "WarningManager.h"

@implementation WifiDetector

@synthesize _WifiList;

//Singleton
+(id)sharedInstance{
    static WifiDetector *_instance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

-(id)init{
    self = [super init];
    if(self){
        _WifiList = [[DataManager sharedInstance]load_Secure_Zone];
    }
    return self;
}


-(void)addtoList:(WifiData*)data{
    //renew SSID if found similar BSSID
    for(int i=0;i<_WifiList.count;i++)
    {
        WifiData *tempData = (WifiData*)[_WifiList objectAtIndex:i];
        if([[tempData BSSID]isEqualToString:[data BSSID]]){
            [tempData setSSID:[data SSID]];
            return;
        }
    }
    
    //if no old BSSID found, just add as new data set
    [_WifiList addObject:data];
    [[DataManager sharedInstance]save_Secure_Zone];
}

-(NSMutableArray*)get_List{
    return _WifiList;
}

-(WifiData*)getCurrentNetwork{
    NSArray *tempArray = (__bridge id) CNCopySupportedInterfaces();
    if(tempArray.count == 0)
        return NULL;
    else{
        for(int i=0;i<tempArray.count;i++)
        {
        NSString *tempStr = [tempArray objectAtIndex:i];
        CFDictionaryRef info = CNCopyCurrentNetworkInfo((__bridge CFStringRef)tempStr);
            if(info==NULL)
                continue;
            else{
                WifiData *tempData = [[WifiData alloc]init];
                [tempData setSSID:(NSString*)CFDictionaryGetValue(info, kCNNetworkInfoKeySSID)];
                [tempData setBSSID:(NSString*)CFDictionaryGetValue(info, kCNNetworkInfoKeyBSSID)];
                CFRelease(info);
                return tempData;
            }
        }
    }
    return NULL;
}

-(BOOL)isCurrentNetWorkOnList{
    WifiData *currentNetwork = [self getCurrentNetwork];
    if(currentNetwork==NULL)
        return false;
    
    for(int i=0;i<_WifiList.count;i++)
    {
        WifiData *tempData = (WifiData*)[_WifiList objectAtIndex:i];
        if([[currentNetwork BSSID]isEqualToString:[tempData BSSID]])
            return true;
    }
    return false;
}

-(void)addCurrentNetworkToList{
    WifiData *currentNetwork = [self getCurrentNetwork];
    if(currentNetwork!=NULL)
        [self addtoList:currentNetwork];
    else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Wifi is not connected to any network" delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

-(void)removeWifiWithBSSID:(NSString*)BSSID{
    for(int i=0;i<_WifiList.count;i++)
    {
        WifiData *tempData = (WifiData*)[_WifiList objectAtIndex:i];
        if([[tempData BSSID]isEqualToString:BSSID]){
            NSLog(@"Found similar BSSID");
            [_WifiList removeObjectAtIndex:i];
            [[DataManager sharedInstance]save_Secure_Zone];
            return;
        }
    }
}

-(void)CheckWiFiStatus{
   
    WifiData *CurrentNetwork = [self getCurrentNetwork];
    if(_WifiList.count > 0 && CurrentNetwork == NULL)
        [[WarningManager sharedInstance]AlertEvent:WIFI_OFF];
    else
        [[WarningManager sharedInstance]AlertEvent:WIFI_ON];
}

@end
