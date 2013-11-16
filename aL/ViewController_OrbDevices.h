#import <UIKit/UIKit.h>
#import "ViewController_LargeOrb.h"

@interface ViewController_OrbDevices : UIViewController{
    NSMutableArray *_OrbDevices;
    UIButton *btn_BigButton;
    ViewController_LargeOrb *_OrbOverlay;
    int int_LargeOrbDetectionWidth;
    bool bol_iphone5;
}

-(void)PressedLargeOrb:(id)sender;
-(void)PressedSmallOrb:(id)sender;
-(void)RefreshSmallOrbs;
-(void)LetGoLargeOrb:(id)sender WithEvent:(UIEvent*)event;

@end


