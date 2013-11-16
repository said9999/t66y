#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MapAnnotations.h"
@class Reachability;


@interface ViewController_AddGeofence : UIViewController{
    UIView* view_Loading;
    MKCircle *circle;
    MapAnnotations *PointonMap;
    Reachability *wwanReach;
    Reachability *wifiReach;
}

@property UITextField *text_Name;
@property UISegmentedControl *seg_Radius;
@property UIButton *btn_Add;
@property MKMapView *view_Map;
-(void)LocationReachablility;
@end
