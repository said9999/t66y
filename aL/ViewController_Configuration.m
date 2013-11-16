#import "ViewController_Configuration.h"
#import "DataManager.h"
#import "GPSManager.h"
#import "DeviceManager.h"
#import "AccountManager.h"
#import "ViewController_SignUpAndSignIn.h"
#import "CustomizedCell.h"
#import "BlueToothBackgroundManager.h"
#import "NearbyDevicesViewController.h"

@interface ViewController_Configuration (){
    int notificateCount;
}

@end

@implementation ViewController_Configuration
@synthesize MobileTable;
@synthesize Cell_Tracking;
@synthesize Cell_BackUp;
@synthesize Cell_LogOut;
@synthesize Cell_Developer;
@synthesize trackingOnOff;
@synthesize backUpOnOff;
@synthesize developerOnOff;
@synthesize lbl_LogOut;
@synthesize barBtn_Back;
@synthesize lblDetail_LogOut;

static UIView *notificationView;
static UILabel *notificationLable;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView *BackGroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"background"]];
    
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height) style:UITableViewStyleGrouped];
    
    [self.view setAutoresizesSubviews:true];
    
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
    [tableView setRowHeight:60];
    
    self.title = @"Mobile";
    
    MobileTable = tableView;
    
    BackGroundView.autoresizingMask = (UIViewAutoresizingFlexibleHeight+20 | UIViewAutoresizingFlexibleWidth);
    tableView.autoresizingMask = (UIViewAutoresizingFlexibleHeight+20 | UIViewAutoresizingFlexibleWidth);
    self.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight+20 | UIViewAutoresizingFlexibleWidth);
    [self.view setAutoresizesSubviews:true];
    
    [self.view addSubview:BackGroundView];
    [self.view addSubview:tableView];

    //This is the fix the 20px bug created by UINavigationController
    [self.view setFrame:CGRectOffset(self.view.frame, 0, -20)];

    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
        self.navigationController.navigationBar.translucent = NO;
        self.navigationController.navigationBar.barTintColor = [UIColor darkGrayColor];
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        self.navigationController.navigationBar.titleTextAttributes = @{UITextAttributeTextColor : [UIColor whiteColor]};
        [barBtn_Back setTintColor:[UIColor whiteColor]];
        //self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [BackGroundView setFrame:self.view.frame];
    [tableView setFrame:self.view.frame];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self refreshMobileTable];
    
    //keep notification update
    [[CrowdTrackNotificationHandler sharedInstance] Register:self];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];

    for(UIView *subview in self.view.subviews)
    {
        if(subview.tag == 10)
            [subview removeFromSuperview];
    }
}
#pragma mark - UITableview Datasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
	return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section==0)
        return 3;
    else
        return 1;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell;
    switch (indexPath.section) {
        case 0:{
            switch (indexPath.row) {
                case 0:{
                    cell = [tableView dequeueReusableCellWithIdentifier:@"Cell_Tracking"];
                    
                    if(cell==NULL){
                        [self reloadNib];
                        cell=Cell_Tracking;
                        Cell_Tracking=NULL;
                    }
                    
                    if(cell!=NULL)
                    {
                        UILabel *lbl_Tracking = (UILabel*)[cell viewWithTag:1];
                        trackingOnOff = (UISwitch*)[cell viewWithTag:2];
                        [lbl_Tracking setText:@"Online Tracking"];
                        UILabel *lblDetail_Tracking = (UILabel*)[cell viewWithTag:3];
                        [lblDetail_Tracking setText:@"Secure your smartphone"];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        [trackingOnOff setOn:[[DataManager sharedInstance]Settings_Tracking]];
                        [trackingOnOff addTarget:self action:@selector(ToggleTracking:) forControlEvents:UIControlEventValueChanged];
                    }
                }
                break;
                
                case 1:{
                    static NSString *cellIdentifier = @"CustomizedCell";
                    CustomizedCell *customizedCell = (CustomizedCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                    
                    if (customizedCell == nil) {
                        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CustomizedCell" owner:self options:nil];
                        customizedCell = [nib objectAtIndex:0];
                    }
                    
                    customizedCell.cellTitle.text = @"Crowd Tracking";
                    customizedCell.detailText.text = @"Join crowd tracking community";
                    [customizedCell.switchToggle addTarget:self action:@selector(ToggleCrowdTracking:) forControlEvents:UIControlEventValueChanged];
                    
                    cell = customizedCell;
                }
                    break;
                case 3:{
                    cell = [tableView dequeueReusableCellWithIdentifier:@"Cell_BackUp"];
        
                    if(cell==NULL){
                        [self reloadNib];
                        cell=Cell_BackUp;
                        Cell_BackUp=NULL;
                    }
                    
                    if(cell!=NULL)
                    {
                        UILabel *lbl_BackUp = (UILabel*)[cell viewWithTag:4];
                        backUpOnOff = (UISwitch*)[cell viewWithTag:5];
                        [lbl_BackUp setText:@"Online BackUp"];
                        UILabel *lblDetail_BackUp = (UILabel*)[cell viewWithTag:6];
                        [lblDetail_BackUp setText:@"Backup your contact list"];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        [backUpOnOff setOn:[[DataManager sharedInstance]Settings_Backup]];
                        [backUpOnOff addTarget:self action:@selector(ToggleBackUp:) forControlEvents:UIControlEventValueChanged];
                    }
                }
                break;
                case 2:{
                    cell = [tableView dequeueReusableCellWithIdentifier:@"Cell_Developer"];
                    
                    if(cell==NULL){
                        [self reloadNib];
                        cell=Cell_Developer;
                        Cell_Developer=NULL;
                    }
                    
                    if(cell!=NULL)
                    {
                        UILabel *lbl_Developer = (UILabel*)[cell viewWithTag:9];
                        developerOnOff = (UISwitch*)[cell viewWithTag:10];
                        [lbl_Developer setText:@"Developer Mode"];
                        UILabel *lblDetailDeveloper = (UILabel*)[cell viewWithTag:11];
                        [lblDetailDeveloper setText:@"Public/Developer Server"];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        [developerOnOff setOn:[[AccountManager sharedAccountManager]bol_isDeveloper]];
                        [developerOnOff addTarget:self action:@selector(ToggleDeveloper:) forControlEvents:UIControlEventValueChanged];
                    }
                }
                break;

            }
            break;
        }
        case 1:
            switch (indexPath.row) {
                case 0:
                    cell = [tableView dequeueReusableCellWithIdentifier:@"Cell_LogOut"];
                    
                    if(cell==NULL){
                        [self reloadNib];
                        cell=Cell_LogOut;
                        Cell_LogOut=NULL;
                    }
                    if(cell != NULL){
                        lbl_LogOut = (UILabel*)[cell viewWithTag:7];
                        [lbl_LogOut setText:@" "];
                        lblDetail_LogOut = (UILabel*)[cell viewWithTag:8];
                        [lblDetail_LogOut setText:@" "];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        barBtn_Back = [[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(BackButtonPressed)];
                    }
                    if(cell != NULL && ([[AccountManager sharedAccountManager] bol_isRegistered] == NO || [[AccountManager sharedAccountManager] bol_isLogined] == NO)){
                        trackingOnOff.enabled = false;
                        backUpOnOff.enabled = false;
                        [trackingOnOff setOn:NO];
                        [self ToggleTracking:trackingOnOff];
                        [backUpOnOff setOn:NO];
                        [self ToggleBackUp:backUpOnOff];
                        lbl_LogOut.text = @"Login";
                        [lblDetail_LogOut setText:@"Login to enable Online Tracking Feature"];
                        self.navigationItem.leftBarButtonItem = NULL;
                    }
                    else
                    {
                        lbl_LogOut.text = [[AccountManager sharedAccountManager]str_Email];
                        [lblDetail_LogOut setText:@"LogOut to disable Online Tracking Feature"];
                        self.navigationItem.leftBarButtonItem = NULL;
                    }
                    break;
            }
            break;
            
        case 2: {
            cell = [tableView dequeueReusableCellWithIdentifier:@"nearby devices"];
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"nearby devices"];
            }
            
            cell.textLabel.text = @"Nearby Lost Devices";
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            [notificationView removeFromSuperview];
            notificationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
            notificationView.center = CGPointMake(270, 30);
            notificationView.backgroundColor = [UIColor redColor];
            [cell.contentView addSubview:notificationView];
            notificationView.layer.cornerRadius = 15;
            notificationView.alpha = 0;
            
            notificationLable = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 30, 30)];
            [notificationView addSubview:notificationLable];
        }
            break;
        default:
            break;
    }
    return cell;
    
}

