#import "ViewController_LargeOrb.h"
#import "DeviceManager.h"
#define kAnimationDuration  0.2555

@implementation ViewController_LargeOrb


-(id)init{
    self = [super init];
    if(self)
    {
        NSArray *theView =  [[NSBundle mainBundle] loadNibNamed:@"View_LargeOrb" owner:self options:nil];
        _PopupView = [theView objectAtIndex:0];
        View_Connect = [_PopupView viewWithTag:1];
        View_Disconnect =[_PopupView viewWithTag:2];
        
        double_Fade=0.5;
        double_Hightlight=0.8;
    }
    return self;
}

-(void)ShowOverlay{
    NSLog(@"Show Overlay");
    id appDelegate = [[UIApplication sharedApplication] delegate];
    UIWindow *window = [appDelegate window];
    
    [window addSubview:_PopupView];
    
    _PopupView.alpha = 1;
    _PopupView.frame = window.frame;
    _PopupView.center = window.center;
    bol_Dismissing=false;
    
    [self animateBackgroundFadeIn];
}
    
-(void)DismissOverlay{
    NSLog(@"Dismiss Overlay");
    [UIView beginAnimations:nil context:nil];
    _PopupView.alpha = 0.0;
    [UIView commitAnimations];
    
    [self performSelector:@selector(FinishDismissAnimation) withObject:nil afterDelay:0.5];
    bol_Dismissing=true;
}

-(void)FinishDismissAnimation{
    if(bol_Dismissing==true)
        [_PopupView removeFromSuperview];
}

-(void)animateBackgroundFadeIn{
    CALayer *viewLayer = _PopupView.layer;
    CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeInAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    fadeInAnimation.toValue = [NSNumber numberWithFloat:1.0];
    fadeInAnimation.duration = kAnimationDuration;
    fadeInAnimation.delegate = nil;
    [viewLayer addAnimation:fadeInAnimation forKey:@"opacity"];
}

-(void)FadeBoth{
    [View_Connect setAlpha:double_Fade];
    [View_Disconnect setAlpha:double_Fade];
}
-(void)HighlightConnect{
    [View_Connect setAlpha:double_Hightlight];
    [View_Disconnect setAlpha:double_Fade];
}
-(void)HighlightDisconnect{
    [View_Connect setAlpha:double_Fade];
    [View_Disconnect setAlpha:double_Hightlight];
}

@end
