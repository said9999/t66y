//
//  CrowdTrackManager.m
//  PROTAG
//
//  Created by Sai on 10/11/13.
//
//

#import "CrowdTrackManager.h"
#import "HTTPClient.h"
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "GPSManager.h"
#import "CrowdTrackLostItem.h"
#import "AccountManager.h"
#import "CrowdTrackNotificationHandler.h"


@interface CrowdTrackManager(){
    NSMutableDictionary *reportedLostItem;
    NSMutableDictionary *macAdressPeripheral;
    HTTPClient *httpClient;
}

@end

@implementation CrowdTrackManager

static NSString *domain = @"";//@"http://localhost:300";//
                //@"http://192.168.0.101:3000";

// http://innovatech
static NSString *lostFoundPath = @"/lost_found.php";
static NSString *lostLocationPath = @"/lost_location.php";
static CrowdTrackManager *instance;

#pragma mark - constructors
+(id)sharedInstance{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (id)init{
    self = [super init];
    if (self) {
        httpClient = [HTTPClient sharedHTTPClient];
        [httpClient setParameterEncoding:AFJSONParameterEncoding];
        reportedLostItem = [NSMutableDictionary dictionary];
        macAdressPeripheral = [NSMutableDictionary dictionary];
    }
    
    return self;
}

#pragma mark - instance methods

- (void)retrieveInfoWith:(NSString *)macAddress peripheral:(CBPeripheral *)peripheral {
    if ([[AccountManager sharedAccountManager] bol_isDeveloper]) {
        domain = [SERVER_ADDRESS stringByAppendingString:DEV_SITE];
    }else{
        domain = [SERVER_ADDRESS stringByAppendingString:PUBLIC_SITE];
    }
    
    NSString *postPath = [domain stringByAppendingString:lostFoundPath];
    NSLog(@"%@", postPath);
    
    //NSLog(@"%@",[self formatMacAddress:macAddress]);
    NSArray *array = [NSArray arrayWithObject:[self formatMacAddress:macAddress]];
    NSDictionary *dataWrapper = [NSDictionary dictionaryWithObject:array forKey:@"mac_ads"];
    NSLog(@"%@",[self formatMacAddress:macAddress]);
    [macAdressPeripheral setObject:peripheral forKey:macAddress];
    
    [httpClient postPath:postPath parameters:dataWrapper success:^(AFHTTPRequestOperation *operation, id responseObject) {
        switch ([operation.response statusCode]) {
            case 200:{//lost
                NSDictionary *json = (NSDictionary*)responseObject;
                NSArray *devices = [json objectForKey:@"devices"];
                
                
                for (NSDictionary *device in devices) {
                    NSLog(@"%@",device);
                    int lost_status = [[device objectForKey:@"lost_status"] intValue];
                    switch (lost_status) {
                        case 0:
                            return ;
                        case 1:
                            [self findPrivate:YES LostItem:device];
                            break;
                        case 2:
                            [self findPrivate:NO LostItem:device];
                            break;
                        case -1:
                            NSLog(@"no such device");
                            break;
                        case -2:
                            NSLog(@"database error");
                            break;
                        default:
                            NSLog(@"not 200 in post macaddress");
                            break;
                    }
                }
                
                break;
            }
            default:
                NSLog(@"not 200,201, or 202 error in post mac address");
                break;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error in post mac address");
        NSLog(@"%@",error);
    }timeout:60];
}


- (NSArray *)retrieveLostItemList{
    NSMutableArray *lostItemList = [NSMutableArray array];
    
    @synchronized(self){
        NSArray *keys = [reportedLostItem allKeys];
        for (NSString* key in keys) {
            CrowdTrackLostItem *lostItem = [reportedLostItem objectForKey:key];
            if (!lostItem.isPrivate) {
                //avoid two threads access to same resources
                [lostItemList addObject:lostItem];
            }
        }
        
        //sort items so latest one will be the first one
        [lostItemList sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSDate *first = [(CrowdTrackLostItem *)obj1 lastUpdateDate];
            NSDate *second = [(CrowdTrackLostItem *)obj2 lastUpdateDate];
            return [second compare:first];
        }];
    }
    
    return lostItemList;
}

#pragma mark - private methods
- (void)findPrivate:(BOOL)isPrivate LostItem:(NSDictionary *)json{
    CLLocation *latestLocation = [[GPSManager sharedInstance] latestLocation];
   
    if (latestLocation) {//check whether gps is work then report gps location
        //post location
        NSString *mac_ad = [json objectForKey:@"mac_ad"];
        //NSString *user_id = [json objectForKey:@"user_id"];
        NSString *latitude = [NSString stringWithFormat:@"%lf",latestLocation.coordinate.latitude];
        NSString *longtitude = [NSString stringWithFormat:@"%lf",latestLocation.coordinate.longitude];
        
        NSString *postPath = [domain stringByAppendingString:lostLocationPath];
        
        NSDictionary *postData = [NSDictionary dictionaryWithObjects:@[mac_ad,latitude,longtitude] forKeys:@[@"mac_ad",@"latitude",@"longitude"]];
        NSArray *array = [NSArray arrayWithObject:postData];
        NSDictionary *dataWrapper = [NSDictionary dictionaryWithObject:array forKey:@"devices"];
        
        
        [httpClient postPath:postPath parameters:dataWrapper
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"post gps location successfully");
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"post gps location fail");
                NSLog(@"%@",error);
            }
        ];
        
        if (!isPrivate) {//create lostitem and put it into hashmap if the item is okay to be shown to others
            CrowdTrackLostItem *lostItem = [[CrowdTrackLostItem alloc] init];
            //lostItem.userId = user_id;
            NSMutableString *temp = [NSMutableString stringWithString:mac_ad];
            [temp replaceOccurrencesOfString:@":" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [mac_ad length])];
            //NSLog(@"server returned mac_id formated %@", temp);
            lostItem.macAdress = (NSString *)temp;
            lostItem.isPrivate = isPrivate;
            //lostItem.description = [json objectForKey:@"description"];
            lostItem.description = [self constructDescription:json];
            lostItem.contactNo = [json objectForKey:@"contact_number"];
            lostItem.message = [json objectForKey:@"message"];
            lostItem.itemName = [json objectForKey:@"protag_name"];
            lostItem.lastUpdateDate = self.latestUpdateTime =[NSDate date];
            lostItem.peripheral = [macAdressPeripheral objectForKey:(NSString *)temp];
            
            @synchronized(self){
                //add lost item to crowdtrack-notification handler
                [[CrowdTrackNotificationHandler sharedInstance] addNewDetectLostItem:lostItem];
                
                [reportedLostItem setObject:lostItem forKey:mac_ad];//store reported item
            }
        }
        
    }
    
}

