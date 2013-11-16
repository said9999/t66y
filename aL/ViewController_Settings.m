#import "ViewController_Settings.h"
#import "Alarm.h"
#import "DataManager.h"
#import "WifiDetector.h"

@interface ViewController_Settings ()

@end

@implementation ViewController_Settings

@synthesize Cell_VibrationOnOff;
@synthesize Cell_SoundOnOff;
@synthesize Cell_Ringtone;
@synthesize Cell_SecureWiFi;
@synthesize Cell_Geofencing;
@synthesize Cell_About;


-(void)viewDidLoad{
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
    [tableView setRowHeight:45];
    
    [tableView setShowsHorizontalScrollIndicator:false];
    [tableView setShowsVerticalScrollIndicator:true];
    
    self.title = @"Settings";
    
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
        self.navigationController.navigationBar.titleTextAttributes = @{UITextAttributeTextColor : [UIColor whiteColor]};
    }
    
    [BackGroundView setFrame:self.view.frame];
    [tableView setFrame:self.view.frame];
    
     _RingtoneController = [[ViewController_Ringtone alloc]init];
    _WifiController = [[ViewController_Wifi alloc]init];
    _GeofencingController = [[ViewController_Geofencing alloc]init];
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return 3; // vibration,sound Alarm, Ringtone
            break;
        case 1: //Secure Zone
        case 2: //About
            return 1;
            break;
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    switch (indexPath.section) {
        case 0:{
            switch (indexPath.row) {
                case 0:{
                    cell = [tableView dequeueReusableCellWithIdentifier:@"Cell_VibrationOnOff"];
                
                    if(cell==NULL){
                        [self reloadNib];
                        cell=Cell_VibrationOnOff;
                        Cell_VibrationOnOff=NULL;
                    }
        
                    if(cell!=NULL)
                    {
                        UILabel *lbl_VibrationOnOff = (UILabel*)[cell viewWithTag:1];
                        UISwitch *_Switch = (UISwitch*)[cell viewWithTag:2];
                        [lbl_VibrationOnOff setText:@"Vibration"];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        [_Switch setOn:[[DataManager sharedInstance]Settings_Vibration]];
                        [_Switch addTarget:self action:@selector(ToggleVibration:) forControlEvents:UIControlEventValueChanged];
                    }
                }
                break;
                case 1:{
                        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell_SoundOnOff"];
                        
                        if(cell==NULL){
                            [self reloadNib];
                            cell=Cell_SoundOnOff;
                            Cell_SoundOnOff=NULL;
                        }
                        
                        if(cell!=NULL)
                        {
                            UILabel *lbl_SoundOnOff = (UILabel*)[cell viewWithTag:3];
                            UISwitch *_Switch = (UISwitch*)[cell viewWithTag:4];
                            [lbl_SoundOnOff setText:@"Sound Alarm"];
                            cell.selectionStyle = UITableViewCellSelectionStyleNone;
                            [_Switch setOn:[[DataManager sharedInstance]Settings_Music]];
                            [_Switch addTarget:self action:@selector(ToggleMusic:) forControlEvents:UIControlEventValueChanged];
                        }
                }
                break;
                case 2:
                        //For Other Settings
                        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell_Ringtone"];
                        
                        if(cell==NULL){
                            [self reloadNib];
                            cell=Cell_Ringtone;
                            Cell_Ringtone=NULL;
                        }
                        if(cell != NULL)
                        {
                            UILabel *lbl_Ringtone = (UILabel*)[cell viewWithTag:9];
                            [lbl_Ringtone setText:@"Select Ringtone"];
                        }
                break;
            }
            break;
        }
        case 1:
            switch (indexPath.row) {
                case 0:
                    cell = [tableView dequeueReusableCellWithIdentifier:@"Cell_Geofencing"];
                    
                    if(cell==NULL){
                        [self reloadNib];
                        cell=Cell_Geofencing;
                        Cell_Geofencing=NULL;
                    }
                    if(cell != NULL){
                        UILabel *lbl_Geofencing = (UILabel*)[cell viewWithTag:6];
                        [lbl_Geofencing setText:@"Secure Geofencing"];
                    }
                    break;
            }
            break;
        case 2:{
            switch(indexPath.row){
                case 0:
                    cell = [tableView dequeueReusableCellWithIdentifier:@"Cell_About"];
                
                    if(cell==NULL){
                        [self reloadNib];
                        cell=Cell_About;
                        Cell_About=NULL;
                    }
                    if(cell != NULL){
                        UILabel *lbl_About = (UILabel*)[cell viewWithTag:7];
                        [lbl_About setText:@"About"];
                    }
                    break;
            }
            break;
        }
        default:
            break;
    }
    return cell;
            
}

