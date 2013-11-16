#import <UIKit/UIKit.h>
#import "Protag_Device.h"
#import "DeviceManager.h"
#import "ViewController_Map.h"
#import "btn_Detail_Icon.h"
#import "ViewController_Radar.h"
#import "ViewController_BaiduMap.h"

@interface ViewController_ProtagDetails : UIViewController<DeviceObserver,UIAlertViewDelegate>{
    UIScrollView *scrollView;
    Protag_Device *_device;
    ViewController_Map *MapController;
    ViewController_BaiduMap *BaiduMapController;
    ViewController_Radar *RadarController;
    double column_Left;
    double column_Right;
    double row_First;
    double row_Second;
    double row_Third;
    double row_Fourth;
    double cell_Height;
}

@property (nonatomic) btn_Detail_Icon *button_Belongings;
@property (nonatomic) btn_Detail_Icon *button_DeviceStatus;
@property (nonatomic) btn_Detail_Icon *button_Battery;
@property (nonatomic) btn_Detail_Icon *button_DistanceSettings;
@property (nonatomic) btn_Detail_Icon *button_RadarTracking;
@property (nonatomic) btn_Detail_Icon *button_LastKnownLocation;
@property (nonatomic) btn_Detail_Icon *button_Sync;
@property (nonatomic) btn_Detail_Icon *button_MAC;
@property (nonatomic) UIButton *button_DeleteDevice;

-(void)LoadButtonView;
-(void)BelongingPressed:(id)sender;
-(void)DeviceStatusPressed:(id)sender;
-(void)DistanceButtonPressed:(id)sender;
-(void)RadarTrackingPressed:(id)sender;
-(void)LastKnownLocationPressed:(id)sender;
-(void)DeleteDevicePressed:(id)sender;
-(void)BatteryPressed:(id)sender;

@end
