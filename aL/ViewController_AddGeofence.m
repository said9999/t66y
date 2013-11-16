#import "ViewController_AddGeofence.h"
#import "ViewController_Geofencing.h"
#import "FencingManager.h"
#import "GPSManager.h"
#import "Reachability.h"

@interface ViewController_AddGeofence ()<FencingObserver,UITextFieldDelegate,MKMapViewDelegate>

@end

@implementation ViewController_AddGeofence

@synthesize btn_Add;
@synthesize view_Map;
@synthesize text_Name;
@synthesize seg_Radius;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView *mainView = [[[NSBundle mainBundle] loadNibNamed:@"ViewController_AddGeofence" owner:self options:nil]objectAtIndex:0];
    view_Loading = [[[NSBundle mainBundle] loadNibNamed:@"ViewController_AddGeofence" owner:self options:nil]objectAtIndex:1];
    
    text_Name = (UITextField*)[mainView viewWithTag:1];
    seg_Radius = (UISegmentedControl*)[mainView viewWithTag:2];
    btn_Add = (UIButton*)[mainView viewWithTag:3];
    view_Map = (MKMapView*)[mainView viewWithTag:4];

    text_Name.delegate = self;
    
    [self setView: mainView];
    
    circle = NULL;
    PointonMap = NULL;
    
    [self.view setAutoresizesSubviews:true];
    
    self.title = @"Add Secure Zone";
    
    self.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    [self.view setAutoresizesSubviews:true];
    
    [btn_Add addTarget:self action:@selector(pressedAdd) forControlEvents:UIControlEventTouchDown];
    [seg_Radius addTarget:self action:@selector(changeRadius) forControlEvents:UIControlEventValueChanged];
        
    [view_Map setDelegate:self];
    
    //This is the fix the 20px bug created by UINavigationController
    [self.view setFrame:CGRectOffset(self.view.frame, 0, -20)];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
        self.navigationController.navigationBar.translucent = NO;
        self.navigationController.navigationBar.barTintColor = [UIColor darkGrayColor];
        self.navigationController.navigationBar.titleTextAttributes = @{UITextAttributeTextColor : [UIColor whiteColor]};
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[FencingManager sharedInstance]registerObserver:self];
    [self LocationReachablility];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[FencingManager sharedInstance]deregisterObserver:self];
    [self hideLoading];
    PointonMap = NULL;
}

-(void)showLoading{
    if(view_Loading.superview != self.view){
        [view_Loading setFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)];
        //default values
        [text_Name setText:@""];
        seg_Radius.segmentedControlStyle = UISegmentedControlStyleBar;
        [seg_Radius setSelectedSegmentIndex:0];
        [self.view addSubview:view_Loading];
        }
}

-(void)hideLoading{
    if(view_Loading.superview!=NULL && view_Loading.superview==self.view)
        [view_Loading removeFromSuperview];
    
    if([view_Map selectedAnnotations].count==0 && PointonMap!=NULL)
        [view_Map selectAnnotation:PointonMap animated:true];
}

