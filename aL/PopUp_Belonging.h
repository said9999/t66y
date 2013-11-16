#import <Foundation/Foundation.h>
#import "Protag_Device.h"

@interface PopUp_Belonging : NSObject<UITextFieldDelegate>{
    UIView *_PopUpView;
    bool bol_DimissingPopUp;
    Protag_Device *_device;
    CGFloat offsetY;
    NSArray *theView;
}
@property(nonatomic)UISegmentedControl *btn_Icons;
@property(nonatomic)UITextField *text_NewName;
@property(nonatomic)UIButton *btn_OK;
@property(nonatomic)UIButton *btn_Cancel;

+(id)sharedInstance;//Singleton
-(void)ShowPopUp;
-(void)DismissPopUp;

@end
