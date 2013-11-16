#import "ViewController_TableDevices.h"
#import "Protag_Device.h"
#import "DeviceManager.h"
#import "ViewController_DevicesWithSideMenu.h"
#import "BluetoothManager.h"
#import "PopUp_AddDevice.h"

@implementation ViewController_TableDevices

@synthesize currentDeviceTable;
@synthesize Cell_DeviceName;
@synthesize Cell_DeviceStatus;
@synthesize Cell_Snooze;
@synthesize Cell_AddDevice;

- (void)viewDidLoad
{
    [super viewDidLoad];
    //Register for refresh with MainController
    [[DeviceManager sharedInstance]registerObserver:self];

    _device = [[DeviceManager sharedInstance]_DetailsDevice];

    UIImageView *BackGroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"background.png"]];
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height) style:UITableViewStyleGrouped];
    [tableView setDataSource:self];
    [tableView setDelegate:self];
    
    [BackGroundView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    tableView.opaque = NO;
    tableView.backgroundView = nil;
    
    [tableView setBackgroundColor:[UIColor clearColor]];
    [tableView setSectionFooterHeight:10];
    [tableView setSectionHeaderHeight:10];
    [tableView setSeparatorColor:[UIColor darkGrayColor]];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [tableView setShowsVerticalScrollIndicator:true];
    [tableView setRowHeight:37];
    
    BackGroundView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    tableView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    self.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    [self.view setAutoresizesSubviews:true];
    
    //This is the fix the 20px bug created by UINavigationController
    [self.view setFrame:CGRectOffset(self.view.frame, 0, -20)];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
        self.navigationController.navigationBar.translucent = NO;
        self.navigationController.navigationBar.barTintColor = [UIColor darkGrayColor];
        self.navigationController.navigationBar.titleTextAttributes = @{UITextAttributeTextColor : [UIColor whiteColor]};
    }
    [self.view addSubview:BackGroundView];
    [self.view addSubview:tableView];
    currentDeviceTable = tableView;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //Register for refresh with MainController
    [self refreshDeviceView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    //deregister for refresh with MainController
    [[DeviceManager sharedInstance]deregisterObserver:self]; 
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1+[[[DeviceManager sharedInstance]_currentDevices]count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    //If device is in snooze mode, show dismiss snooze
    //else just show 2
    if(section<[[[DeviceManager sharedInstance]_currentDevices]count])
    {
        Protag_Device *device = [[[DeviceManager sharedInstance]_currentDevices]objectAtIndex:section];
        if(device.int_Status==STATUS_SNOOZE)
            return 3;
        else
            return 2;
    }
    else
        return 1; //Add device button
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    _device = [[DeviceManager sharedInstance]_DetailsDevice];

    UITableViewCell *cell;
    if(indexPath.section<[[[DeviceManager sharedInstance]_currentDevices]count])
    {
        _device = (Protag_Device*)[[[DeviceManager sharedInstance]_currentDevices]objectAtIndex:indexPath.section];
        if(indexPath.row==0)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"Cell_Device1"];
            if(cell==NULL)
            {
                [self reloadNib];
                cell = Cell_DeviceName;
                Cell_DeviceName=NULL;
            }
            
            UILabel *lbl_Name = (UILabel*)[cell viewWithTag:1];
            lbl_Name.text = [_device str_Name];
            
            if(_device.int_Status != STATUS_CONNECTING)
            {
                UISwitch *btn_OnOff = (UISwitch*)[cell viewWithTag:2];
                [btn_OnOff setOn: (_device.int_Status == STATUS_CONNECTED || _device.int_Status==STATUS_SECURE_ZONE)];

                [btn_OnOff addTarget:self action:@selector(toggleOnOff:) forControlEvents:UIControlEventValueChanged];
            }
            return cell;
        }
        else if(indexPath.row==1){
            cell = [tableView dequeueReusableCellWithIdentifier:@"Cell_Device2"];
            if(cell==NULL)
            {
                [self reloadNib];
                cell = Cell_DeviceStatus;
                Cell_DeviceStatus=NULL;
            }
            UILabel *lbl_Status = (UILabel*)[cell viewWithTag:3];
            [lbl_Status setText:_device.str_Status];
            return cell;
        }else{
            cell = [tableView dequeueReusableCellWithIdentifier:@"Cell_Device3"];
            if(cell==NULL)
            {
                [self reloadNib];
                cell = Cell_Snooze;
                Cell_Snooze=NULL;
            }
            return cell;
        }
    }
    else
    {
        //Add Device
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell_AddDevice"];
        if(cell==NULL)
        {
            [self reloadNib];
            cell = Cell_AddDevice;
            Cell_AddDevice=NULL;
        }
        return cell;
    }
}

