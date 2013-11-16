#import "ViewController_Geofencing.h"
#import "Protag_Device.h"
#import "DeviceManager.h"
#import "GPSManager.h"

@interface ViewController_Geofencing()

@end

@implementation ViewController_Geofencing

@synthesize _table;
@synthesize Cell_Geofencing;
@synthesize btn_Add;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UIView *mainView = [[[NSBundle mainBundle] loadNibNamed:@"View_Geofencing" owner:self options:nil]objectAtIndex:0];
    
    [self.view setAutoresizesSubviews:true];
    
    self.title = @"Secure Geofencing";
    
    self.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    [self.view setAutoresizesSubviews:true];
    
    [btn_Add addTarget:self action:@selector(pressedAddBtn) forControlEvents:UIControlEventTouchUpInside];
    
    //IBOutlet the table causes incorrect reference
    _table = (UITableView*)[mainView viewWithTag:1];
    [_table setDataSource:self];
    [_table setDelegate:self];
    
    //This is the fix the 20px bug created by UINavigationController
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
        self.navigationController.navigationBar.translucent = NO;
        self.navigationController.navigationBar.barTintColor = [UIColor darkGrayColor];
        self.navigationController.navigationBar.titleTextAttributes = @{UITextAttributeTextColor : [UIColor whiteColor]};
    }
    else
        [self.view setFrame:CGRectOffset(self.view.frame, 0, -20)];
    
    [self setView: mainView];

    _ViewController_AddGeofence = [[ViewController_AddGeofence alloc]init];
    _ViewController_ViewGeofence = [[ViewController_ViewGeofence alloc]init];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_table reloadData];
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
    return [[[FencingManager sharedInstance]_FencingList]count];
    NSLog(@"Number of rows %d", [[[FencingManager sharedInstance]_FencingList]count]);
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"Cell_Geofencing"];
    if(cell==NULL)
    {
        [self reloadCellNib];
        cell = Cell_Geofencing;
        Cell_Geofencing = NULL;
    }
    
    UILabel *lbl_LocationName = (UILabel*)[cell viewWithTag:3];
    UILabel *lbl_LocationData = (UILabel*)[cell viewWithTag:2];
    FencingData *tempData = [[[FencingManager sharedInstance]_FencingList]objectAtIndex:indexPath.row];
    
    if(tempData!=NULL){
    [lbl_LocationName setText:tempData.LocationName];
    [lbl_LocationData setText:[NSString stringWithFormat:@"%f ,%f",tempData.Longitude,tempData.Latitude]];
    }
    
    UIButton *btn_Delete = (UIButton*)[cell viewWithTag:4];
    [btn_Delete addTarget:self action:@selector(pressedRemoveBtn:) forControlEvents:UIControlEventTouchUpInside];
    UIButton *btn_Where = (UIButton*)[cell viewWithTag:5];
    [btn_Where addTarget:self action:@selector(pressedWhereBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

-(void)reloadCellNib{
    [[[NSBundle mainBundle] loadNibNamed:@"View_Geofencing" owner:self options:nil]objectAtIndex:1];
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
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
        cell.backgroundColor = [UIColor colorWithRed:.3 green:.3 blue:.3 alpha:.2];
    else
        cell.backgroundColor = [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:.4];
}

-(void)pressedAddBtn{
    NSLog(@"pressed Add Button");
#warning only allow adding if GPS is enabled
    [self.navigationController pushViewController:_ViewController_AddGeofence animated:true];
}

-(void)pressedRemoveBtn:(id)sender{
    NSLog(@"pressed remove button");
    UIButton *btn_Delete = (UIButton*)sender;
    UITableViewCell *cell;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
        cell = (UITableViewCell*)btn_Delete.superview.superview.superview;
    else
        cell = (UITableViewCell*)btn_Delete.superview.superview;

    [[FencingManager sharedInstance]removeRegion:[_table indexPathForCell:cell].row];
    
    [_table reloadData];
}

-(void)pressedWhereBtn:(id)sender{
    NSLog(@"pressed Where button");
    UIButton *btn_Where = (UIButton*)sender;
    UITableViewCell *cell;

    [_table reloadData];
    
    [self.navigationController pushViewController:_ViewController_ViewGeofence animated:true];

    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
        cell = (UITableViewCell*)btn_Where.superview.superview.superview;
        [_ViewController_ViewGeofence populateView];
        [_ViewController_ViewGeofence setFenceView:[[[FencingManager sharedInstance]_FencingList]objectAtIndex:[_table indexPathForCell:cell].row]];
    }
    else{
        cell = (UITableViewCell*)btn_Where.superview.superview;
        [_ViewController_ViewGeofence setFenceView:[[[FencingManager sharedInstance]_FencingList]objectAtIndex:[_table indexPathForCell:cell].row]];
    }
}
@end
