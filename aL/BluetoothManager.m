#import "BluetoothManager.h"
#import "DeviceManager.h"
#import "Protag_Device.h"
#import "Alarm.h"
#import "WarningManager.h"
#import "NotificationGrouper.h"
#import "RingtoneManager.h"
#import "WifiDetector.h"



static NSString *const kEliteServiceUUID = @"180F";
static NSString *const kEliteReadCharacteristicUUID = @"2A19";
static NSString *const kEliteSpeedUpCharacteristicUUID = @"2A3A";

static NSString *const kiPadServiceUUID = @"3A47";
static NSString *const kiPadReadCharacteristicUUID = @"2B40";
static NSString *const kiPadWritableCharacteristicUUID = @"6B47";

//internal interface that only self can see
@interface BluetoothManager () <CBCentralManagerDelegate, CBPeripheralDelegate>
@end


@implementation BluetoothManager

@synthesize CentralManager = _CentralManager;
@synthesize Discovered_Peripherals = _Discovered_Peripherals;
@synthesize _discoveryObserver;
@synthesize MacAddress;

//Proximity
@synthesize _proximitydelegate;
@synthesize _proximityDevice;
@synthesize _localNotification;

//Singleton
+(id)sharedInstance{
    static BluetoothManager *_instance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

-(id)init{
    if(self = [super init]){
        _CentralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
        _Discovered_Peripherals = [[NSMutableArray alloc]init];
        _Discovered_MAC = [[NSMutableArray alloc]init];
        MacAddress = [[NSMutableArray alloc]init];
        _localNotification = [[UILocalNotification alloc]init];
        _RegrabiPad = [[NSMutableArray alloc]init];
        bol_Scanning = false;
        [self CheckBluetoothStatus];
    }
    return self;
}


-(bool)is_BluetoothOn{
    if(_CentralManager.state!=CBCentralManagerStatePoweredOff)
        return true;
    else
        return false;
}
-(bool)is_BluetoothSupported{
    if(_CentralManager.state==CBCentralManagerStateUnsupported)
        return false;
    else
        return true;
}
-(bool)is_BluetoothAuthorized{
    if(_CentralManager.state==CBCentralManagerStateUnauthorized)
        return false;
    else
        return true;
}

-(void)CheckBluetoothStatus{

    if(![self is_BluetoothSupported])
        [[WarningManager sharedInstance]AlertEvent:BLUETOOTH_NOT_COMPATABLE];
    else
    {
        if([self is_BluetoothAuthorized])
        {
            [[WarningManager sharedInstance]AlertEvent:BLUETOOTH_ALLOWED];
            if([self is_BluetoothOn])
                [[WarningManager sharedInstance]AlertEvent:BLUETOOTH_ON];
            else
                [[WarningManager sharedInstance]AlertEvent:BLUETOOTH_OFF];
        }
        else
            [[WarningManager sharedInstance]AlertEvent:BLUETOOTH_NOT_ALLOWED];
    }
}

-(bool)is_Scanning{
    return bol_Scanning;
}

-(void)get_Peripherals:(NSArray*) UUID_List{
    if (_CentralManager.state == CBCentralManagerStatePoweredOn) {
        [_CentralManager retrievePeripherals:UUID_List];
    }
}


/****************************************************************************/
/*								Discovery                                   */
/****************************************************************************/
- (void) startScanning
{
    NSLog(@"Bluetooth Controller startScanning");
   if(bol_Scanning==true)
        [self stopScanning];
    
    bol_Scanning = true;
    
#warning have not tried setting this to yes before
    NSDictionary	*options	= [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
    
    //Specify only certain service UUID to be scanned for
    [_CentralManager scanForPeripheralsWithServices:[self get_ServiceUUIDForScan] options:options];
    NSLog(@"%@ Elite , %@Ipad",[CBUUID UUIDWithString:kEliteServiceUUID],[CBUUID UUIDWithString:kiPadServiceUUID]);
    [_discoveryObserver AlertEvent:DISCOVERING_DEVICES];
}

-(void) scan
{
    NSLog(@"Bluetooth Controller startScanning");
    if(bol_Scanning==true)
        [self stopScanning];
    
    bol_Scanning = true;
    
#warning have not tried setting this to yes before
    NSDictionary	*options	= [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
    
    //Specify only certain service UUID to be scanned for
    [_CentralManager scanForPeripheralsWithServices:[self get_ServiceUUIDForScan] options:options];
    NSLog(@"%@ Elite , %@Ipad",[CBUUID UUIDWithString:kEliteServiceUUID],[CBUUID UUIDWithString:kiPadServiceUUID]);

}

- (void) stopScanning
{
    NSLog(@"Bluetooth Controller stopScanning");
    [_CentralManager stopScan];
    bol_Scanning = false;
}


- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    //check for existing device that has the same peripheral
    Protag_Device *discovered_device = [[DeviceManager sharedInstance]Device_With_Peripheral:peripheral];
    
    NSLog(@"advertismentData: %@",advertisementData);
    NSLog(@"RSSI of discovered device %d",RSSI.integerValue);
   
    //For iPad reconnection
    if(_RegrabiPad.count>0)
    {
        for(int i=0;i<_RegrabiPad.count;i++)
        {
            Protag_Device *device = [_RegrabiPad objectAtIndex:i];
            //if([device str_UUID]
            for(int k=0;k<[peripheral services].count;k++)
            {
                CBService *tempServce = [[peripheral services]objectAtIndex:k];
                
                if([[device str_UUID]isEqualToString:(NSString*)[tempServce UUID]])
                {
                    NSLog(@"Found unique id service of ipad");
                    [device set_peripheral:peripheral];
                    [_RegrabiPad removeObject:device];
                    i--;
                    break;
                }
            }
        }
        
        if(_RegrabiPad.count==0)
           [self stopScanning];
    }
    
    //only add to discovery if it is quite close to the phone
    //Adjust this value for detection range
    if(RSSI.integerValue > -50)
    {
#warning check for "protag" name and MAC address
        if (![_Discovered_Peripherals containsObject:peripheral] && discovered_device==NULL && _proximityDevice==NULL)
        {
         //   if([[advertisementData objectForKey:@"kCBAdvDataLocalName"] isEqual:@"PROTAG"]){
                [peripheral setDelegate:self];
                [_Discovered_Peripherals addObject:peripheral];
                if([advertisementData objectForKey:@"kCBAdvDataManufacturerData"]!=NULL)
                    [_Discovered_MAC addObject:((NSData*)[advertisementData objectForKey:@"kCBAdvDataManufacturerData"]).description];
                else{
                    //Generate Empty MAC if AdvDataManufacturerData not found
                    //iPad cannot put AdvDataManufacturerData
                    NSString* MACStr = @"000000000000";
                    [_Discovered_MAC addObject:MACStr];
                }
          //  }
            [_discoveryObserver AlertEvent:DISCOVERED_DEVICE];
        }
    }
    else
    {
        [self startScanning];
    }
    
    if(discovered_device != NULL && [_Discovered_Peripherals containsObject:peripheral] && [advertisementData objectForKey:@"kCBAdvDataManufacturerData"]!=NULL){
            NSString *tempMAC = [[advertisementData objectForKey:@"kCBAdvDataManufacturerData"]description];
            tempMAC = [tempMAC stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
            tempMAC = [tempMAC stringByReplacingOccurrencesOfString:@" " withString:@""];
            NSMutableString *tempStr = [NSMutableString stringWithString:tempMAC];
            [tempStr insertString:@":" atIndex:2];
            [tempStr insertString:@":" atIndex:5];
            [tempStr insertString:@":" atIndex:8];
            [tempStr insertString:@":" atIndex:11];
            [tempStr insertString:@":" atIndex:14];
            tempMAC = tempStr;
        
            if([tempMAC isEqualToString:[discovered_device str_MAC]]){
                discovered_device._peripheral = peripheral;
                [peripheral setDelegate:self];
                [self stopScanning];
            }
    }
        /*
    NSString *deviceName = [advertisementData objectForKey:@"kCBAdvDataLocalName"];
    
    if ([deviceName isEqualToString:@"PROTAG"]) {
        NSString *macAddress = ((NSData*)[advertisementData objectForKey:@"kCBAdvDataManufacturerData"]).description;
        macAddress = [self convertMacAdress:macAddress];
        [MacAddress addObject:macAddress];
        NSLog(@"%@",MacAddress);
        
        if(MacAddress isEqual _Discovered_Peripherals.m)
    }
         */
    //Proximity detection for Radar
    if(discovered_device!=NULL && _proximitydelegate!=NULL && _proximityDevice!=NULL)
    {
        if([discovered_device isEqual:_proximityDevice])
        {
            NSLog(@"proximity device %@ found with RSSI %@",discovered_device.str_Name,RSSI);
            [_proximitydelegate detectedProximityDevice:discovered_device withRSSI:(int)RSSI];
        }
    }else if(_proximitydelegate!=NULL && _proximityDevice!=NULL && [advertisementData objectForKey:@"kCBAdvDataManufacturerData"]!=NULL){
        NSString *tempMAC = [[advertisementData objectForKey:@"kCBAdvDataManufacturerData"]description];
        tempMAC = [tempMAC stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
        tempMAC = [tempMAC stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSMutableString *tempStr = [NSMutableString stringWithString:tempMAC];
        [tempStr insertString:@":" atIndex:2];
        [tempStr insertString:@":" atIndex:5];
        [tempStr insertString:@":" atIndex:8];
        [tempStr insertString:@":" atIndex:11];
        [tempStr insertString:@":" atIndex:14];
        tempMAC = tempStr;

        if([tempMAC isEqualToString:[_proximityDevice str_MAC]]){
            _proximityDevice._peripheral = peripheral;
            [peripheral setDelegate:self];
            [_proximitydelegate detectedProximityDevice:_proximityDevice withRSSI:(int)RSSI];
        }
    }
    
}
/*
-(NSString *)convertMacAdress:(NSString *)str{
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
*/
#pragma mark -
#pragma mark Connection/Disconnection
/****************************************************************************/
/*						Connection/Disconnection                            */
/****************************************************************************/

- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    //Remove peripheral from discovered peripheral
    if ([_Discovered_Peripherals containsObject:peripheral])
    {
        NSString *tempMac = (NSString*)[_Discovered_MAC objectAtIndex:
                                        [_Discovered_Peripherals indexOfObject:peripheral]];
        Protag_Device *_newDevice = [[Protag_Device alloc]init_WithPeripheral:peripheral andMAC:tempMac];
        //Add to Maincontroller database
        [[DeviceManager sharedInstance]add_Device: _newDevice];
        [_newDevice set_Status:STATUS_CONNECTED];
        [_Discovered_MAC removeObjectAtIndex:
        [_Discovered_Peripherals indexOfObject:peripheral]];
        [_Discovered_Peripherals removeObject:peripheral];
        //start discovering the services of connected peripheral
        [peripheral discoverServices:[[NSArray alloc]initWithObjects:[CBUUID UUIDWithString:kEliteServiceUUID],[CBUUID UUIDWithString:kiPadServiceUUID], nil]];

        //Alert Observer
        [_discoveryObserver AlertEvent:CONNECTED_DEVICE];
    }else if([[DeviceManager sharedInstance]has_Device_with_Peripheral:peripheral])
    {
        //Rediscover services to set notify for characteristics
        [peripheral discoverServices:[[NSArray alloc]initWithObjects:[CBUUID UUIDWithString:kEliteServiceUUID],[CBUUID UUIDWithString:kiPadServiceUUID], nil]];
        //Update status : Connected
        [[DeviceManager sharedInstance]update_Device_Status:peripheral withStatus: STATUS_CONNECTED];
    }else if(_proximityDevice!=NULL && [_proximityDevice._peripheral isEqual:peripheral]){
        [peripheral discoverServices:[[NSArray alloc]initWithObjects:[CBUUID UUIDWithString:kEliteServiceUUID],[CBUUID UUIDWithString:kiPadServiceUUID], nil]];
        [_proximityDevice set_Status:STATUS_CONNECTED];
    }else{
        NSLog(@"Disconnecting peripheral due to not appearing on discovery nor devicelist");
        //if not inside DeviceManager list nor discovery list, disconnect from it
        [_CentralManager cancelPeripheralConnection:peripheral];
    }
    
}


- (void) centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"BluetoothController received failed bluetooth connection");
    if(error)
        NSLog(@"Error: %@",error);
    if ([_Discovered_Peripherals containsObject:peripheral])
    {
        [_discoveryObserver AlertEvent:FAIL_CONNECT_DEVICE];
        [_Discovered_Peripherals removeObject:peripheral];
    }
    else{
        Protag_Device *tempDevice = [[DeviceManager sharedInstance]Device_With_Peripheral:peripheral];
        
        if([tempDevice get_StatusCode]==STATUS_SECURE_ZONE){
            NSLog(@"Connection failed in Secure zone, attempting to try again");
           [tempDevice Connect];
        }
        else{
            NSLog(@"Bluetooth Fail to connectperipheral");
            //Update status: Conection Failed
              if([peripheral isConnected]==false){
                [[DeviceManager sharedInstance]update_Device_Status:peripheral withStatus: STATUS_CONNECTION_FAILED];
            }else{
                //Bug fix attempt
                [[DeviceManager sharedInstance]update_Device_Status:peripheral withStatus: STATUS_CONNECTED];
            }
        }
    }
}


- (void) centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    Protag_Device *temp_Device = [[DeviceManager sharedInstance]Device_With_Peripheral:peripheral];
    
    //This part used to detect device lost
    if(temp_Device!=NULL)
    {
        if([temp_Device get_StatusCode]==STATUS_CONNECTED)
        {
            //Add to lost device List, MainController will set the status for Protag_Device
            
            //Do not add to lost device if in proximity mode
            if(!(_proximityDevice!=NULL && [temp_Device isEqual:_proximityDevice]))
            {
                NSLog(@"Peripheral disconnected, adding to lost device");
                [[DeviceManager sharedInstance]Add_LostDevice:temp_Device];
            }
        }
        else if([temp_Device get_StatusCode]==STATUS_DISCONNECTING){
            [[DeviceManager sharedInstance]update_Device_Status:peripheral withStatus: STATUS_DISCONNECTED];
        }
        else{
            NSLog(@"Status code: %d before disconnecting device: %@",[temp_Device get_StatusCode],temp_Device.str_Name);
        }
    }
    else{
        NSLog(@"temp_Device was NULL in disconnecting");
    }
}

- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals{
    NSMutableArray *temp = [peripherals mutableCopy];
    NSMutableArray *_devices = [[DeviceManager sharedInstance]_currentDevices];
    Boolean bol_PeripheralFound = false;
    
    //Find similar UUID
    for(int i=0;i<_devices.count;i++){
        Protag_Device *tempDevice = [_devices objectAtIndex:i];
        for(int k=0;k<temp.count;k++){
            CBPeripheral *tempPeripheral = (CBPeripheral*)[temp objectAtIndex:k];
            
#warning to add in ipad stuff
            if([tempDevice is_iPad])
            {
                //Must spam all to discover the correct one
                [tempPeripheral discoverServices:@[[CBUUID UUIDWithString:kiPadServiceUUID]]];
            }
            else if([tempDevice isEqualUUID:tempPeripheral])
            {
                [tempDevice Set_Peripheral:tempPeripheral];
                [tempPeripheral setDelegate:self];
                //After remove object from temp, reduce the k
                [temp removeObjectAtIndex:k];
                k--;
                bol_PeripheralFound = true;
                NSLog(@"Found Peripheral for Protag Device: %@",tempDevice.str_Name);
                break;
            }
        }
        //if cannot find the UUID of such peripheral show Error
        if(bol_PeripheralFound==false){
            NSLog(@"Error: could not find peripheral for Protag Device : %@",tempDevice.str_Name);
        }
    }
}


- (void)clearDiscoveredDevices
{
    [_Discovered_Peripherals removeAllObjects];
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    //state change when bluetooth on / off etc
    switch (central.state){
        case CBCentralManagerStatePoweredOff:
            [[WarningManager sharedInstance]AlertEvent:BLUETOOTH_OFF];
            if([self isBluetoothBackground])
            {
                //Only show BluetoothLocalNotification if there is at least 1 device connected
                for(int i=0;i<[[[DeviceManager sharedInstance]_currentDevices]count];i++)
                {
                    Protag_Device *tempDevice = (Protag_Device*)[[[DeviceManager sharedInstance]_currentDevices]objectAtIndex:i];
                    if([tempDevice get_StatusCode]==STATUS_CONNECTED || [tempDevice get_StatusCode] == STATUS_SECURE_ZONE){
                        [self ShowBluetoothLocalNotification];
                    }
                }
                //Also show BluetoothNotification if the device is in Snooze
                for(int i=0;i<[[[DeviceManager sharedInstance]_LostDevices]count];i++)
                {
                    Protag_Device *tempDevice = (Protag_Device*)[[[DeviceManager sharedInstance]_LostDevices]objectAtIndex:i];
                    if([tempDevice get_StatusCode]==STATUS_SNOOZE){
                        [self ShowBluetoothLocalNotification];
                    }
                }
            }
            else
                     [self ShowBluetoothLocalNotification];
            break;
        case CBCentralManagerStatePoweredOn:
            [[WarningManager sharedInstance]AlertEvent:BLUETOOTH_ON];
            break;
        case CBCentralManagerStateUnauthorized:
            [[WarningManager sharedInstance]AlertEvent:BLUETOOTH_NOT_ALLOWED];
            break;
        case CBCentralManagerStateUnsupported:
            [[WarningManager sharedInstance]AlertEvent:BLUETOOTH_NOT_COMPATABLE];
            break;
        case CBCentralManagerStateUnknown:
        default:
            return;
    }
}

/****************************************************************************/
/*                            CBPeripheralDelegate                          */
/****************************************************************************/

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    NSLog(@"Discovered Characteristics for service name: %@",(NSString*)service.UUID);
    if(error)
        NSLog(@"Error when discovering characteristics: %@",error);
    
    for(int i=0;i<[service characteristics].count;i++)
    {
        CBCharacteristic *temp = [[service characteristics]objectAtIndex:i];
        NSLog(@"Characteristic UUID: %@ from %@",(NSString*)[temp UUID],(NSString*)service.UUID);
        Protag_Device *tempDevice = [[DeviceManager sharedInstance]Device_With_Peripheral:peripheral];
        
        
        [peripheral readValueForCharacteristic:temp];
        
#warning possible problem for normal radar
        if(_proximityDevice!=NULL && [_proximityDevice._peripheral isEqual:peripheral]){
            tempDevice = _proximityDevice;
        }
        
        //UUID of characteristic 2A19 is used for Protag to send RSSI, battery level and for alerting the phone
        if(tempDevice!=NULL)
        {
            if([temp.UUID isEqual:[CBUUID UUIDWithString:kEliteReadCharacteristicUUID]])
            {
                [tempDevice set_2A19Characteristic:temp];
                [tempDevice check_NotifyCharacteristic];
            }
            
            //Store the characteristic to be used to speed up the RSSI update
            if([temp.UUID isEqual:[CBUUID UUIDWithString:kEliteSpeedUpCharacteristicUUID]]){
                NSLog(@"Setting up _speedUpCharacteristic");
                [tempDevice set_speedUpCharacteristic:temp];
            }
            
#warning must stop sending after once
            //Write the UUID into characteristic for iPad due to ever changing UUID
            if([temp.UUID isEqual:[CBUUID UUIDWithString:kiPadWritableCharacteristicUUID]]){
                NSLog(@"write to iPad the new UUID");
                NSString *tempStr = (NSString*)CFBridgingRelease(CFUUIDCreateString(nil,peripheral.UUID));
                
                //cannot write too long to characteristic so have to split to 2 parts
                NSString *tempStrPart1 = [tempStr substringToIndex:20];
                NSString *tempStrPart2 = [tempStr substringFromIndex:20];
                NSLog(@"Part 1 UUID: %@",tempStrPart1);
                NSLog(@"Part 2 UUID: %@",tempStrPart2);
                
                NSData *data = [tempStrPart1 dataUsingEncoding:NSUTF8StringEncoding];
                
                [peripheral writeValue:data forCharacteristic:temp type:CBCharacteristicWriteWithoutResponse];
                
                data = [tempStrPart2 dataUsingEncoding:NSUTF8StringEncoding];
                
                [peripheral writeValue:data forCharacteristic:temp type:CBCharacteristicWriteWithoutResponse];
            }
        }
        else{
            NSLog(@"Discovered Characteristic but had NULL protag device");
            
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    //not using descriptor
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error
{
    //not used
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    //180F is service for 2A19 characteristic
    NSLog(@"Discovered Services");
    if(error)
        NSLog(@"Error when discovering service: %@",error);
    for(int i=0;i<[peripheral services].count;i++)
    {
        CBService *temp_service = [[peripheral services]objectAtIndex:i];
        NSLog(@"Discovered Service UUID: %@",(NSString*)temp_service.UUID);
        [peripheral discoverCharacteristics:nil forService:temp_service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    //not used 
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if(characteristic.value==NULL)
        return;
    
    if(error!=NULL)
    {
        NSLog(@"Characteristic update error: %@",error);
        return;
    }
    
    if([characteristic.UUID isEqual:[CBUUID UUIDWithString:kEliteReadCharacteristicUUID]]){
        
        //First we find the category of the information sent using the same channel
        uint8_t _CharacteristicCategory  = 0;
        [[characteristic value] getBytes:&_CharacteristicCategory length:sizeof (_CharacteristicCategory)];

        uint16_t positive16 =0;
        [[characteristic value] getBytes:&positive16 length:sizeof (positive16)];
        int16_t negative16 = 0;
        [[characteristic value] getBytes:&negative16 length:sizeof (negative16)];
        
        NSLog(@"Characteristic: %@ has a value of %@ and %x",characteristic.UUID,characteristic.value,positive16);
        
        Protag_Device *device = [[DeviceManager sharedInstance]Device_With_Peripheral:peripheral];
        
        //possible problem
        if(_proximityDevice!=NULL && [_proximityDevice._peripheral isEqual:peripheral]){
            device = _proximityDevice;
        }
        
        if(_CharacteristicCategory==0xfc){
            //For Protag to alert the phone
            //Protag_Device has pressed the ring phone button
            NSLog(@"Detected Ring Mobile Button");
            [[Alarm sharedInstance]ProtagAlertsPhone:device];
        }
        else if(_CharacteristicCategory==0xfd){
            //For RSSI readings from the Protag

            int ConvertedRSSI = negative16>>8;
            NSLog(@"Converted RSSI: %d",ConvertedRSSI);
            [device update_RSSI:ConvertedRSSI];//alerting the alarm to ring will be done by the device
        }
        else if(_CharacteristicCategory==0xfe){
            //For battery readings of the Protag
            int ConvertedBattery = positive16>>8;
            NSLog(@"Converted Battery Readings: %d",ConvertedBattery);
            [device update_Battery:ConvertedBattery];
        }
        else{
            NSLog(@"Reading from Characteristic for Battery Update");
            [device update_Battery:positive16];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
{
    //not using descriptor
    //descriptors gave 0
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"UUID of characteristic writing to: %@",characteristic.UUID);
    if(error)
        NSLog(@"Error when writing to characteristic: %@",error);
    else if([characteristic.UUID isEqual:[CBUUID UUIDWithString:kEliteSpeedUpCharacteristicUUID]])
        NSLog(@"write to speedup successful");
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
{
    //not using descriptor
}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
    //empty
}



//********************************************************
//Local Notification
//********************************************************

#warning bad way of checking background here, shouldn't do it here
-(BOOL)isBluetoothBackground{
    return [UIApplication sharedApplication].applicationState == UIApplicationStateBackground;
}

-(void)ShowBluetoothLocalNotification{
    NSLog(@"Show Local Notification");
    //instant local notification
    //[[UIApplication sharedApplication]cancelAllLocalNotifications];
    
    UILocalNotification *_LocalBluetoothNotification = [[UILocalNotification alloc]init];
    
    _LocalBluetoothNotification.alertBody = [NSString stringWithFormat:@"Don't Turn Off Bluetooth,Please Turn On Bluetooth"];
    _LocalBluetoothNotification.alertAction = @"View";
    
    _LocalBluetoothNotification.soundName = [[RingtoneManager sharedInstance]get_ToneFilename];
    _LocalBluetoothNotification.applicationIconBadgeNumber +=1;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:_LocalBluetoothNotification];
    
    //Set devices as Lost
    if([[BluetoothManager sharedInstance]is_BluetoothOn] == FALSE)
    {
       /* for(int i = 0;i<[[DeviceManager sharedInstance]_LostDevices].count;i++)
        {
            Protag_Device *device = (Protag_Device*)[[[DeviceManager sharedInstance]_LostDevices]objectAtIndex:i];
            //if snooze, still show lost
            if([device get_StatusCode]!=STATUS_DISCONNECTED && [device get_StatusCode]!=STATUS_CONNECTION_FAILED)
                [[DeviceManager sharedInstance]Add_LostDevice:device];
        }*/
        for(int i=0;i<[[DeviceManager sharedInstance]_currentDevices].count;i++)
        {
            Protag_Device *device = (Protag_Device*)[[[DeviceManager sharedInstance]_currentDevices]objectAtIndex:i];
            //if lost, still show lost
           // if([device get_StatusCode]!=STATUS_DISCONNECTED && [device get_StatusCode]!=STATUS_CONNECTION_FAILED && [device get_StatusCode] != STATUS_SECURE_ZONE)
                if([device get_StatusCode] == STATUS_CONNECTED)
                    [[DeviceManager sharedInstance]Add_LostDevice:device];
        }
    }
}

-(void)SpeedupUpdates:(Protag_Device*)device{
    if(device==NULL)
        return;
    
    if(device._speedUpCharacteristic==NULL)
    {
        NSLog(@"_speedUpCharacteristic is NULL");
        return;
    }
    
    if(device._peripheral!=NULL){
        NSString *tempStr = [NSString stringWithFormat:@"ok"];
        NSData *data = [tempStr dataUsingEncoding:NSUTF8StringEncoding];
        
        //Cannot do writeWithResponse else will not work
        [device._peripheral writeValue:data forCharacteristic:device._speedUpCharacteristic type:CBCharacteristicWriteWithoutResponse];
        
        NSLog(@"writing to speedup peripheral");
    }
}

-(void)regrab_iPadPeripheral:(Protag_Device*)device{
    if(![_RegrabiPad containsObject:device]){
        [_RegrabiPad addObject:device];
        [self startScanning];
    }
}

-(NSArray*)get_ServiceUUIDForScan{
    NSMutableArray *tempArray = [[NSMutableArray alloc]init];
    
    for(int i=0;i<_RegrabiPad.count;i++)
    {
        Protag_Device *device = [_RegrabiPad objectAtIndex:i];
        //Specify only certain service UUID to be scanned for
        [tempArray addObject:[CBUUID UUIDWithString:[device str_UUID]]];
    }
    
    [tempArray addObject:[CBUUID UUIDWithString:kEliteServiceUUID]];
    [tempArray addObject:[CBUUID UUIDWithString:kiPadServiceUUID]];
    
    return tempArray;
}

@end