- (NSString *)constructDescription:(NSDictionary *)json{
    NSString *description = @"";
    description = [description stringByAppendingString:[NSString stringWithFormat:@"Item Name: %@\n",[json objectForKey:@"protag_name"]]];
//    description = [description stringByAppendingString:[NSString stringWithFormat:@"Location: %@\n",[json objectForKey:@"location"]]];
//    description = [description stringByAppendingString:[NSString stringWithFormat:@"Time Lost: %@\n",[json objectForKey:@"time_lost"]]];
    description = [description stringByAppendingString:[NSString stringWithFormat:@"Contact Name: %@\n",[json objectForKey:@"contact_name"]]];
    description = [description stringByAppendingString:[NSString stringWithFormat:@"Contact Number: %@\n",[json objectForKey:@"contact_number"]]];
    
    return description;
}

- (BOOL)withinValidTime:(NSDate *)latestTime WithNewAddress:(NSString *)mac_ad{
    
    BOOL isGPSWorkWithinPastFewMinutes;
    BOOL isReportedBefore;
    BOOL isReportedWithinPastFewMinutes;
    BOOL isValid;
    NSDate *now = [NSDate date];
    
    isReportedBefore = ([reportedLostItem objectForKey:mac_ad] != nil);
    isGPSWorkWithinPastFewMinutes =  (now.timeIntervalSince1970 - latestTime.timeIntervalSince1970 <= 300);//work in the past 5 minutes
    
    if (isReportedBefore) {
        NSDate *updateTime = [[reportedLostItem objectForKey:mac_ad] lastUpdateDate];
        isReportedWithinPastFewMinutes = (now.timeIntervalSince1970 - updateTime.timeIntervalSince1970 <= 300);
    }else{
        isReportedWithinPastFewMinutes = NO;
    }
    
    isValid = (isGPSWorkWithinPastFewMinutes && !isReportedWithinPastFewMinutes);
    
    return isValid;
}

- (NSString *)formatMacAddress:(NSString *)mac
{
    NSMutableString *temp = [NSMutableString stringWithString:mac];
    for (int i = 2; i < 17; i += 3) {
        [temp insertString:@":" atIndex:i];
    }
    return (NSString *)temp;
}

@end
