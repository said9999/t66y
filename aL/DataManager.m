#import "DataManager.h"
#import "DeviceManager.h"
#import "Protag_Device.h"
#import "RingtoneManager.h"
#import "WifiDetector.h"
#import "FencingManager.h"
#import "AccountManager.h"


//Constants
static NSString * const KEY_DEVICES = @"KEY_DEVICES";
static NSString * const KEY_VIBRATION = @"KEY_VIBRATION";
static NSString * const KEY_MUSIC = @"KEY_MUSIC";
static NSString * const KEY_NOT_FIRST_LOAD = @"KEY_NOT_FIRST_LOAD";
static NSString * const KEY_TONE = @"KEY_TONE";
static NSString * const KEY_SECURE_ZONE = @"KEY_SECURE_ZONE";//WIFI Secure Zone
static NSString * const KEY_SECURE_GEOFENCING = @"KEY_SECURE_GEOFENCING";
static NSString * const KEY_TRACKING = @"KEY_TRACKING";
static NSString * const KEY_BACKUP = @"KEY_BACKUP";
static NSString * const KEY_HINT = @"KEY_HINT";
static NSString * const KEY_LOGGEDIN = @"KEY_LOGGEDIN";
static NSString * const KEY_REGID = @"KEY_REGID";
static NSString * const KEY_USERID = @"KEY_USERID";
static NSString * const KEY_EMAIL = @"KEY_EMAIL";
static NSString * const KEY_ALREADYREGISTERED = @"KEY_ALREADYREGISTERED";
static NSString * const KEY_ISMISSING = @"KEY_ISMISSING";
static NSString * const KEY_ISDEVELOPER = @"KEY_ISDEVELOPER";
static NSString * const KEY_ACCURACY = @"KEY_ACCURACY";


@implementation DataManager

@synthesize Settings_Vibration;
@synthesize Settings_Music;
@synthesize Settings_Backup;
@synthesize Settings_Tracking;
@synthesize Hints_Step;

