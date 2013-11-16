#import "ViewController_ViewGeofence.h"
#import "FencingManager.h"

@interface ViewController_ViewGeofence ()<MKMapViewDelegate>

@end

@implementation ViewController_ViewGeofence

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView *mainView = [[[NSBundle mainBundle] loadNibNamed:@"ViewController_ViewGeofence" owner:self options:nil]objectAtIndex:0];
  
    _CircleList = [[NSMutableArray alloc]init];
    _PointList = [[NSMutableArray alloc]init];
    
    view_Map = (MKMapView*)[mainView viewWithTag:1];
    [view_Map setZoomEnabled:YES];
    [view_Map setScrollEnabled:YES];
    [view_Map setShowsUserLocation:YES];
    [view_Map setMapType:MKMapTypeStandard];

    btn_Left = (UIButton*)[mainView viewWithTag:2];
    btn_Right = (UIButton*)[mainView viewWithTag:3];
    [btn_Left addTarget:self action:@selector(pressedLeftBtn) forControlEvents:UIControlEventTouchDown];
    [btn_Right addTarget:self action:@selector(pressedRightBtn) forControlEvents:UIControlEventTouchDown];
    
    [self setView: mainView];
    
    [self.view setAutoresizesSubviews:true];
    
    self.title = @"View Secure Zone";
    
    self.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    [self.view setAutoresizesSubviews:true];
    
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
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)
        [self populateView];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self unpopulateView];
}

-(void)populateView{
    for(int i=0;i<[[FencingManager sharedInstance]_FencingList].count;i++)
    {
        FencingData *tempData = [[[FencingManager sharedInstance]_FencingList]objectAtIndex:i];
        
        //Add points
        CLLocationCoordinate2D _coord = CLLocationCoordinate2DMake([tempData Latitude], [tempData Longitude]);
        MapAnnotations *PointonMap = [[MapAnnotations alloc]init];
        [PointonMap setCoordinate:_coord];
        [PointonMap setTitle:[tempData LocationName]];
        [PointonMap setSubtitle:[NSString stringWithFormat:@"Radius: %0.fm",[tempData Radius]]];
        
        [view_Map addAnnotation:PointonMap];
        [_PointList addObject:PointonMap];
        
        //Add circle
        MKCircle *circle = [MKCircle circleWithCenterCoordinate:_coord radius:[tempData Radius]];
        [view_Map addOverlay:circle];
        [_CircleList addObject:circle];
    }
    
    if([[FencingManager sharedInstance]_FencingList].count>=1)
    {
        [btn_Left setAlpha:0.7];
        [btn_Left setEnabled:true];
        [btn_Right setAlpha:0.7];
        [btn_Right setEnabled:true];
    }
    else
    {
        [btn_Left setAlpha:0];
        [btn_Left setEnabled:false];
        [btn_Right setAlpha:0];
        [btn_Right setEnabled:false];
    }
    NSLog(@"Populate %d",_PointList.count);
}

-(void)unpopulateView{
    [view_Map removeAnnotations:_PointList];
    [view_Map removeOverlays:_CircleList];
    [_PointList removeAllObjects];
    [_CircleList removeAllObjects];
    NSLog(@"UNPopulate %d",_PointList.count);

}

-(void)setFenceView:(FencingData*)fence{
    NSLog(@"set Fence View %d  , %@",_PointList.count,_PointList.description);
    [view_Map setRegion:MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake([fence Latitude], [fence Longitude]), 800, 800) animated:YES];

    for(int i=0;i<[[FencingManager sharedInstance]_FencingList].count;i++)
    {
        NSLog(@"%d",[[FencingManager sharedInstance]_FencingList].count);
        if([[[FencingManager sharedInstance]_FencingList]objectAtIndex:i]==fence)
        {
            [view_Map selectAnnotation:[_PointList objectAtIndex:i] animated:YES];
            [[FencingManager sharedInstance]set_CurrentViewFence:fence];
            return;
        }
    }
}

//Circle overlay delegate
-(MKOverlayView*)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay{
    MKCircleView *circleView = [[MKCircleView alloc]initWithOverlay:overlay];
    circleView.strokeColor = [UIColor redColor];
    circleView.fillColor = [[UIColor redColor]colorWithAlphaComponent:0.4];
    return circleView;
}

-(void)pressedLeftBtn{
    NSLog(@"Pressed Left");
    for(int i=0;i<[[FencingManager sharedInstance]_FencingList].count;i++)
    {
        if([[[FencingManager sharedInstance]_FencingList]objectAtIndex:i]==[[FencingManager sharedInstance]_CurrentViewFence])
        {
            if(i==0)
                i=[[FencingManager sharedInstance]_FencingList].count;
            i--;
            [self setFenceView:[[[FencingManager sharedInstance]_FencingList]objectAtIndex:i]];
        }
    }
}

-(void)pressedRightBtn{
    NSLog(@"Pressed Right");
    for(int i=0;i<[[FencingManager sharedInstance]_FencingList].count;i++)
    {
        if([[[FencingManager sharedInstance]_FencingList]objectAtIndex:i]==[[FencingManager sharedInstance]_CurrentViewFence])
        {
            if(i==[[FencingManager sharedInstance]_FencingList].count-1)
                i=-1;
            i++;
            [self setFenceView:[[[FencingManager sharedInstance]_FencingList]objectAtIndex:i]];
        }
    }
}

@end
