#import <Foundation/Foundation.h>

//Class in charge of saving/loading data

@interface DataManager : NSObject{
    NSUserDefaults *_Prefs;
    bool bol_Not_First_Load;
}

@property (nonatomic) bool Settings_Vibration;
@property (nonatomic) bool Settings_Music;

//Mobile
@property (nonatomic) bool Settings_Tracking;
@property (nonatomic) bool Settings_Backup;

//Hints/Wizard
@property (nonatomic) int Hints_Step;


+(id)sharedInstance;//Singleton
-(void)save_Devices;
-(NSMutableArray*)load_Devices;
-(void)save_Settings;
-(void)load_Settings;
-(void)save_Secure_Zone;
-(NSMutableArray*)load_Secure_Zone;
-(void)save_Secure_Geofencing;
-(NSMutableArray*)load_Secure_Geofencing;


-(void)save_Account;
-(void)load_Account;

@end