//Singleton
+(id)sharedInstance{
    static DataManager *_instance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

-(id)init{
    if(self = [super init]){
        NSLog(@"Initializing DataManager");
        _Prefs = [NSUserDefaults standardUserDefaults];
        
        //bol_Not_First_Load is used to have a initial setting for the other settings because all settings will return false if there are no saved settings        bol_Not_First_Load = false;
        [self load_Settings];
        [self load_Account];
        
        //Default values for Settings
        if(bol_Not_First_Load==false){
            Settings_Vibration = true;
            Settings_Music = true;
            Settings_Tracking = false;
            Settings_Backup = false;
            Hints_Step = -1;
            [[AccountManager sharedAccountManager]setUser_Accuracy:kCLLocationAccuracyHundredMeters];
        }
        NSLog(@"DataManager initialized");
    }
    return self;
}

-(void)save_Devices{
    //Must save the custom class in a special way
    NSMutableArray* _save = [[NSMutableArray alloc]init];
    NSMutableArray* _devices = [[DeviceManager sharedInstance] _currentDevices];
    
    for(int i=0;i<_devices.count;i++){
        [_save addObject:[NSKeyedArchiver archivedDataWithRootObject:[_devices objectAtIndex:i]]];
        NSLog(@"Saved %@",[[_devices objectAtIndex:i]str_Name]);
    }
    
    [_Prefs setObject: _save forKey:KEY_DEVICES];
    [_Prefs synchronize];
}

-(NSMutableArray*)load_Devices{
    //When retrieving saved values it returns NSArray which does not allow us to edit, thus we need to convert it to NSMUtableArray
    NSArray* _oldSave = [_Prefs objectForKey:KEY_DEVICES];
    NSMutableArray* _newDeviceList = [[NSMutableArray alloc]init];
    
    
    //if no previous save, return a empty NSMutableArray
    if(_oldSave==NULL)
        return [[NSMutableArray alloc]init];
    
    for(int i=0;i<_oldSave.count;i++)
    {
        //Add object to list
        Protag_Device *temp = (Protag_Device*)[NSKeyedUnarchiver unarchiveObjectWithData:[_oldSave objectAtIndex:i]];
        [_newDeviceList addObject:temp];
        
        NSLog(@"Loaded %@",temp.str_Name);
    }
    return _newDeviceList;
}

-(void)save_Settings{
    [_Prefs setBool:Settings_Vibration forKey:KEY_VIBRATION];
    [_Prefs setBool:Settings_Music forKey:KEY_MUSIC];
    [_Prefs setBool:Settings_Tracking forKey:KEY_TRACKING];
    [_Prefs setBool:Settings_Backup forKey:KEY_BACKUP];
    [_Prefs setInteger:[[RingtoneManager sharedInstance]get_ToneInt] forKey:KEY_TONE];
    [_Prefs setInteger:Hints_Step forKey:KEY_HINT];
    [_Prefs setBool:true forKey:KEY_NOT_FIRST_LOAD];
}

-(void)load_Settings{
    bol_Not_First_Load=[_Prefs boolForKey:KEY_NOT_FIRST_LOAD];
    Settings_Vibration=[_Prefs boolForKey:KEY_VIBRATION];
    Settings_Music=[_Prefs boolForKey:KEY_MUSIC];
    Settings_Tracking=[_Prefs boolForKey:KEY_TRACKING];
    Settings_Backup=[_Prefs boolForKey:KEY_BACKUP];
    Hints_Step=[_Prefs integerForKey:KEY_HINT];
    
    if(bol_Not_First_Load==true)
        [[RingtoneManager sharedInstance]set_Tone:[_Prefs integerForKey:KEY_TONE]];
}

-(void)save_Secure_Zone{
    //Must save the custom class in a special way
    NSMutableArray* _save = [[NSMutableArray alloc]init];
    NSMutableArray* _WifiList = [[WifiDetector sharedInstance] _WifiList];
    
    //This saves a list of wifi
    for(int i=0;i<_WifiList.count;i++){
        [_save addObject:[NSKeyedArchiver archivedDataWithRootObject:[_WifiList objectAtIndex:i]]];
    }
    
    [_Prefs setObject: _save forKey:KEY_SECURE_ZONE];
    [_Prefs synchronize];
    NSLog(@"Saved Wifi Secure Zones");
}

-(NSMutableArray*)load_Secure_Zone{
    //When retrieving saved values it returns NSArray which does not allow us to edit, thus we need to convert it to NSMUtableArray
    NSArray* _oldSave = [_Prefs objectForKey:KEY_SECURE_ZONE];
    NSMutableArray* _secureZones = [[NSMutableArray alloc]init];
    
    
    //if no previous save, return a empty NSMutableArray
    if(_oldSave==NULL)
        return [[NSMutableArray alloc]init];

    for(int i=0;i<_oldSave.count;i++)
    {
        //Add object to list
        WifiData *temp = (WifiData*)[NSKeyedUnarchiver unarchiveObjectWithData:[_oldSave objectAtIndex:i]];
        [_secureZones addObject:temp];
    }
    
    NSLog(@"Loaded Wifi Secure Zones");
    return _secureZones;
}


-(void)save_Secure_Geofencing{
    //Must save the custom class in a special way
    NSMutableArray* _save = [[NSMutableArray alloc]init];
    NSMutableArray* _FencingList = [[FencingManager sharedInstance]_FencingList];
    
    //This saves a list of geofencing
    for(int i=0;i<_FencingList.count;i++){
        [_save addObject:[NSKeyedArchiver archivedDataWithRootObject:[_FencingList objectAtIndex:i]]];
    }
    
    [_Prefs setObject: _save forKey:KEY_SECURE_GEOFENCING];
    [_Prefs synchronize];
    NSLog(@"Saved Secure Geofencing");
}

-(NSMutableArray*)load_Secure_Geofencing{
    //When retrieving saved values it returns NSArray which does not allow us to edit, thus we need to convert it to NSMUtableArray
    NSArray* _oldSave = [_Prefs objectForKey:KEY_SECURE_GEOFENCING];
    NSMutableArray* _secureGeofencing = [[NSMutableArray alloc]init];
    
    
    //if no previous save, return a empty NSMutableArray
    if(_oldSave==NULL)
        return [[NSMutableArray alloc]init];
    
    for(int i=0;i<_oldSave.count;i++)
    {
        //Add object to list
        FencingData *temp = (FencingData*)[NSKeyedUnarchiver unarchiveObjectWithData:[_oldSave objectAtIndex:i]];
        [_secureGeofencing addObject:temp];
    }
    
    NSLog(@"Loaded Secure Geofencing");
    return _secureGeofencing; 
}

-(void)save_Account{
    [_Prefs setObject:[[AccountManager sharedAccountManager]str_RegID] forKey:KEY_REGID];
    [_Prefs setObject:[[AccountManager sharedAccountManager]str_Email] forKey:KEY_EMAIL];
    [_Prefs setObject:[[AccountManager sharedAccountManager]str_UserID] forKey:KEY_USERID];
    [_Prefs setBool:[[AccountManager sharedAccountManager]bol_isLogined] forKey:KEY_LOGGEDIN];
    [_Prefs setBool:[[AccountManager sharedAccountManager]bol_isMissing] forKey:KEY_ISMISSING];
    [_Prefs setBool:[[AccountManager sharedAccountManager]bol_isRegistered] forKey:KEY_ALREADYREGISTERED];
    [_Prefs setDouble:[[AccountManager sharedAccountManager]user_Accuracy] forKey:KEY_ACCURACY];
    [_Prefs setBool:[[AccountManager sharedAccountManager]bol_isDeveloper] forKey:KEY_ISDEVELOPER];
    
    [_Prefs synchronize];
    NSLog(@"RegID = %@",[[AccountManager sharedAccountManager]str_RegID]);
    NSLog(@"Email = %@",[[AccountManager sharedAccountManager]str_Email]);
    NSLog(@"UserID = %@",[[AccountManager sharedAccountManager]str_UserID]);
    NSLog(@"Saved Account");
}

-(void)load_Account{
    //RegID
    NSString *regID = [_Prefs objectForKey:KEY_REGID];
	if(regID == nil || [regID length] <= 0){
		NSString * uuid = [[UIDevice currentDevice] identifierForVendor].UUIDString;
        
		[[AccountManager sharedAccountManager]setStr_RegID:uuid];
	}else{
        [[AccountManager sharedAccountManager]setStr_RegID:regID];
    }
    
    //UserID
    NSString *userID = [_Prefs objectForKey:KEY_USERID];
    if(userID == nil)
        [[AccountManager sharedAccountManager]setStr_UserID:@""];
    else
        [[AccountManager sharedAccountManager]setStr_UserID:userID];
    
    //Email
    NSString *email = [_Prefs objectForKey:KEY_EMAIL];
    if(email == nil)
        [[AccountManager sharedAccountManager]setStr_Email:@""];
    else
         [[AccountManager sharedAccountManager]setStr_Email:email];

    //Loggined
    [[AccountManager sharedAccountManager]setBol_isLogined:[_Prefs boolForKey:KEY_LOGGEDIN]];

    //Is Missing
    [[AccountManager sharedAccountManager]setBol_isMissing:[_Prefs boolForKey:KEY_ISMISSING]];
    
    //Registered
    [[AccountManager sharedAccountManager]setBol_isRegistered:[_Prefs boolForKey:KEY_ALREADYREGISTERED]];
    
    //Accuracy
    double accuracy = [_Prefs doubleForKey:KEY_ACCURACY];
    [[AccountManager sharedAccountManager]setUser_Accuracy:accuracy];
    
    //Is Developer
    [[AccountManager sharedAccountManager]setBol_isDeveloper:[_Prefs boolForKey:KEY_ISDEVELOPER]];
    
    NSLog(@"Loaded Account");
}

@end
