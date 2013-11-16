#import "ViewController_Ringtone.h"
#import "Alarm.h"
#import "RingtoneManager.h"

@interface ViewController_Ringtone()

@end

@implementation ViewController_Ringtone

@synthesize Cell_Ringtone;

-(void)viewDidLoad{
    [super viewDidLoad];
    //Load the Nib for tableviewcells
    [[[NSBundle mainBundle] loadNibNamed:@"Cells_Ringtone" owner:self options:nil]objectAtIndex:0];
    
    UIImageView *BackGroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"background.png"]];
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    
    tableView.opaque = NO;
    tableView.backgroundView = nil;
    
    [tableView setDataSource:self];
    [tableView setDelegate:self];
    
    [tableView setBackgroundColor:[UIColor clearColor]];
    [tableView setSectionFooterHeight:10];
    [tableView setSectionHeaderHeight:10];
    [tableView setSeparatorColor:[UIColor darkGrayColor]];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    BackGroundView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    tableView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    self.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    [self.view setAutoresizesSubviews:true];
    
    self.title = @"Ringtone";
    
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
}

-(void)reloadNib{
    //Load the Nib for tableviewcells
    [[[NSBundle mainBundle] loadNibNamed:@"Cells_Ringtone" owner:self options:nil]objectAtIndex:0];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[Alarm sharedInstance]Stop_MusicOnly];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //10 ringtones
    return 10;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell_Ringtone"];
    if(cell==NULL){
        [self reloadNib];
        cell = Cell_Ringtone;
        Cell_Ringtone = NULL;
    }
    
    if(cell!=NULL)
    {
        UILabel *lbl_ringtone = (UILabel*)[cell viewWithTag:1];
        UIImageView *img_arrow = (UIImageView*)[cell viewWithTag:2];
        
        //set color of arrow for selection
        if(indexPath.row == [[RingtoneManager sharedInstance]get_ToneInt])
            [img_arrow setAlpha:1];
        else
            [img_arrow setAlpha:0.3];
        
        //please build table according to ringtone enum placement
        switch(indexPath.row){
            case 0:
                [lbl_ringtone setText:@"Default"];
                break;
            case 1:
                [lbl_ringtone setText:@"Ringer"];
                break;
            case 2:
                [lbl_ringtone setText:@"Hi-Low"];
                break;
            case 3:
                [lbl_ringtone setText:@"Kitten"];
                break;
            case 4:
                [lbl_ringtone setText:@"Sweet"];
                break;
            case 5:
                [lbl_ringtone setText:@"Bell"];
                break;
            case 6:
                [lbl_ringtone setText:@"Digital"];
                break;
            case 7:
                [lbl_ringtone setText:@"Siren"];
                break;
            case 8:
                [lbl_ringtone setText:@"Tingling"];
                break;
            case 9:
                [lbl_ringtone setText:@"Beep"];
                break;
            case 10:
                [lbl_ringtone setText:@"Sweep"];
                break;
        }
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    //do nothing
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row!=[[RingtoneManager sharedInstance]get_ToneInt])
    {
        [[RingtoneManager sharedInstance]set_Tone:indexPath.row];
        [[Alarm sharedInstance]Play_Music:indexPath.row];
    }
    else
        [[Alarm sharedInstance]Stop_MusicOnly];
    
    [tableView reloadData];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //Setting background color of cell
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
        cell.backgroundColor = [UIColor colorWithRed:.3 green:.3 blue:.3 alpha:.2];
    else
        cell.backgroundColor = [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:.4];
}

@end
