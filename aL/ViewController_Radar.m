
#import "ViewController_Radar.h"
#import "CrowdTrackManager.h"
#import "AccountManager.h"

@interface ViewController_Radar ()

@end

int prev_Distance;
NSString *prev_str_Status;
int prev_int_Status;

@implementation ViewController_Radar

-(id)init{
    if(self=[super init]){
        _DeviceProximity = [[DeviceProximity alloc]init];
        _DeviceFinder = [[DeviceFinder alloc]init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIView *mainView = [[[NSBundle mainBundle] loadNibNamed:@"View_Radar" owner:self options:nil]objectAtIndex:0];
    view_Loading = [[[NSBundle mainBundle] loadNibNamed:@"View_Radar" owner:self options:nil]objectAtIndex:1];
    [self setView: mainView];
    
    [self.view setAutoresizesSubviews:true];
    
    self.title = @"Radar";
    
    self.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    [self.view setAutoresizesSubviews:true];
    
    //This is the fix the 20px bug created by UINavigationController
    [self.view setFrame:CGRectOffset(self.view.frame, 0, -20)];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
        self.navigationController.navigationBar.translucent = NO;
        self.navigationController.navigationBar.barTintColor = [UIColor darkGrayColor];
        self.navigationController.navigationBar.titleTextAttributes = @{UITextAttributeTextColor : [UIColor whiteColor]};
    }
    
    img_Dot  = (UIImageView*)[mainView viewWithTag:1];
    lbl_Distance = (UILabel*)[mainView viewWithTag:2];
    img_Radar = (UIImageView*)[mainView viewWithTag:3];
    img_Arrow = (UIImageView*)[mainView viewWithTag:4];
    lbl_DetectingDevice = (UILabel *)[view_Loading viewWithTag:5];
    
#warning hide the arrow here
    //Used to display direction indicator but it is not working well which is why we are hiding it for the moment
    [img_Arrow setAlpha:0];
    
    double_accumulatedRSSI=0;
    //_device = NULL;
    int_speedUpCount=0;
 }

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setRadarDevice:[[DeviceManager sharedInstance]_DetailsDevice]];

   // [[AccountManager sharedAccountManager] setIsUserRadarOn:YES];
   // [self.tabBarController.tabBar setHidden:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
  //  [[AccountManager sharedAccountManager] setIsUserRadarOn:NO];
    //[self.tabBarController.tabBar setHidden:NO];

    [super viewWillDisappear:animated];
    [_DeviceProximity stopScanning];
    [_DeviceProximity deregisterObserver:self];
    [self hideLoading];
    NSLog(@"Device status : %@,%d",prev_str_Status,prev_int_Status);
    if(_device!=NULL){
        _device.index_Distance = prev_Distance;
        _device.str_Status = prev_str_Status;
        _device.int_Status = prev_int_Status;
        if(prev_int_Status == STATUS_SECURE_ZONE || prev_int_Status == STATUS_CONNECTING){
            [_device Disconnect];
            [_device Connect];
        }
        else if(prev_int_Status == STATUS_DISCONNECTING)
            [_device Disconnect];
    }
    [_device check_NotifyCharacteristic];
}

-(void)showLoading{
    if(view_Loading.superview != self.view){
        [view_Loading setFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)];
        if(_device!=NULL)
            lbl_DetectingDevice.text = [NSString stringWithFormat:@"Detecting %@",_device.str_Name];
        else
            NSLog(@"_device was NULL");
        [self.view addSubview:view_Loading];
        int_speedUpCount=0;
        [_DeviceFinder StopSearching];
    }
}

-(void)hideLoading{
    if(view_Loading.superview!=NULL && view_Loading.superview==self.view){
        [view_Loading removeFromSuperview];
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        [_DeviceFinder StartSearching];
        [_DeviceFinder set_Observer:self];
        [self rotateImage:img_Arrow duration:0.1 curve:UIViewAnimationCurveEaseIn degrees:0];
        if(_device!=NULL){
            [_device set_Status:STATUS_RADAR];
            //Set notify of 2A19 to true
            if([_device _2A19Characteristic]!=NULL){
                [[_device _peripheral]setNotifyValue:true forCharacteristic:[_device _2A19Characteristic]];
            }else{
                NSLog(@"Proxmity unable to register _2A19");
            }
        }else
            NSLog(@"_device was NULL");
        
    }
}



-(void)setRadarDevice:(Protag_Device*)device{
    _device = device;
    
    prev_Distance = _device.index_Distance;
    _device.index_Distance = 1; //previously was 2
    prev_str_Status = _device.str_Status;
    prev_int_Status = _device.int_Status;
    
    [_DeviceProximity registerObserver:self];
    [_DeviceProximity startScanning:_device];
    double_accumulatedRSSI=0;
    [self showLoading];
    [_device set_Status:STATUS_RADAR];
}

-(void)UpdateStatus:(ProximityStatus)status{
    switch(status){
        case PROXIMITY_IN_RANGE:
            [self hideLoading];
            break;
        case PROXIMITY_NOT_IN_RANGE:
        case PROXIMITY_LONG_RANGE:
        default:
                [self showLoading];
            break;
    }
}

- (void) UpdateRSSI:(int)RSSI{
    if(int_speedUpCount<=0){
        [_device toggleSpeedUp];
        int_speedUpCount=6;
    }
    else
        int_speedUpCount--;
   
    //range is 0 to -90, max as 8 meters
    //int int_Estimate = RSSI;//8*(0-RSSI);
    //[lbl_Distance setText:[NSString stringWithFormat:@"Approximate Distance: %d",int_Estimate]];
   
    if(RSSI <0 && RSSI>-50)
        [lbl_Distance setText:[NSString stringWithFormat:@"Approximate Distance: 1 to 5 meters"]];
    else if(RSSI <-51 && RSSI>-80)
        [lbl_Distance setText:[NSString stringWithFormat:@"Approximate Distance: 6 to 10 meters"]];
    else
        [lbl_Distance setText:[NSString stringWithFormat:@"Approximate Distance: Above 10 meters"]];
    
    double dbl_NewY = 5 * RSSI + 450;
    
    if(dbl_NewY>300)
        dbl_NewY = 300;
    else
        if(dbl_NewY<0)
            dbl_NewY = 0;
    
    //update the dot here
    [UIView animateWithDuration:1.8
                          delay:0.0
                        options: UIViewAnimationCurveLinear
                     animations:^{
                         [img_Dot setFrame:CGRectMake(img_Dot.frame.origin.x, dbl_NewY, img_Dot.frame.size.width, img_Dot.frame.size.height)];
                     }
                     completion:nil];
}


//FinderObserver implementation
- (void) newDirection:(double)degree{
    [self rotateImage:img_Arrow duration:0.5 curve:UIViewAnimationCurveEaseIn degrees:degree];
}


//http://mobiledevelopertips.com/user-interface/rotate-an-image-with-animation.html
- (void)rotateImage:(UIImageView *)image duration:(NSTimeInterval)duration
              curve:(int)curve degrees:(CGFloat)degrees
{
    // Setup the animation
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:curve];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    // The transform matrix
    CGAffineTransform transform =
    CGAffineTransformMakeRotation([self Convert_DegreeToRadian:degrees]);
    image.transform = transform;
    
    // Commit the changes
    [UIView commitAnimations];
}

-(double)Convert_DegreeToRadian:(double) angle{
    return angle / 180.0 * M_PI;
}

@end