-(void)reloadNib{
    //Load the Nib for tableviewcells
    if([[[UIDevice currentDevice]systemVersion]floatValue] >=7.0)
        [[[NSBundle mainBundle] loadNibNamed:@"Cells_Settingsios7" owner:self options:nil]objectAtIndex:0];
    else
        [[[NSBundle mainBundle] loadNibNamed:@"Cells_Settings" owner:self options:nil]objectAtIndex:0];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 2:
                    //Select ringtone
                    [Cell_Ringtone setSelected:false];
                    [self.navigationController pushViewController:_RingtoneController animated:true];
                    break;
                default:
                    break;
            }
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                    //Secure Geofencing
                    [Cell_Geofencing setSelected:false];
                    [self.navigationController pushViewController:_GeofencingController animated:true];
                    break;
                default:
                    break;
            }
            break;

        case 2:
            switch (indexPath.row) {
                case 0:
                    //About
                    #warning to change this next time. Not done by MK, by Suarap I think
                    [Cell_About setSelected:false];
                    if([[[UIDevice currentDevice]systemVersion]floatValue] >= 7.0){
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Innova Technology" message:@"http://www.innovatechnology.com.sg/\n Version:2.0" delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil, nil];
                        [alertView show];
                    }
                    else
                    {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"\n\n\n\n\n" delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil, nil];
                    
                        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"innovaLogo.png"]];
                        [imageView setFrame:CGRectMake(20, 20, 70, 50)];
                        [alertView addSubview:imageView];
                    
                        UILabel *companyNamelabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 20, 150, 50)];
                        [companyNamelabel setTextColor:[UIColor whiteColor]];
                        [companyNamelabel setFont:[UIFont boldSystemFontOfSize:16]];
                        [companyNamelabel setText:@"Innova Technology"];
                        [companyNamelabel setBackgroundColor:[UIColor clearColor]];
                        [alertView addSubview:companyNamelabel];
                    
                        UITextView *contentTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, 75, 260, 40)];
                        [contentTextView setEditable:FALSE];
                        [contentTextView setTextColor:[UIColor whiteColor]];
                        [contentTextView setFont:[UIFont systemFontOfSize:14]];
                        contentTextView.contentMode = UIViewAutoresizingFlexibleWidth;
                        [contentTextView setBackgroundColor:[UIColor clearColor]];
                        [contentTextView setClipsToBounds:TRUE];
                        [contentTextView setTextAlignment:NSTextAlignmentCenter];
                        contentTextView.dataDetectorTypes = UIDataDetectorTypeLink;
                        [contentTextView setText:@"http://www.innovatechnology.com.sg/\n Version:2.0"];
                        [alertView addSubview:contentTextView];
                    
                        [alertView show];
                    }
                    break;
            }
            break;
        default:
            break;
    }

    
    [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    //Setting background color of cell
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
        cell.backgroundColor = [UIColor colorWithRed:.3 green:.3 blue:.3 alpha:.2];
    else
        cell.backgroundColor = [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:.4];
}

-(void)ToggleVibration:(id)sender{
    if([sender isKindOfClass: [UISwitch class]]){
        NSLog(@"Toggle Vibration");
        UISwitch *_Switch = (UISwitch*)sender;
        [[DataManager sharedInstance]setSettings_Vibration:[_Switch isOn]];
    }
}

-(void)ToggleMusic:(id)sender{
    if([sender isKindOfClass: [UISwitch class]]){
        NSLog(@"Toggle Music");
        UISwitch *_Switch = (UISwitch*)sender;
        [[DataManager sharedInstance]setSettings_Music:[_Switch isOn]];
    }
}

@end
