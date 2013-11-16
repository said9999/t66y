#import <Foundation/Foundation.h>
#import "BluetoothManager.h"

@interface PopUp_AddDevice : NSObject<UIAlertViewDelegate,DiscoveryObserver>{
    UIView *_PopUpView;
    UITextView *lbl_Top;
    UITextView *lbl_Btm;
    UIActivityIndicatorView *LoadingCircle;
    UIButton *btn_Button;
    int int_step;
    int int_DevicesFound;
    int int_DevicesFailed;
    bool bol_DimissingPopUp;
    NSTimer *timer;
}

+(id)sharedInstance;//Singleton
-(void)ShowPopUp;
-(void)DismissPopUp;
-(void)FinishDismissAnimation;
-(void)UpdateUI;
-(void)connectNextDiscoveredDevice;
-(void)showAlert;

@end
