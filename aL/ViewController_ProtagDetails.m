#import "ViewController_ProtagDetails.h"
#import "BluetoothManager.h"
#import "WifiDetector.h"
#import "DataManager.h"
#import "PopUp_Belonging.h"
#import "PopUp_Distance.h"
#import "PopUp_Hint_Details.h"
#import "PopUp_Battery.h"
#import "AccountManager.h"

@interface ViewController_ProtagDetails ()

@end

@implementation ViewController_ProtagDetails

@synthesize button_Belongings;
@synthesize button_DeviceStatus;
@synthesize button_Battery;
@synthesize button_DistanceSettings;
@synthesize button_RadarTracking;
@synthesize button_LastKnownLocation;
@synthesize button_DeleteDevice;
@synthesize button_Sync;
@synthesize button_MAC;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [[DeviceManager sharedInstance]registerObserver:self];
    
    MapController = [[ViewController_Map alloc]init];
    BaiduMapController = [[ViewController_BaiduMap alloc]init];
    RadarController = [[ViewController_Radar alloc]init];
    
    UIImageView *BackGroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"background.png"]];
    [BackGroundView setFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)];
    self.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    [self.view setAutoresizesSubviews:true];
    
    self.title = @"PROTAG Details";
    
    scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)];
    
    //Used to indicate where the buttons should be
    column_Left=0;
    column_Right=140;
    row_First=0;
    row_Second=110;
    row_Third=220;
    row_Fourth=330;
    cell_Height=70.0;
    
    [scrollView addSubview:BackGroundView];
   
    [self LoadButtonView];

    //Change this contentSize if it is not scrolling
   // scrollView.contentSize = CGSizeMake(0,row_Fourth+cell_Height+button_Sync.frame.size.height+62);
    //scrollView.contentSize = CGSizeMake(0,row_Third+cell_Height+button_RadarTracking.frame.size.height*2);
    
    scrollView.bounces = NO;
    scrollView.delaysContentTouches = YES;
    
    [self.view addSubview:scrollView];
    
    //This is the fix the 20px bug created by UINavigationController
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
        self.navigationController.navigationBar.translucent = NO;
        self.navigationController.navigationBar.barTintColor = [UIColor darkGrayColor];
        self.navigationController.navigationBar.titleTextAttributes = @{UITextAttributeTextColor : [UIColor whiteColor]};
        //Change this contentSize if it is not scrolling
        scrollView.contentSize = CGSizeMake(0,row_Fourth+cell_Height+button_Sync.frame.size.height+85);
        //scrollView.contentSize = CGSizeMake(0,row_Third+cell_Height+button_RadarTracking.frame.size.height*2);
        
    }
    else
    {
        [self.view setFrame:CGRectOffset(self.view.frame, 0,-20)];
        //Change this contentSize if it is not scrolling
        scrollView.contentSize = CGSizeMake(0,row_Fourth+cell_Height+button_Sync.frame.size.height+62);
        //scrollView.contentSize = CGSizeMake(0,row_Third+cell_Height+button_RadarTracking.frame.size.height*2);
    }
    
    [BackGroundView setFrame:self.view.frame];
    [scrollView setFrame:self.view.frame];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[DeviceManager sharedInstance]registerObserver:self];
    [self refreshDeviceView];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //Show Hint/Wizard
    if([[DataManager sharedInstance]Hints_Step]==2){
        [[PopUp_Hint_Details sharedInstance]showView];
        [[DataManager sharedInstance]setHints_Step:3];
        [[DataManager sharedInstance]save_Settings];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated{
   [[DeviceManager sharedInstance]deregisterObserver:self];
}

//just button is loaded in the view
-(void)LoadButtonView
{
    //Belongings
    button_Belongings = [[btn_Detail_Icon alloc]init];
    [button_Belongings addTarget:self action:@selector(BelongingPressed:) forControlEvents:UIControlEventTouchUpInside];
    [button_Belongings setX:column_Left andY: row_First];
    [scrollView addSubview:button_Belongings];
    
    //Device status
    button_DeviceStatus = [[btn_Detail_Icon alloc]init];
    [button_DeviceStatus addTarget:self action:@selector(DeviceStatusPressed:) forControlEvents:UIControlEventTouchUpInside];
    [button_DeviceStatus setX:column_Right andY:row_First];
    [scrollView addSubview:button_DeviceStatus];
    
    //MAC
    button_Battery = [[btn_Detail_Icon alloc]init];
    [button_Battery refresh:[UIImage imageNamed:@"three_bar_144.png"] andName:@"BATTERY" andStatus:@"Current Battery Level"];
    [button_Battery setX:column_Left andY:row_Second];
    [scrollView addSubview:button_Battery];
    
    [button_Battery addTarget:self action:@selector(BatteryPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    //Distance
    button_DistanceSettings = [[btn_Detail_Icon alloc]init];
    [button_DistanceSettings addTarget:self action:@selector(DistanceButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [button_DistanceSettings refresh:[UIImage imageNamed:@"distance.png"] andName:@"DISTANCE SETTING" andStatus: @"-"];
    [button_DistanceSettings setX:column_Right andY:row_Second];
    [scrollView addSubview:button_DistanceSettings];
    
    //Radar
    button_RadarTracking = [[btn_Detail_Icon alloc]init];
    [button_RadarTracking addTarget:self action:@selector(RadarTrackingPressed:) forControlEvents:UIControlEventTouchUpInside];
    [button_RadarTracking refresh:[UIImage imageNamed:@"radar tracking.png"] andName:@"RADAR TRACKING" andStatus:@"Track Now"];
    [button_RadarTracking setX:column_Left andY:row_Third];
    [scrollView addSubview:button_RadarTracking];
    
    //Last known location
    button_LastKnownLocation = [[btn_Detail_Icon alloc]init];
    [button_LastKnownLocation addTarget:self action:@selector(LastKnownLocationPressed:) forControlEvents:UIControlEventTouchUpInside];
    [button_LastKnownLocation refresh:[UIImage imageNamed:@"lost location.png"] andName:@"LOST LOCATION" andStatus:@"-"];
    [button_LastKnownLocation setX:column_Right andY:row_Third];
    [scrollView addSubview:button_LastKnownLocation];
    
    //Sync
    button_Sync = [[btn_Detail_Icon alloc]init];
    [button_Sync addTarget:self action:@selector(SyncPressed) forControlEvents:UIControlEventTouchUpInside];
    [button_Sync refresh:[UIImage imageNamed:@"sync.png"] andName:@"CLOUD SYNC" andStatus:@"-"];
    [button_Sync setX:column_Left andY:row_Fourth];
    [scrollView addSubview:button_Sync];

    //MAC
    button_MAC = [[btn_Detail_Icon alloc]init];
    [button_MAC refresh:[UIImage imageNamed:@"MAC address.png"] andName:@"MAC ADDRESS" andStatus:@"-"];
    [button_MAC setX:column_Right andY:row_Fourth];
    [scrollView addSubview:button_MAC];
    
    [button_MAC addTarget:self action:@selector(MACPressed:) forControlEvents:UIControlEventTouchDown];
    
    
    [self LoadOtherButton]; 
}

-(void)LoadOtherButton{
    
    button_DeleteDevice = [UIButton buttonWithType:UIButtonTypeCustom];
    button_DeleteDevice.frame = CGRectMake(0.0,row_Fourth+button_Sync.frame.size.height+5,320.0,35);
    
    [button_DeleteDevice setTitle:@"Delete Device" forState:UIControlStateNormal];
    button_DeleteDevice.titleLabel.font = [UIFont systemFontOfSize:18.0];
    [button_DeleteDevice setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button_DeleteDevice.backgroundColor = [UIColor grayColor];
    button_DeleteDevice.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [button_DeleteDevice addTarget:self action:@selector(DeleteDevicePressed:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:button_DeleteDevice];
    
}
-(void)refreshDeviceView{
    NSLog(@"ProtagDetails refreshDeviceView");
    _device = [[DeviceManager sharedInstance]_DetailsDevice];
    
    UIImage* img_Belonging;
    switch(_device.int_Icon)
    {
        case 6:
            img_Belonging = [UIImage imageNamed:@"luggage1.png"];
            break;
        case 5:
            img_Belonging = [UIImage imageNamed:@"purse1.png"];
            break;
        case 4:
            img_Belonging = [UIImage imageNamed:@"briefcase1.png"];
            break;
        case 3:
            img_Belonging = [UIImage imageNamed:@"laptop1.png"];
            break;
        case 2:
            img_Belonging = [UIImage imageNamed:@"camera1.png"];
            break;
        case 1:
            img_Belonging = [UIImage imageNamed:@"wallet1.png"];
            break;
        case 0:
        default:
            img_Belonging = [UIImage imageNamed:@"empty ring.png"];
            break;
    }
    [button_Belongings refresh:img_Belonging andName:@"BELONGINGS" andStatus:_device.str_Name];

    //Status
        
    UIImage *img_Status;
    if([_device get_StatusCode]==STATUS_CONNECTED || [_device get_StatusCode]==STATUS_SECURE_ZONE){
        img_Status = [UIImage imageNamed:@"secured.png"];
    }
    else{
        img_Status = [UIImage imageNamed:@"unsecured.png"];
    }

    //Battery Level set to negative at first until an update of battery level comes
    if([_device get_StatusCode] == STATUS_DISCONNECTED)
        [button_DeviceStatus refresh:img_Status andName:@"MANUALLY" andStatus:@"DISCONNECTED"];
    else
        [button_DeviceStatus refresh:img_Status andName: _device.str_Status.uppercaseString andStatus:[NSString stringWithFormat:@"Battery : %d%%",_device.int_Battery]];
    
    //Distance
    switch(_device.index_Distance)
    {
        case 0:
            [button_DistanceSettings refresh:@"Minimum"];
            break;
        case 1:
        default:
            [button_DistanceSettings refresh:@"Maximum"];
            break;
    }
 
    //MAC
    if([_device is_iPad])
        [button_MAC refresh:@"UNIQUE ADDRESS" andStatus:[_device str_UUID]];
    else
        [button_MAC refresh:_device.str_MAC.uppercaseString];
    
    //lost location
    [button_LastKnownLocation refresh:_device.str_DateLost];
    
    //Cloud Sync
    if([[AccountManager sharedAccountManager]hasInternetConnection]){
        if([_device bol_Synced])
            [button_Sync refresh:@"Sync is on"];
        else
            [button_Sync refresh:@"Sync is off"];
    }else{
        [button_Sync refresh:@"No Connection"];
    }
    
  /*  UIImage *img_Battery;
    
    img_Battery = [UIImage imageNamed:@"three_bar_144.png"];
    
    [button_Battery refresh:img_Battery andName:@"BATTERY" andStatus:@"Current Battery Level"];
   */
}

-(void)BelongingPressed:(id)sender{
    NSLog(@"Pressed Belonging Icon");
    [[PopUp_Belonging sharedInstance]ShowPopUp];
}

-(void)DeviceStatusPressed:(id)sender
{
    NSLog(@"Pressed Device Status Icon");
    if ([[BluetoothManager sharedInstance]is_BluetoothOn]) {
        if([_device isConnected])
            [_device Disconnect];
        else if ([_device get_StatusCode] == STATUS_SECURE_ZONE)
            [_device set_Status: STATUS_DISCONNECTED];
        else
            [_device Connect];
    }
    else
    {
        if([[[UIDevice currentDevice]systemVersion]floatValue] >= 7.0){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Information" message:@"Bluetooth is currently OFF, please turn ON Bluetooth in iPhone Settings" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"\n\n\n\n\n" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            
            UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(90, 10, 130, 40)];
            [title setTextColor:[UIColor whiteColor]];
            [title setFont:[UIFont boldSystemFontOfSize:20]];
            [title setText:@"Information"];
            [title setBackgroundColor:[UIColor clearColor]];
            [alertView addSubview:title];
            
            UITextView *contentTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, 45, 260, 100)];
            [contentTextView setEditable:FALSE];
            [contentTextView setTextColor:[UIColor blackColor]];
            [contentTextView setFont:[UIFont systemFontOfSize:18]];
            contentTextView.contentMode = UIViewAutoresizingFlexibleWidth;
            [contentTextView setBackgroundColor:[UIColor clearColor]];
            [contentTextView setClipsToBounds:TRUE];
            [contentTextView setTextAlignment:NSTextAlignmentCenter];
            [contentTextView setText:@"Bluetooth is currently OFF, please turn ON Bluetooth in iPhone Settings"];
            [alertView addSubview:contentTextView];
            
            [alertView show];
        }
    }
}

-(void)DistanceButtonPressed:(id)sender{
    NSLog(@"Pressed Distance Icon");
    [[PopUp_Distance sharedInstance]ShowPopUp];
}

-(void)LastKnownLocationPressed:(id)sender{
    NSLog(@"Pressed Last Known Location Icon");
   // _device._latitude = 39.54;
   // _device._longitude = 116.23;
    //_device._latitude = 34.54;
    //_device._longitude = 116.23;
    
    if((_device._latitude>18.1500 && _device._latitude<53.300) && (_device._longitude> 74.0000 && _device._longitude<134.3000)){
        [self.navigationController pushViewController:BaiduMapController animated:true];
        NSLog(@"Protag Details of coordinates %f,%f  ",_device._latitude,_device._longitude);
    } else
        [self.navigationController pushViewController:MapController animated:true];
}

-(void)RadarTrackingPressed:(id)sender{
    NSLog(@"Pressed Radar Tracking Icon");
   // [RadarController setRadarDevice:[[DeviceManager sharedInstance]_DetailsDevice]];
    [self.navigationController pushViewController:RadarController animated:true];
}

-(void)DeleteDevicePressed:(id)sender{
        UIAlertView *message = [[UIAlertView alloc]initWithTitle:@"Delete Device" message:[NSString stringWithFormat:@"Are you sure you want to delete the %@?",_device.str_Name] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
        [message setAlertViewStyle:UIAlertViewStyleDefault];
        [message setTag:1];
        [message show];
}

-(void)MACPressed:(id)sender{
    [_device toggleSpeedUp];
}

-(void)SyncPressed{
    NSLog(@"Pressed Sync button");
    if(![[AccountManager sharedAccountManager]hasInternetConnection]){
        UIAlertView *tempAlert = [[UIAlertView alloc]initWithTitle:@"Information" message:@"Please turn on 3G or WIFI" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [tempAlert setAlertViewStyle:UIAlertViewStyleDefault];
        [tempAlert show];
        [self refreshDeviceView];
    }
    
    [_device toggleSync];
}

-(void)BatteryPressed:(id)sender{
    NSLog(@"Pressed Battery Button");
    [[PopUp_Battery sharedInstance]ShowPopUp];

}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag == 1)
    {
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        if([title isEqualToString:@"Delete"])
        {
            NSLog(@"Button Delete was Pressed");
            [[DeviceManager sharedInstance]remove_Device:_device];
            [[self navigationController]popViewControllerAnimated:true];//simulate the back button
        }
    }
}

@end
