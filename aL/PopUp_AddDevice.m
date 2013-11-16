#import "PopUp_AddDevice.h"
#import "BluetoothManager.h"
#import "DataManager.h"

//Animation guide
//http://iphonedevelopment.blogspot.sg/2010/05/custom-alert-views.html
#define kAnimationDuration  0.2555

@implementation PopUp_AddDevice

//Singleton
+(id)sharedInstance{
    static PopUp_AddDevice *_instance;
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
        NSArray *theView =  [[NSBundle mainBundle] loadNibNamed:@"PopUp_AddDevice" owner:self options:nil];
        _PopUpView = [theView objectAtIndex:0];
        lbl_Top = (UITextView*)[_PopUpView viewWithTag:1];
        LoadingCircle = (UIActivityIndicatorView*)[_PopUpView viewWithTag:2];
        lbl_Btm = (UITextView*)[_PopUpView viewWithTag:3];
        btn_Button = (UIButton*)[_PopUpView viewWithTag:4];
        
        [btn_Button addTarget:self action:@selector(DismissPopUp) forControlEvents:UIControlEventTouchUpInside];
        //Observe BluetoothManager
        [[BluetoothManager sharedInstance]set_discoveryObserver:self];
    
    }
    return self;
}

-(void)ShowPopUp{
    
    id appDelegate = [[UIApplication sharedApplication] delegate];
    UIWindow *window = [appDelegate window];
    [window addSubview:_PopUpView];
    
    _PopUpView.alpha = 1;
    _PopUpView.frame = window.frame;
    _PopUpView.center = window.center;
    bol_DimissingPopUp=false;
    
    int_step=1;
    
    [self UpdateUI];
    [self animateBackgroundFadeIn];
    [self animateBoxPopIn];
    //Start scanning
    [[BluetoothManager sharedInstance]startScanning];
    timer = [NSTimer scheduledTimerWithTimeInterval:50.0 target:self selector:@selector(showAlert) userInfo:nil repeats:false];
    
}

