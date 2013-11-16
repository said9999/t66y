#import "PopUp_Belonging.h"
#import "DeviceManager.h"
#import "AccountManager.h"

//Animation guide
//http://iphonedevelopment.blogspot.sg/2010/05/custom-alert-views.html
#define kAnimationDuration  0.2555

@implementation PopUp_Belonging

@synthesize text_NewName;
@synthesize btn_OK;
@synthesize btn_Cancel;
@synthesize btn_Icons;

//Singleton
+(id)sharedInstance{
    static PopUp_Belonging *_instance;
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
        if([[[UIDevice currentDevice]systemVersion]floatValue] >= 7.0)
            theView =  [[NSBundle mainBundle] loadNibNamed:@"PopUp_Belongingios7" owner:self options:nil];
        else
            theView =  [[NSBundle mainBundle] loadNibNamed:@"PopUp_Belonging" owner:self options:nil];
        _PopUpView = [theView objectAtIndex:0];

        btn_Icons = (UISegmentedControl *)[_PopUpView viewWithTag:5];
        text_NewName = (UITextField *)[_PopUpView viewWithTag:6];
        btn_OK = (UIButton *)[_PopUpView viewWithTag:7];
        btn_Cancel = (UIButton *)[_PopUpView viewWithTag:8];
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
        [center addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

        [btn_OK addTarget:self action:@selector(pressedOk) forControlEvents:UIControlEventTouchUpInside];
        [btn_Cancel addTarget:self action:@selector(DismissPopUp) forControlEvents:UIControlEventTouchUpInside];
        text_NewName.delegate = self;
    }
    return self;
}

-(void)ShowPopUp{
    
    id appDelegate = [[UIApplication sharedApplication] delegate];
    UIWindow *window = [appDelegate window];
    [window addSubview:_PopUpView];
    
    _device = [[DeviceManager sharedInstance]_DetailsDevice];
    text_NewName.text = _device.str_Name;
    [btn_Icons setSelectedSegmentIndex:[_device int_Icon]];

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
    {
        [_PopUpView removeFromSuperview];
        [text_NewName resignFirstResponder];
    }
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

-(void)pressedOk{
    
    if([text_NewName.text length] > 12){
        text_NewName.text = [text_NewName.text substringToIndex:12];
    }
    
    if([text_NewName.text length] == 0){
        [self ShowPopUp];
    }
    else if(_device != NULL){
        [_device setStr_Name:text_NewName.text];
        if([_device bol_Synced]){
            [[AccountManager sharedAccountManager]syncProtag:_device];
        }
    }
    
    //Update Icon
    if([_device int_Icon]<0 ||
       [_device int_Icon]>=[btn_Icons numberOfSegments])
    {
        NSLog(@"segment %i",btn_Icons.numberOfSegments);
        NSLog(@"Reset int_Icon");
        _device.int_Icon = 0;
    }
    
    if(_device!=NULL && btn_Icons!=NULL){
        [_device setInt_Icon:btn_Icons.selectedSegmentIndex];
    }
    
    
    [[DeviceManager sharedInstance]refreshAllDeviceViews];

       //[btn_Icons sendActionsForControlEvents:UIControlEventValueChanged];
    
  //  [btn_Icons addTarget:self action:@selector(UpdateIcon:) forControlEvents:UIControlEventValueChanged];
    
  //  [btn_Icons setSelectedSegmentIndex:btn_Icons.selectedSegmentIndex];
   // [btn_Icons sendActionsForControlEvents:UIControlEventValueChanged];

   // [text_NewName resignFirstResponder];
    [self DismissPopUp];
}

- (void)keyboardDidShow:(NSNotification *)notification {
    
    CGRect keyboardFrameW = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    CGRect keyboardFrame = [window convertRect:keyboardFrameW toView:_PopUpView];
	
    // put the bottom of the login button's frame just above the top of the keyboard
    CGFloat signinButtonBottom = CGRectGetMaxY(_PopUpView.frame);
    CGFloat targetBottom = keyboardFrame.origin.y + 193.0;
    offsetY = MAX(0.0, signinButtonBottom - targetBottom);
    
    [UIView animateWithDuration:0.3 animations:^{
        _PopUpView.frame = CGRectOffset(_PopUpView.frame, 0.0, -offsetY);
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    [UIView animateWithDuration:0.3 animations:^{
		
		[UIView animateWithDuration:0.3 animations:^{
			_PopUpView.frame = CGRectOffset(_PopUpView.frame, 0.0, offsetY);
		}];
    }];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(textField == text_NewName)
        [textField resignFirstResponder];
    return YES;
}
@end
