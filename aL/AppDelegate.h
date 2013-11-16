#import <UIKit/UIKit.h>
#import "BMKGeneralDelegate.h"
#import "BMKMapManager.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,BMKGeneralDelegate>
{
    bool HasLaunchedOnce;
  //  BMKMapManager *mapManager;
}

@property (strong, nonatomic) UIWindow *window;

@end
