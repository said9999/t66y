#define kAnimationDuration  0.2555

#import "PopUp_Processing.h"
#import <QuartzCore/QuartzCore.h>

@implementation PopUp_Processing

+(id)sharedInstance
{
    static PopUp_Processing *instance;
    static dispatch_once_t once;
    dispatch_once(&once,^{
        instance = [[self alloc]init];
    });
    return instance;
}

-(id)init
{
    self = [super init];
    if(self)
    {
        NSArray *theView = [[NSBundle mainBundle]loadNibNamed:@"PopUp_Processing" owner:self options:nil];
        _popUpView = [theView objectAtIndex:0];
    }
    return self;
}

-(void)showView
{
    id appDelegate = [[UIApplication sharedApplication]delegate];
    UIWindow *window = [appDelegate window];
    [window addSubview:_popUpView];
    
    _popUpView.alpha = 1.0;
    _popUpView.frame = window.frame;
    _popUpView.center = window.center;
    bol_DismissingView = false;
    
    [self animateBackgroundFadeIn];
    [self animateBoxPopIn];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(dismissView) userInfo:nil repeats:false];

}

-(void)dismissView
{
    NSLog(@"Inside Dismiss View");
    [UIView beginAnimations:nil context:nil];
    _popUpView.alpha = 0.0;
    [UIView commitAnimations];
    
    [self performSelector:@selector(FinishDismissAnimation) withObject:nil afterDelay:0.5];
    bol_DismissingView =true;
    if(timer !=NULL)
    {
        [timer invalidate];
        timer = NULL;
    }
}

-(void)FinishDismissAnimation{
    NSLog(@"Finish Dismiss Animation");
    if(bol_DismissingView ==true)
        [_popUpView removeFromSuperview];
}

-(void)animateBoxPopIn{
    //pop in animation
    CALayer *viewLayer = [_popUpView viewWithTag:10].layer;
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
    CALayer *viewLayer = [_popUpView viewWithTag:11].layer;
    CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeInAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    fadeInAnimation.toValue = [NSNumber numberWithFloat:0.4];
    fadeInAnimation.duration = kAnimationDuration;
    fadeInAnimation.delegate = nil;
    [viewLayer addAnimation:fadeInAnimation forKey:@"opacity"];
}



@end
