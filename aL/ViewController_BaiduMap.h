#import <UIKit/UIKit.h>
#import "BMapKit.h"
#import "BMKMapView.h"
#import "Protag_Device.h"
#import "BMKGeneralDelegate.h"

@interface ViewController_BaiduMap : UIViewController{
    BMKMapManager *mapManager;
    BMKMapView *mapView;
    Protag_Device *_device;
}

-(NSString *)getMyBundlePath:(NSString *)filename;

@end
