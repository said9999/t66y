#import <UIKit/UIKit.h>

@interface ViewController_Wifi : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic) UITableView *_table;
@property (nonatomic) IBOutlet UITableViewCell *Cell_Wifi;
@property (nonatomic) IBOutlet UIButton *btn_Add;

@end
