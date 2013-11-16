//
//  BlueToothBackgroundManager.m
//  PROTAG
//
//  Created by Sai on 10/11/13.
//
//

#import "BlueToothBackgroundManager.h"
#import "CrowdTrackManager.h"

@interface BlueToothBackgroundManager()<CBCentralManagerDelegate>{
    CBCentralManager *cbBackgroundManager;
    NSMutableArray *discoveredPeripheral;
    NSMutableDictionary *deviceandDate;
    UIBackgroundTaskIdentifier bgTask;
}
@end

@implementation BlueToothBackgroundManager

static BlueToothBackgroundManager *instance;
static dispatch_queue_t backgroundQueue;
static dispatch_queue_t crowdTrackingQueue;


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
        backgroundQueue = dispatch_queue_create("backgroundQueue", NULL);//serial queue
        crowdTrackingQueue = dispatch_queue_create("crowdTrackingQueue", NULL);//serial queue
        cbBackgroundManager = [[CBCentralManager alloc] initWithDelegate:self queue:backgroundQueue];
        discoveredPeripheral = [NSMutableArray array];
        deviceandDate = [NSMutableDictionary dictionary];
    }
    
    return self;
}


#pragma mark - instance methods
- (void)enableBackgroundTracking{
    self.isCrowdTrackingEnabled = YES;
    
    [self disableBackgroundTracking];
    backgroundQueue = dispatch_queue_create("backgroundQueue", NULL);
    dispatch_async(backgroundQueue, ^{
        if (cbBackgroundManager.state == CBCentralManagerStatePoweredOn) {
            NSDictionary *scanOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
            NSArray *serviceArray = [self serviceArray];
            [cbBackgroundManager scanForPeripheralsWithServices:serviceArray options:nil];
        }
    });
}

- (void)disableBackgroundTracking{
    self.isCrowdTrackingEnabled = NO;
    
    if (cbBackgroundManager.state == CBCentralManagerStatePoweredOn){
        [cbBackgroundManager stopScan];
    }
    //backgroundQueue = nil;
}

#pragma mark - CBCentralManager delegates

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    
    NSString *deviceName = [advertisementData objectForKey:@"kCBAdvDataLocalName"];
 
    if ([deviceName isEqualToString:@"PROTAG"]) {
        NSString *macAddress = ((NSData*)[advertisementData objectForKey:@"kCBAdvDataManufacturerData"]).description;
        macAddress = [self convertMacAdress:macAddress];
       // NSLog(@"protag found, mac %@", macAddress);
        
        NSDate *deviceLastFoundTime = [deviceandDate objectForKey:macAddress];
        if (!deviceLastFoundTime || (deviceLastFoundTime && [[NSDate date] timeIntervalSince1970] - [deviceLastFoundTime timeIntervalSince1970] >= 3)){
            NSLog(@"interval >= 20 or first find");
            [deviceandDate setObject:[NSDate date] forKey:macAddress];
            dispatch_async(crowdTrackingQueue, ^{
                [[CrowdTrackManager sharedInstance] retrieveInfoWith:macAddress peripheral:peripheral];
            });
        } 
    }
}

- (NSString *)convertMacAdress:(NSString *)str{
    NSSet *fobidChar = [NSSet setWithObjects:@"<",@">",@" ", nil];
    NSString *mac = @"";
    
    for (int i=0; i<str.length; i++) {
        char c = [str characterAtIndex:i];
        NSString *ch = [NSString stringWithFormat:@"%c",c];

        if (![fobidChar containsObject:ch]) {
            mac = [mac stringByAppendingString:ch];
        }
    }
    
    return mac;
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    
}

#pragma mark - private methods

- (NSArray *)serviceArray{
    CBUUID *service1802 = [CBUUID UUIDWithString:@"1802"];
    CBUUID *service1803 = [CBUUID UUIDWithString:@"1803"];
    CBUUID *service1804 = [CBUUID UUIDWithString:@"1804"];
    CBUUID *service180F = [CBUUID UUIDWithString:@"180F"];
    
    return @[service1802,service1803,service1804,service180F];
}
@end
