#import "ViewController_Wifi.h"
#import "Protag_Device.h"
#import "DeviceManager.h"
#import "WifiDetector.h"

@interface ViewController_Wifi ()

@end

@implementation ViewController_Wifi

@synthesize _table;
@synthesize Cell_Wifi;
@synthesize btn_Add;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
     UIView *mainView = [[[NSBundle mainBundle] loadNibNamed:@"View_Wifi" owner:self options:nil]objectAtIndex:0];
    
    [self setView: mainView];
    
    [self.view setAutoresizesSubviews:true];
    
    self.title = @"Secure Wifi-Zones";
    
    self.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    [self.view setAutoresizesSubviews:true];
    
    //This is the fix the 20px bug created by UINavigationController
    [self.view setFrame:CGRectOffset(self.view.frame, 0, -20)];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
        self.navigationController.navigationBar.translucent = NO;
        self.navigationController.navigationBar.barTintColor = [UIColor darkGrayColor];
        self.navigationController.navigationBar.titleTextAttributes = @{UITextAttributeTextColor : [UIColor whiteColor]};
    }
    [btn_Add addTarget:self action:@selector(pressedAddBtn) forControlEvents:UIControlEventTouchUpInside];
    
    //IBOutlet the table causes incorrect reference
    _table = (UITableView*)[mainView viewWithTag:1];
    [_table setDataSource:self];
    [_table setDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[WifiDetector sharedInstance]_WifiList]count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"Cell_Wifi"];
    if(cell==NULL)
    {
        [self reloadCellNib];
        cell = Cell_Wifi;
        Cell_Wifi = NULL;
    }
    
    UILabel *lbl_SSID = (UILabel*)[cell viewWithTag:3];
    UILabel *lbl_BSSID = (UILabel*)[cell viewWithTag:2];
    WifiData *tempData = [[[WifiDetector sharedInstance]_WifiList]objectAtIndex:indexPath.row];
    
    if(tempData!=NULL){
    [lbl_SSID setText:tempData.SSID];
    [lbl_BSSID setText:tempData.BSSID];
    }
    
    UIButton *btn_Delete = (UIButton*)[cell viewWithTag:4];
    [btn_Delete addTarget:self action:@selector(pressedRemoveBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

-(void)reloadCellNib{
    [[[NSBundle mainBundle] loadNibNamed:@"View_Wifi" owner:self options:nil]objectAtIndex:1];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    //do nothing
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   //Nothing
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //Setting background color of cell
    cell.backgroundColor = [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:.4];
}

-(void)pressedAddBtn{
    NSLog(@"pressed Add Button");
    [[WifiDetector sharedInstance]addCurrentNetworkToList];

   /* if([[WifiDetector sharedInstance]isCurrentNetWorkOnList])
            [[DeviceManager sharedInstance]SecureZone_On];
*/
    [_table reloadData];
}

-(void)pressedRemoveBtn:(id)sender{
    NSLog(@"pressed remove button");
    UIButton *btn_Delete = (UIButton*)sender;
    UITableViewCell *cell = (UITableViewCell*)btn_Delete.superview.superview;
    
    UILabel *lbl_BSSID = (UILabel*)[cell viewWithTag:2];
    [[WifiDetector sharedInstance]removeWifiWithBSSID:lbl_BSSID.text];

    if(![[WifiDetector sharedInstance]isCurrentNetWorkOnList])
                [[DeviceManager sharedInstance]SecureZone_Off];
    [[WifiDetector sharedInstance]CheckWiFiStatus];
    [_table reloadData];
}

@end