-(void)pressedAdd{
    NSLog(@"Pressed Add Button");
    
    //check duplicate secure zone names
    for(int i=0;i<[[FencingManager sharedInstance]_FencingList].count;i++)
    {
        FencingData *tempData = [[[FencingManager sharedInstance]_FencingList]objectAtIndex:i];
        
        if([[tempData LocationName]isEqualToString:[text_Name text]])
        {
            UIAlertView *tempAlert = [[UIAlertView alloc]initWithTitle:@"Duplicate Name" message:@"A Secure Zone with the same name exist, please change the name of this secure zone" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [tempAlert show];
            return;
        }
    }
    [[[FencingManager sharedInstance]getCurrentRegion]setLocationName:[text_Name text]];
    [[FencingManager sharedInstance]addCurrentRegion];
    [self.navigationController popViewControllerAnimated:true];
}

-(void)changeRadius{
    NSLog(@"change Radius");
    FencingData *tempData = [[FencingManager sharedInstance]getCurrentRegion];
    
    if(tempData==NULL)
        return;
    
    double tempRadius=0;
    
    switch([seg_Radius selectedSegmentIndex]){
        case 2:
            tempRadius=800;
            break;
        case 1:
            tempRadius=400;
            break;
        case 0:
        default:
            tempRadius=200;
            break;
    }
    
    [[[FencingManager sharedInstance]getCurrentRegion]setRadius:tempRadius];
    
    CLLocationCoordinate2D _coord = CLLocationCoordinate2DMake([tempData Latitude], [tempData Longitude]);
    
    if(circle!=NULL)
       [view_Map removeOverlay:circle];
    
    circle = [MKCircle circleWithCenterCoordinate:_coord radius:tempRadius];
    
    [view_Map addOverlay:circle];
}

-(void)refreshView{
    FencingData *tempData = [[FencingManager sharedInstance]getCurrentRegion];
    if(tempData!=NULL)
    {
        NSLog(@"Secure Zone View refresh");

        [text_Name setText:[tempData LocationName]];
        
        CLLocationCoordinate2D _coord = CLLocationCoordinate2DMake([tempData Latitude], [tempData Longitude]);
        
        [view_Map setZoomEnabled:YES];
        [view_Map setScrollEnabled:YES];
        
        [view_Map setShowsUserLocation:NO];
        
        [view_Map setCenterCoordinate:_coord];
        
        if(PointonMap!=NULL)
           [view_Map removeAnnotation:PointonMap];
        
        PointonMap = [[MapAnnotations alloc]init];
        [PointonMap setCoordinate:_coord];
        [PointonMap setTitle:@"Secure Zone"];
        [PointonMap setSubtitle:@"Press \"Add\" to use this Secure Zone"];
        
        [view_Map addAnnotation:PointonMap];
        
        [self changeRadius];
        
        [self hideLoading];
    }
}

// When a map annotation point is added, zoom to it (800 range)
- (void)mapView:(MKMapView *)mv didAddAnnotationViews:(NSArray *)views
{
	MKAnnotationView *annotationView = [views objectAtIndex:0];
	id <MKAnnotation> mp = [annotationView annotation];
	MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance([mp coordinate], 800, 800);
	[mv setRegion:region animated:YES];
    [view_Map selectAnnotation:PointonMap animated:true];
}

//Circle overlay
-(MKOverlayView*)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay{
    MKCircleView *circleView = [[MKCircleView alloc]initWithOverlay:overlay];
    circleView.strokeColor = [UIColor redColor];
    circleView.fillColor = [[UIColor redColor]colorWithAlphaComponent:0.4];
    return circleView;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return NO;
}

-(void)LocationReachablility{
    wifiReach = [Reachability reachabilityForLocalWiFi];
    NetworkStatus networkStatus = [wifiReach currentReachabilityStatus];
    if (networkStatus == ReachableViaWiFi) {
        [self showLoading];
        [[FencingManager sharedInstance]updateCurrentRegion:NULL];
        [[FencingManager sharedInstance]registerObserver:self];
        [[GPSManager sharedInstance]GenerateCurrentGeofence];
    }
    else
    {
        wwanReach = [Reachability reachabilityForInternetConnection];
        NetworkStatus networkStatus = [wwanReach currentReachabilityStatus];
        if (networkStatus == ReachableViaWWAN) {
            UIAlertView *message = [[UIAlertView alloc]initWithTitle:@"Information" message:@"WiFi is currently OFF/Not Connected, GeoFence accuracy may be affected. Do you wish to add the current location(you may turn OFF WiFi after adding Location)" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
            [message setAlertViewStyle:UIAlertViewStyleDefault];
            [message setTag:1];
            [message show];
        }
        else
        {
            UIAlertView *message =  [[UIAlertView alloc]initWithTitle:@"Information" message:@"Location cannot be found as both WiFi and 3G is disabled" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [message setAlertViewStyle:UIAlertViewStyleDefault];
            [message setTag:1];
            [message show];
        }
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag == 1)
    {
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        if([title isEqualToString:@"Yes"])
        {
            NSLog(@"ReachViaWWAN Yes was Pressed");
            [self showLoading];
            [[FencingManager sharedInstance]updateCurrentRegion:NULL];
            [[FencingManager sharedInstance]registerObserver:self];
            [[GPSManager sharedInstance]GenerateCurrentGeofence];
        }
        else {
            [[self navigationController]popViewControllerAnimated:true];//simulate the back button
        }
    }
}

@end