-(void)reloadNib{
    //Load the Nib for tableviewcells
    if([[[UIDevice currentDevice]systemVersion]floatValue] >=7.0)
        [[[NSBundle mainBundle] loadNibNamed:@"Cells_CurrentDevicesios7" owner:self options:nil]objectAtIndex:0];
    else
        [[[NSBundle mainBundle] loadNibNamed:@"Cells_CurrentDevices" owner:self options:nil]objectAtIndex:0];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section<[[[DeviceManager sharedInstance]_currentDevices]count])
    {
        if(indexPath.row == 1)
        {
            [[DeviceManager sharedInstance]set_DetailsDevice:[[[DeviceManager sharedInstance]_currentDevices]objectAtIndex: indexPath.section]];
            UITableViewCell *temp_cell = [tableView cellForRowAtIndexPath:indexPath];
            [temp_cell setSelected:false];
            
            //Access Parent view to push to details view (so that we only have 1 details viewcontroller
            UIViewController *tempController = [self parentViewController];
            while(![tempController isKindOfClass:[ViewController_DevicesWithSideMenu class]])tempController = [tempController parentViewController];
            
            [((ViewController_DevicesWithSideMenu*)tempController) PushToDetails];
            
        }
        else if(indexPath.row==2)
        {
            //dismiss snooze
            UITableViewCell *temp_cell = [tableView cellForRowAtIndexPath:indexPath];
            [temp_cell setSelected:false];
            
            _device = [[[DeviceManager sharedInstance]_currentDevices]objectAtIndex: indexPath.section];
            [_device DismissSnooze];
            //Attempt reconnect again
            [_device Connect];

            [self refreshDeviceView];
        }
    }
    else
    {
        [self pressedAddDeviceBtn];
        UITableViewCell *temp_cell = [tableView cellForRowAtIndexPath:indexPath];
        [temp_cell setSelected:false];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //Setting background color of cell
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
        cell.backgroundColor = [UIColor colorWithRed:.3 green:.3 blue:.3 alpha:.2];
    else
        cell.backgroundColor = [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:.4];
}

- (void) refreshDeviceView{
    //_device = [[DeviceManager sharedInstance]_DetailsDevice];
    [currentDeviceTable reloadData];
}

-(void)toggleOnOff:(id)sender{
    NSIndexPath *indexPath;
    if([sender isKindOfClass:[UISwitch class]])
    {
        UISwitch *btn_OnOff = (UISwitch*)sender;
        
        //Find out which row it came from (need to superview 3 times for ios7 and two times for ios6 and below)
        if([[[UIDevice currentDevice]systemVersion]floatValue] >= 7.0)
            indexPath=[currentDeviceTable indexPathForCell:(UITableViewCell*)btn_OnOff.superview.superview.superview];
        else
            indexPath=[currentDeviceTable indexPathForCell:(UITableViewCell*)btn_OnOff.superview.superview];
        
        _device = (Protag_Device*)[[[DeviceManager sharedInstance]_currentDevices]objectAtIndex:indexPath.section];
        
        if(_device!=NULL && btn_OnOff!=NULL)
        {
            if([[BluetoothManager sharedInstance]is_BluetoothOn])
            {
                if([btn_OnOff isOn])
                    [_device Connect];
                else
                    [_device Disconnect];
            }
            else
            {
                if([[[UIDevice currentDevice]systemVersion]floatValue] >= 7.0){
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Information" message:@"Bluetooth is currently OFF, please turn ON Bluetooth in iPhone Settings" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alertView show];
                }
                else
                {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"\n\n\n\n\n" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    
                    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(90, 10, 130, 40)];
                    [title setTextColor:[UIColor whiteColor]];
                    [title setFont:[UIFont boldSystemFontOfSize:20]];
                    [title setText:@"Information"];
                    [title setBackgroundColor:[UIColor clearColor]];
                    [alertView addSubview:title];
                    
                    UITextView *contentTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, 45, 260, 100)];
                    [contentTextView setEditable:FALSE];
                    [contentTextView setTextColor:[UIColor blackColor]];
                    [contentTextView setFont:[UIFont systemFontOfSize:18]];
                    contentTextView.contentMode = UIViewAutoresizingFlexibleWidth;
                    [contentTextView setBackgroundColor:[UIColor clearColor]];
                    [contentTextView setClipsToBounds:TRUE];
                    [contentTextView setTextAlignment:NSTextAlignmentCenter];
                    [contentTextView setText:@"Bluetooth is currently OFF, please turn ON Bluetooth in iPhone Settings"];
                    [alertView addSubview:contentTextView];
                    
                    [alertView show];
                }
            }
        }
    }
}

-(void)pressedAddDeviceBtn{
    if([[BluetoothManager sharedInstance]is_BluetoothOn])
        [[PopUp_AddDevice sharedInstance]ShowPopUp];
    else
    {
        if([[[UIDevice currentDevice]systemVersion]floatValue] >= 7.0){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Information" message:@"Bluetooth is currently OFF, please turn ON Bluetooth in iPhone Settings" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"\n\n\n\n\n" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            
            UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(90, 10, 130, 40)];
            [title setTextColor:[UIColor whiteColor]];
            [title setFont:[UIFont boldSystemFontOfSize:20]];
            [title setText:@"Information"];
            [title setBackgroundColor:[UIColor clearColor]];
            [alertView addSubview:title];
            
            UITextView *contentTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, 45, 260, 100)];
            [contentTextView setEditable:FALSE];
            [contentTextView setTextColor:[UIColor blackColor]];
            [contentTextView setFont:[UIFont systemFontOfSize:18]];
            contentTextView.contentMode = UIViewAutoresizingFlexibleWidth;
            [contentTextView setBackgroundColor:[UIColor clearColor]];
            [contentTextView setClipsToBounds:TRUE];
            [contentTextView setTextAlignment:NSTextAlignmentCenter];
            [contentTextView setText:@"Bluetooth is currently OFF, please turn ON Bluetooth in iPhone Settings"];
            [alertView addSubview:contentTextView];
            
            [alertView show];
        }
    }
}


@end
