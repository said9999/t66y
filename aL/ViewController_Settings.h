#import <UIKit/UIKit.h>
#import "ViewController_Ringtone.h"
#import "ViewController_Wifi.h"
#import "ViewController_Geofencing.h"

@interface ViewController_Settings : UIViewController<UITableViewDelegate,UITableViewDataSource>{
    ViewController_Ringtone * _RingtoneController;
    ViewController_Wifi *_WifiController;
    ViewController_Geofencing *_GeofencingController;
}

@property IBOutlet UITableViewCell *Cell_VibrationOnOff;
@property IBOutlet UITableViewCell *Cell_SoundOnOff;
@property IBOutlet UITableViewCell *Cell_Ringtone;
@property IBOutlet UITableViewCell *Cell_SecureWiFi;
@property IBOutlet UITableViewCell *Cell_Geofencing;
@property IBOutlet UITableViewCell *Cell_About;

-(void)ToggleVibration:(id)sender;
-(void)ToggleMusic:(id)sender;
-(void)reloadNib;

@end
