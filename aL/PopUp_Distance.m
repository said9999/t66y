#import "PopUp_Distance.h"
#import "DeviceManager.h"

//Animation guide
//http://iphonedevelopment.blogspot.sg/2010/05/custom-alert-views.html
#define kAnimationDuration  0.2555

@implementation PopUp_Distance


@synthesize btn_Done;
@synthesize SegCtrl_Distance;


//Singleton
+(id)sharedInstance{
    static PopUp_Distance *_instance;
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
        NSArray *theView =  [[NSBundle mainBundle] loadNibNamed:@"PopUp_Distance" owner:self options:nil];
        _PopUpView = [theView objectAtIndex:0];
        SegCtrl_Distance = (UISegmentedControl *)[_PopUpView viewWithTag:13];
        btn_Done = (UIButton *)[_PopUpView viewWithTag:14];
        
        [btn_Done addTarget:self action:@selector(RefreshDistance) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

-(void)ShowPopUp{
    
    id appDelegate = [[UIApplication sharedApplication] delegate];
    UIWindow *window = [appDelegate window];
    [window addSubview:_PopUpView];
    
    _device = [[DeviceManager sharedInstance]_DetailsDevice];
    [SegCtrl_Distance setSelectedSegmentIndex:_device.index_Distance];
    
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

-(void)RefreshDistance
{
    if([_device index_Distance]<0 ||
       [_device index_Distance]>=[SegCtrl_Distance numberOfSegments])
    {
        NSLog(@"Reset index_Distance");
        _device.index_Distance = [SegCtrl_Distance numberOfSegments]-1;
    }
    
    if(_device!=NULL && SegCtrl_Distance!=NULL)
        _device.index_Distance = [SegCtrl_Distance selectedSegmentIndex];
    
    [_device check_NotifyCharacteristic];
    
    [[DeviceManager sharedInstance]refreshAllDeviceViews];

    [self DismissPopUp];
}

@end
