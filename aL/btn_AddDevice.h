#import <UIKit/UIKit.h>
#import "DeviceManager.h"


//Used in ViewController_PageScroll to add devices

@interface btn_AddDevice : UIButton<DeviceObserver>{
    UIImageView *img_Hint;
    BOOL bol_Glow_Shrink;
    NSTimer *timer_Glow;
    int glowCounter;
}

@end
