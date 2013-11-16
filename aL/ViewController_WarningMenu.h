#import <UIKit/UIKit.h>
#import "WarningManager.h"

@interface ViewController_WarningMenu : UIViewController<UITableViewDelegate,UITableViewDataSource,WarningObserver>{
    UIView *_superView;
}

@property (nonatomic) UITableView *_tableView;
@property IBOutlet UITableViewCell *Cell_Fine;
@property IBOutlet UITableViewCell *Cell_Warning;

@end
