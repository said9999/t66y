#import <UIKit/UIKit.h>
#import "ViewController_AddGeofence.h"
#import "ViewController_ViewGeofence.h"
#import "FencingManager.h"

@interface ViewController_Geofencing : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    ViewController_AddGeofence *_ViewController_AddGeofence;
    ViewController_ViewGeofence *_ViewController_ViewGeofence;
}

@property (nonatomic) UITableView *_table;
@property IBOutlet UITableViewCell *Cell_Geofencing;
@property IBOutlet UIButton *btn_Add;

@end