#pragma mark - crowdtrackdelegate
- (void)updateNumberOfDevices:(int)numberofDevices{
    if (numberofDevices == 0) {
        notificationView.alpha = 0;
    }else{
        notificationView.alpha = 1;
        notificationLable.text = [NSString stringWithFormat:@"%d",numberofDevices];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Logout button
    if(indexPath.section == 0)
    {
        if(indexPath.row == 0 || indexPath.row == 1)
        {
            if(![trackingOnOff isEnabled] || ![backUpOnOff isEnabled])
                [[[UIAlertView alloc]initWithTitle:@"Information" message:@"Please Login/Register to access Mobile Functions" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil]show];
        }
        
    }
    else if (indexPath.section==1 && indexPath.row==0)
    {
        if([lbl_LogOut.text isEqualToString: @"Login"])
        {
            NSLog(@"Login");
            
            [[ViewController_SignUpAndSignIn sharedInstance]MobileView];
            [self.view addSubview:[[ViewController_SignUpAndSignIn sharedInstance]view]];
            self.navigationItem.leftBarButtonItem = self.barBtn_Back;
            if([[AccountManager sharedAccountManager] bol_isRegistered] == YES || [[AccountManager sharedAccountManager]str_RegID] != NULL)
            {
                trackingOnOff.enabled = true;
                backUpOnOff.enabled = true;
                [trackingOnOff setOn:YES];
                [self ToggleTracking:trackingOnOff];
                [backUpOnOff setOn:YES];
                [self ToggleBackUp:backUpOnOff];
            }
        }
        else
        {
            NSLog(@"Log out");
            
            UIAlertView *message = [[UIAlertView alloc]initWithTitle:@"Information" message:@"Are you sure you want to LogOut? Online Tracking Feature will be disabled" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
            [message setTag:20];
            [message show];
        }
    } else {
        // nearby devices
        NSLog(@"nearby devices");
        
        NearbyDevicesViewController *nb = [[NearbyDevicesViewController alloc] initWithNibName:@"NearbyDevicesViewController" bundle:nil];
        
        [self.navigationController pushViewController:nb animated:YES];
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    //Setting background color of cell
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
        cell.backgroundColor = [UIColor colorWithRed:.3 green:.3 blue:.3 alpha:.2];
    else
        cell.backgroundColor = [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:.4];
}

-(void)reloadNib{
    //Load the Nib for tableviewcells
    if([[[UIDevice currentDevice]systemVersion]floatValue] >= 7.0)
        [[[NSBundle mainBundle] loadNibNamed:@"Cells_Configurationios7" owner:self options:nil]objectAtIndex:0];
    else
        [[[NSBundle mainBundle] loadNibNamed:@"Cells_Configuration" owner:self options:nil]objectAtIndex:0];
}

-(void)ToggleTracking:(id)sender{
    if([sender isKindOfClass: [UISwitch class]]){
        NSLog(@"Toggle Tracking");
        trackingOnOff = (UISwitch*)sender;
        [[DataManager sharedInstance]setSettings_Tracking:[trackingOnOff isOn]];
        [[DataManager sharedInstance]save_Settings];
        if([trackingOnOff isOn])
        {
            [[GPSManager sharedInstance] StartTracking];
            if([[AccountManager sharedAccountManager]str_PushToken].length==0)
            {
                //Let device know we want to receive push notification
                [[UIApplication sharedApplication]registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound)];
            }else{
                [[AccountManager sharedAccountManager]updateServerPushToken:[[AccountManager sharedAccountManager]str_PushToken]];
            }
            //Set to perform background fetch every 10min
            [[UIApplication sharedApplication]setMinimumBackgroundFetchInterval:600];
        }
        else
        {
            [[GPSManager sharedInstance] StopTracking];
            [[AccountManager sharedAccountManager]clearServerPushToken];
            [[UIApplication sharedApplication]setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalNever];
        }
    }
}

- (void)ToggleCrowdTracking:(id)sender{
    UISwitch *switchToggle = (UISwitch *)sender;
    
    if(switchToggle.isOn){
        //start tracking
        NSLog(@"Crowd Track On");
        [[BlueToothBackgroundManager sharedInstance] enableBackgroundTracking];
        
    }else{
        //disable tracking
         NSLog(@"Crowd Track Off");
        [[BlueToothBackgroundManager sharedInstance] disableBackgroundTracking];
    }
}

-(void)ToggleBackUp:(id)sender{
    if([sender isKindOfClass: [UISwitch class]]){
        NSLog(@"Toggle BackUp");
        backUpOnOff = (UISwitch*)sender;
        [[DataManager sharedInstance]setSettings_Backup:[backUpOnOff isOn]];
        [[DataManager sharedInstance]save_Settings];
        if([backUpOnOff isOn])
        {
            if([[AccountManager sharedAccountManager]str_PushToken].length==0)
            {
                //Let device know we want to receive push notification
                [[UIApplication sharedApplication]registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound)];
            }else{
                [[AccountManager sharedAccountManager]updateServerPushToken:[[AccountManager sharedAccountManager]str_PushToken]];
            }
        }
        else{
            [[AccountManager sharedAccountManager]clearServerPushToken];
        }
        
    }
}

-(void)ToggleDeveloper:(id)sender{
    if([sender isKindOfClass: [UISwitch class]]){
        NSLog(@"Toggle Developer");
        developerOnOff = (UISwitch*)sender;
        [[AccountManager sharedAccountManager]setBol_isDeveloper:[developerOnOff isOn]];
        [[DataManager sharedInstance]save_Settings];
    }
}

-(void)refreshMobileTable{
    [MobileTable reloadData];
}

-(void)BackButtonPressed{
    for(UIView *subview in self.view.subviews)
    {
        if(subview.tag == 10)
            [subview removeFromSuperview];
    }
    [self reloadNib];
    [self refreshMobileTable];
    self.navigationItem.leftBarButtonItem = NULL;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag == 20)
    {
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        if([title isEqualToString:@"Yes"])
        {
            NSLog(@"Button LogOut was Pressed");
            [[AccountManager sharedAccountManager]userLogout];
            
            //Set all settings to false
#warning because toggling tracking off will update empty push token on server, signing out will also send empty push token on server which results in "unable to perform task" error on server when trying to get the location. The way to solve this is to check if user is logined before clearing the pushToken. However that does not make sense as well because people can just toggle it off instead of logout
            [trackingOnOff setOn:NO];
            [self ToggleTracking:trackingOnOff];
            [backUpOnOff setOn:NO];
            [self ToggleBackUp:backUpOnOff];
            trackingOnOff.enabled = false;
            backUpOnOff.enabled = false;
            lbl_LogOut.text = @"Login";
        }
    }
}

@end
