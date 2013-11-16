#import <UIKit/UIKit.h>
#import "IIViewDeckController.h"
#import "ViewController_PageScroll.h"
#import "ViewController_WarningMenu.h"
#import "WarningManager.h"
#import "ViewController_ProtagDetails.h"
#import "ViewController_SignUpAndSignIn.h"

@interface ViewController_DevicesWithSideMenu : IIViewDeckController<IIViewDeckControllerDelegate,WarningObserver>{
    ViewController_PageScroll *CenterController;
    ViewController_WarningMenu *WarningMenu;
    ViewController_ProtagDetails *ProtagDetailsController;
}

@property (nonatomic) UIBarButtonItem *btn_Warning;
-(void)ToggleSideMenu;
-(void)PushToDetails;
-(void)UpdateVisibilityOfWarningMenuBtn;
-(void)AlertEvent:(WarningEvents)event;

@end
