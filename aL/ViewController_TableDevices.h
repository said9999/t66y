#import <UIKit/UIKit.h>
#import "DeviceManager.h"

@interface ViewController_TableDevices : UIViewController <UITableViewDelegate,UITableViewDataSource,DeviceObserver>
{
    Protag_Device *_device;
}

@property (nonatomic) UITableView *currentDeviceTable;
@property IBOutlet UITableViewCell *Cell_DeviceName;
@property IBOutlet UITableViewCell *Cell_DeviceStatus;
@property IBOutlet UITableViewCell *Cell_Snooze;
@property IBOutlet UITableViewCell *Cell_AddDevice;

-(void)toggleOnOff:(id)sender;

@end
