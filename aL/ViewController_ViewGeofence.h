#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MapAnnotations.h"
#import "FencingData.h"

@interface ViewController_ViewGeofence : UIViewController{
    NSMutableArray *_CircleList;
    NSMutableArray *_PointList;
    MKMapView *view_Map;
    UIButton *btn_Left;
    UIButton *btn_Right;
}

-(void)setFenceView:(FencingData*)fence;
-(void)populateView;
-(void)unpopulateView;

@end
