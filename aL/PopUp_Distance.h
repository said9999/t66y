#import <Foundation/Foundation.h>
#import "Protag_Device.h"

@interface PopUp_Distance : NSObject{
    UIView *_PopUpView;
    bool bol_DimissingPopUp;
    Protag_Device *_device;
    
}
@property(nonatomic)UISegmentedControl *SegCtrl_Distance;
@property(nonatomic)UIButton *btn_Done;


+(id)sharedInstance;//Singleton
-(void)ShowPopUp;
-(void)DismissPopUp;
-(void)FinishDismissAnimation;
-(void)RefreshDistance;


@end
