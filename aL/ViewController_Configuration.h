#import <UIKit/UIKit.h>
#import "CrowdTrackNotificationHandler.h"

@interface ViewController_Configuration : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
}
@property (nonatomic) UITableView *MobileTable;
@property IBOutlet UITableViewCell *Cell_Tracking;
@property IBOutlet UITableViewCell *Cell_BackUp;
@property IBOutlet UITableViewCell *Cell_Developer;
@property IBOutlet UITableViewCell *Cell_LogOut;
@property (nonatomic) UISwitch *trackingOnOff;
@property (nonatomic) UISwitch *backUpOnOff;
@property (nonatomic) UISwitch *developerOnOff;
@property (nonatomic) UILabel *lbl_LogOut;
@property (nonatomic) UILabel *lblDetail_LogOut;
@property (nonatomic) UIBarButtonItem *barBtn_Back;
@property (nonatomic) UIViewController *nearbyDevices;

-(void)ToggleTracking:(id)sender;
-(void)ToggleBackUp:(id)sender;
-(void)ToggleCrowdTracking:(id)sender;
-(void)ToggleDeveloper:(id)sender;
-(void)BackButtonPressed;
-(void)refreshMobileTable;
+(void)updateFindDevices:(BOOL)isToIncrease;
@end
