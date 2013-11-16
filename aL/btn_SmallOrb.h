#import <UIKit/UIKit.h>
#import "Protag_Device.h"

//btn_SmallOrb only used to display and store the device, does not manupilate anything

@interface btn_SmallOrb : UIButton{
    BOOL bol_Glow_Shrink;
    NSTimer *timer_Glow;
    int glowCounter;
}

-(id)initWithDevice:(Protag_Device*)device;
@property (nonatomic) UIImageView *img_Icon;
@property (nonatomic) UIImageView *img_Background;
@property (nonatomic) Protag_Device *_device;
-(void)updateImages;
@end
