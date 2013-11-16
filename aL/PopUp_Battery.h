#import <Foundation/Foundation.h>
#import "Protag_Device.h"

@interface PopUp_Battery : NSObject{
    UIView *_PopUpView;
    bool bol_DimissingPopUp;
    Protag_Device *_device;
}

@property(nonatomic)UIImageView *img_Battery;
@property(nonatomic)UIButton *btn_Done;

+(id)sharedInstance;//Singleton
-(void)ShowPopUp;
-(void)DismissPopUp;
-(void)FinishDismissAnimation;
-(void)RefreshBattery;


@end
