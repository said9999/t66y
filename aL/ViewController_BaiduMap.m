#import "ViewController_BaiduMap.h"
#import "DeviceManager.h"
#import "AppDelegate.h"

#define MYBUNDLE_NAME @"mapapi.bundle"
#define MYBUNDLE_PATH [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: MYBUNDLE_NAME]
#define MYBUNDLE [NSBundle bundleWithPath: MYBUNDLE_PATH]

@interface ViewController_BaiduMap ()<BMKMapViewDelegate,BMKGeneralDelegate>
@end

@implementation ViewController_BaiduMap

-(NSString *) getMyBundlePath: (NSString *)filename {
    NSBundle * libBundle = MYBUNDLE;
    if (libBundle && filename){
    NSString * s = [[libBundle resourcePath] stringByAppendingPathComponent: filename];
        NSLog (@"%@", s);
        return s;
    }
    return nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    mapManager = [[BMKMapManager alloc]init];
    
    //either one can use i think so, registered for two api key
    //BOOL unique_Identifier = [mapManager start: @"3cf99a6c628cae126cd34f95e3672fe6" generalDelegate: nil];
    BOOL unique_Identifier = [mapManager start: @"5E4C7ce641dca63331ac501d7ea06310" generalDelegate: nil];
    
    if(!(unique_Identifier))
    {
        NSLog(@"Manager Start Failed");
    }
    
    mapView = [[BMKMapView alloc]init];
    
    mapView.autoresizingMask = (UIViewAutoresizingFlexibleHeight+20 | UIViewAutoresizingFlexibleWidth);
    self.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight+20 | UIViewAutoresizingFlexibleWidth);
    [self.view setAutoresizesSubviews:true];

    self.title = @"Lost Location";
    
    [mapView setMapType:BMKMapTypeStandard];
    [mapView setDelegate:self];
    [self.view addSubview:mapView];

    //This is the fix the 20px bug created by UINavigationController
    [self.view setFrame:CGRectOffset(self.view.frame, 0, -20)];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
        self.navigationController.navigationBar.translucent = NO;
        self.navigationController.navigationBar.barTintColor = [UIColor darkGrayColor];
        self.navigationController.navigationBar.titleTextAttributes = @{UITextAttributeTextColor : [UIColor whiteColor]};
    }
    [mapView setFrame:self.view.frame];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    _device = [[DeviceManager sharedInstance]_DetailsDevice];
   // CLLocationCoordinate2D _coord = CLLocationCoordinate2DMake(_device._latitude,_device._longitude);
    CLLocationCoordinate2D _coord = CLLocationCoordinate2DMake(_device._latitude,_device._longitude);
    NSLog(@"show latitude: %f, longitude: %f",_coord.latitude,_coord.longitude);
    
    [mapView setZoomEnabled:YES];
    [mapView setScrollEnabled:YES];
    [mapView setCenterCoordinate:_coord];

    BMKPointAnnotation *PointonMap = [[BMKPointAnnotation alloc]init];
    PointonMap.coordinate = _coord;
    PointonMap.title = [[DeviceManager sharedInstance]_DetailsDevice].str_Name;
    PointonMap.subtitle = @"Last Known Location";
    
    if([[_device str_DateLost]isEqual:@""])
    {
        [mapView setShowsUserLocation:YES];
        UIAlertView *message = [[UIAlertView alloc]initWithTitle:@"Last Known Location" message:@"No Last Known Coordinates Found" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [message show];
    }
    else
    {
        [mapView addAnnotation:PointonMap];
        [mapView setShowsUserLocation:NO];
    }
}

// When a map annotation point is added, zoom to it (1500 range)
-(void)mapView:(BMKMapView *)mView didAddAnnotationViews:(NSArray *)views
{
	BMKAnnotationView *annotationView = [views objectAtIndex:0];
	id <BMKAnnotation> mp = [annotationView annotation];
	BMKCoordinateRegion region = BMKCoordinateRegionMakeWithDistance([mp coordinate], 1500, 1500);
	//BMKCoordinateRegion region = BMKCoordinateRegionMake([mp coordinate], BMKCoordinateSpanMake(0.5,0.5));
    [mView setRegion:region animated:YES];
	[mView selectAnnotation:mp animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [mapView setShowsUserLocation:NO];
}


 - (void)onGetNetworkState:(int)iError
 {
 NSLog(@"onGetNetworkState %d",iError);
 }
 
 - (void)onGetPermissionState:(int)iError
 {
 NSLog(@"onGetPermissionState %d",iError);
 }


@end
