#import "ViewController_Map.h"
#import "DeviceManager.h"
#import "MapAnnotations.h"
#import "AppDelegate.h"

@interface ViewController_Map ()<MKMapViewDelegate>

@end

@implementation ViewController_Map

- (void)viewDidLoad
{
    [super viewDidLoad];
	mapView = [[MKMapView alloc]init];
   // [mapView setFrame:self.view.frame];
    
    [self.view addSubview:mapView];
    
    mapView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    self.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    
    self.title = @"Lost Location";
    
    [mapView setMapType:MKMapTypeStandard];
    [self.view setAutoresizesSubviews:true];
    [mapView setDelegate:self];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
        self.navigationController.navigationBar.translucent = NO;
        self.navigationController.navigationBar.barTintColor = [UIColor darkGrayColor];
        self.navigationController.navigationBar.titleTextAttributes = @{UITextAttributeTextColor : [UIColor whiteColor]};
    }
    else
    {
        //This is the fix the 20px bug created by UINavigationController
        [self.view setFrame:CGRectOffset(self.view.frame, 0, -20)];
    }
    [mapView setFrame:self.view.frame];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    _device = [[DeviceManager sharedInstance]_DetailsDevice];
    
    //CLLocationCoordinate2D _coord = CLLocationCoordinate2DMake(_device._latitude,_device._longitude);

    CLLocationCoordinate2D _coord = CLLocationCoordinate2DMake(1.2947,103.7739);

    NSLog(@"show latitude: %f, longitude: %f",_coord.latitude,_coord.longitude);
    
    [mapView setZoomEnabled:YES];
    [mapView setScrollEnabled:YES];
    [mapView setCenterCoordinate:_coord];
    
    MapAnnotations *PointonMap = [[MapAnnotations alloc]init];
    [PointonMap setCoordinate:_coord];
    [PointonMap setTitle:[[DeviceManager sharedInstance]_DetailsDevice].str_Name];
    [PointonMap setSubtitle:@"Last Known Location"];
//   if([[_device str_DateLost]isEqual:@""])
//    {
//        [mapView setShowsUserLocation:YES];
//        UIAlertView *message = [[UIAlertView alloc]initWithTitle:@"Last Known Location" message:@"No Last Known Coordinates Found" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [message show];
//    }
//    else
//    {
        [mapView addAnnotation:PointonMap];
        [mapView setShowsUserLocation:NO];
//    }
}

// When a map annotation point is added, zoom to it (1500 range)
- (void)mapView:(MKMapView *)mv didAddAnnotationViews:(NSArray *)views
{
	MKAnnotationView *annotationView = [views objectAtIndex:0];
	id <MKAnnotation> mp = [annotationView annotation];
	MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance([mp coordinate], 1500, 1500);
	[mv setRegion:region animated:YES];
	[mv selectAnnotation:mp animated:YES];
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
@end