-(void)DismissPopUp{
    //Stop Scanning
    if([[BluetoothManager sharedInstance]is_Scanning] == true)
        [[BluetoothManager sharedInstance]stopScanning];
    [UIView beginAnimations:nil context:nil];
    _PopUpView.alpha = 0.0;
    [UIView commitAnimations];
    
    [self performSelector:@selector(FinishDismissAnimation) withObject:nil afterDelay:0.5];
    bol_DimissingPopUp=true;
    if(timer !=NULL)
    {
        [timer invalidate];
        timer = NULL;
    }
    
    //this code was used previously to move to another tab
    /*if(btn_Button.tag == 20)
    {
        UITabBarController *MyTabController = (UITabBarController *)((AppDelegate*) [[UIApplication sharedApplication] delegate]).window.rootViewController;
        
        [MyTabController setSelectedIndex:1];
    }*/
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

-(void)UpdateUI{
    switch(int_step)
    {
        case 1:
            [lbl_Top setText:@"Please turn on your PROTAG Elite(s) and Place it within 1m of your iPhone"];
            [LoadingCircle setHidden:false];
            [btn_Button setTitle:@"Cancel" forState:UIControlStateNormal];
            [btn_Button setTag:10];
            [lbl_Btm setText:@"Scanning for any PROTAG Elite(s) nearby..."];
            break;
        case 2:
            [lbl_Top setText:[NSString stringWithFormat:@"Discovered %d PROTAG Elite(s)",int_DevicesFound]];
            
            [lbl_Btm setText:@"Searching for other PROTAG Elite(s)"];
            if([[BluetoothManager sharedInstance]is_Scanning] == true)
                [[BluetoothManager sharedInstance]stopScanning];
            break;
        case 3:
            [lbl_Top setText:[NSString stringWithFormat:@"Connecting to %d PROTAG Elite(s)",int_DevicesFound]];
            
            int tempInt = int_DevicesFound-[[BluetoothManager sharedInstance]Discovered_Peripherals].count;
            if(tempInt == 0){
                [lbl_Btm setText:@""];
            }
            else
                [lbl_Btm setText:[NSString stringWithFormat:@"Connected to %d PROTAG Elite(s)",tempInt]];
            break;
        case 4:
            [btn_Button setTitle:@"Done" forState:UIControlStateNormal];
            [btn_Button setTag:20];
            [LoadingCircle setHidden:true];
            if(int_DevicesFound>int_DevicesFailed)
            {
                [lbl_Top setText:[NSString stringWithFormat:@"Successfully connected to %d PROTAG Elite(s)",int_DevicesFound-int_DevicesFailed]];
                if(int_DevicesFailed<=0)
                    [lbl_Btm setText:@"Please tap on the ORB to access more options"];
                else
                    [lbl_Btm setText:[NSString stringWithFormat:@"Failed to connect to %d PROTAG Elite(s)...",int_DevicesFailed]];
            }
            else
            {
                [lbl_Top setText:[NSString stringWithFormat:@"Failed to link %d PROTAG Elite(s)\nPlease try again : sorry for the inconvenience",int_DevicesFailed]];
                [lbl_Btm setText:@""];
            }
            if(timer !=NULL)
            {
                [timer invalidate];
                timer = NULL;
            }
            break;
        default:
            break;
    }
}

-(void)AlertEvent:(DiscoveryEvents)event{
    switch(event){
        case DISCOVERING_DEVICES:
            int_step=1;
            int_DevicesFailed=0;
            int_DevicesFound=0;
            break;
        case DISCOVERED_DEVICE:
            if(int_step<=2)
                int_DevicesFound++;
            if(int_step==1)
            {
                int_step=2;
                //A timer to wait for more devices to be discovered before attempting to connect to all of them
                [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(connectNextDiscoveredDevice) userInfo:nil repeats:false];
            }
            break;
        case CONNECTING_DEVICE:
            if(int_step==2)
            {
                //Stop Scanning
                if([[BluetoothManager sharedInstance]is_Scanning] == true)
                    [[BluetoothManager sharedInstance]stopScanning];
                int_step=3;
            }
            break;
        case CONNECTED_DEVICE:
            NSLog(@"Connected_Device");
            if(int_step==3)
            {
                if([[DataManager sharedInstance]Hints_Step]==1){
                    [[DataManager sharedInstance]setHints_Step:2];
                    [[DataManager sharedInstance]save_Settings];
                }
                if([[BluetoothManager sharedInstance]Discovered_Peripherals].count<=0)
                    int_step=4;
                else if([[BluetoothManager sharedInstance]Discovered_Peripherals].count>0)
                    [self connectNextDiscoveredDevice];
            }
            break;
        case FAIL_CONNECT_DEVICE:
            int_DevicesFailed++;
            [self connectNextDiscoveredDevice];
            break;
        default:
            break;
    }
    
    [self UpdateUI];
}

-(void)connectNextDiscoveredDevice{
    if([[BluetoothManager sharedInstance]Discovered_Peripherals].count>0)
    {
        //Stop Scanning
        if([[BluetoothManager sharedInstance]is_Scanning] == true)
            [[BluetoothManager sharedInstance]stopScanning];
        NSLog(@"connectNextDiscoveredDevice");
        CBPeripheral *tempPeripheral = (CBPeripheral*)[[[BluetoothManager sharedInstance]Discovered_Peripherals]objectAtIndex:0];
        
        if(![tempPeripheral isConnected]){
            [[[BluetoothManager sharedInstance]CentralManager] connectPeripheral:tempPeripheral options:nil];
            
            [self AlertEvent:CONNECTING_DEVICE];
        }
        else
        {
            //If Device already connected
            [[[BluetoothManager sharedInstance]Discovered_Peripherals]removeObjectAtIndex:0];
            [self AlertEvent:CONNECTED_DEVICE];
        }
    }
}

-(void)showAlert{
    UIAlertView *message = [[UIAlertView alloc]initWithTitle:@"Information" message:@"No PROTAG Elite(s) Found, Please, ensure PROTAG Elite is turned on and within 1m of iphone and try again" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [message setAlertViewStyle:UIAlertViewStyleDefault];
    [self DismissPopUp];
    [message show];
    
}

@end
