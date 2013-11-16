
#import <UIKit/UIKit.h>
#import "DeviceProximity.h"
#import "DeviceManager.h"
#import "Protag_Device.h"
#import "DeviceFinder.h"

@interface ViewController_Radar : UIViewController<ProximityObserver,FinderObserver>{
    DeviceProximity *_DeviceProximity;
    DeviceFinder *_DeviceFinder;
    UILabel *lbl_Distance;
    UIImageView *img_Dot;
    UIImageView *img_Radar;
    UIView *view_Loading;
    double double_accumulatedRSSI;
    Protag_Device *_device;
    int int_speedUpCount;
    UIImageView *img_Arrow;
    UILabel *lbl_DetectingDevice;
}

- (id)initWithDevice:(Protag_Device *)device;
-(void)setRadarDevice:(Protag_Device *)device;

@end
