#import <Foundation/Foundation.h>

@interface ViewController_LargeOrb : UIViewController{
    UIView *_PopupView;
    BOOL bol_Dismissing;
    double double_Fade;
    double double_Hightlight;
    UIView *View_Connect;
    UIView *View_Disconnect;
}

-(void)ShowOverlay;
-(void)DismissOverlay;
-(void)FadeBoth;
-(void)HighlightConnect;
-(void)HighlightDisconnect;


@end
