#import "PopUp_Battery.h"
#import "DeviceManager.h"

//Animation guide
//http://iphonedevelopment.blogspot.sg/2010/05/custom-alert-views.html
#define kAnimationDuration  0.2555

@implementation PopUp_Battery

@synthesize img_Battery;
@synthesize btn_Done;


//Singleton
+(id)sharedInstance{
    static PopUp_Battery *_instance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

-(id)init{
    self = [super init];
    if(self)
    {
        NSArray *theView =  [[NSBundle mainBundle] loadNibNamed:@"PopUp_Battery" owner:self options:nil];
        _PopUpView = [theView objectAtIndex:0];
       
        img_Battery = (UIImageView *)[_PopUpView viewWithTag:15];
      //  [img_Battery setFrame:CGRectMake(40, 15, 100, 100)];
        btn_Done = (UIButton *)[_PopUpView viewWithTag:16];
        
        [btn_Done addTarget:self action:@selector(DismissPopUp) forControlEvents:UIControlEventTouchUpInside];
        
    //    [btn_Done addTarget:self action:@selector(RefreshBattery) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

-(void)ShowPopUp{
    
    id appDelegate = [[UIApplication sharedApplication] delegate];
    UIWindow *window = [appDelegate window];
    [window addSubview:_PopUpView];
   
    _device = [[DeviceManager sharedInstance]_DetailsDevice];
   
    int prev_Distance = _device.index_Distance;
    
    _device.index_Distance = 0;
    
    [_device check_NotifyCharacteristic];
    
    if(_device.int_Battery>0 && _device.int_Battery<=30)
        [img_Battery setImage:[UIImage imageNamed:@"battery_one_144.png"]];
    else if (_device.int_Battery>30 && _device.int_Battery<=65)
        [img_Battery setImage:[UIImage imageNamed:@"battery_two_144.png"]];
    else
        [img_Battery setImage:[UIImage imageNamed:@"battery_three_114.png"]];

    _device.index_Distance = prev_Distance;
    
    [[DeviceManager sharedInstance]refreshAllDeviceViews];

    _PopUpView.alpha = 1;

    bol_DimissingPopUp=false;
    
    [self animateBackgroundFadeIn];
    [self animateBoxPopIn];
}

-(void)DismissPopUp{
    [UIView beginAnimations:nil context:nil];
    _PopUpView.alpha = 0.0;
    [UIView commitAnimations];
    
    [self performSelector:@selector(FinishDismissAnimation) withObject:nil afterDelay:0.5];
    bol_DimissingPopUp = TRUE;
}

-(void)FinishDismissAnimation{
    if(bol_DimissingPopUp==true)
        [_PopUpView removeFromSuperview];
}

-(void)animateBoxPopIn{
    //pop in animation
    CALayer *viewLayer = [_PopUpView viewWithTag:10].layer;
    CAKeyframeAnimation* popInAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    
    popInAnimation.duration = kAnimationDuration;
    popInAnimation.values = [NSArray arrayWithObjects:
                             [NSNumber numberWithFloat:0.6],
                             [NSNumber numberWithFloat:1.1],
                             [NSNumber numberWithFloat:.9],
                             [NSNumber numberWithFloat:1],
                             nil];
    popInAnimation.keyTimes = [NSArray arrayWithObjects:
                               [NSNumber numberWithFloat:0.0],
                               [NSNumber numberWithFloat:0.6],
                               [NSNumber numberWithFloat:0.8],
                               [NSNumber numberWithFloat:1.0],
                               nil];
    popInAnimation.delegate = nil;
    
    [viewLayer addAnimation:popInAnimation forKey:@"transform.scale"];
}

-(void)animateBackgroundFadeIn{
    CALayer *viewLayer = [_PopUpView viewWithTag:11].layer;
    CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeInAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    fadeInAnimation.toValue = [NSNumber numberWithFloat:0.4];
    fadeInAnimation.duration = kAnimationDuration;
    fadeInAnimation.delegate = nil;
    [viewLayer addAnimation:fadeInAnimation forKey:@"opacity"];
}

-(void)RefreshBattery
{
    
    [self DismissPopUp];
    
}

@end
