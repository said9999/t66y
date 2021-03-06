//
//  NearbyDevicesViewController.m
//  PROTAG
//
//  Created by cc on 13/10/13.
//
//

#import "NearbyDevicesViewController.h"
#import "DeviceDetailsViewController.h"
#import "CrowdTrackManager.h"
#import "CrowdTrackLostItem.h"
#import "CrowdTrackNotificationHandler.h"
#import "NearbyLostDevicesCell.h"



@interface NearbyDevicesViewController (){
    NSMutableDictionary * notificationLableAndLostItem;
}
@end

@implementation NearbyDevicesViewController
static NSMutableSet *trashBin;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.view.backgroundColor = [UIColor blackColor];
        //self.nearbyDevices = [NSMutableArray arrayWithObjects:@"test1", @"teset2", @"test3", nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (!trashBin) {
        trashBin = [NSMutableSet set];
    }
    notificationLableAndLostItem = [NSMutableDictionary dictionary];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"Pull to Refresh"];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.tableHeaderView = [UIView new];
    self.nearbyDevices = [self filterLostItems:[[CrowdTrackManager sharedInstance] retrieveLostItemList]];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //clear notification in configuration page
    [[CrowdTrackNotificationHandler sharedInstance] clearDevicesList];
    [self.tableView reloadData];


}

- (void)refresh:(id)sender
{
    __weak UIRefreshControl *refreshControl = (UIRefreshControl *)sender;
    if(refreshControl.refreshing) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // refresh here
            [self filterLostItems:[[CrowdTrackManager sharedInstance] retrieveLostItemList]];
            //NSLog(@"refrehing");
            dispatch_sync(dispatch_get_main_queue(), ^{
                [refreshControl endRefreshing];
                //reload the table here
                self.nearbyDevices = [self filterLostItems:[[CrowdTrackManager sharedInstance] retrieveLostItemList]];
                [[CrowdTrackNotificationHandler sharedInstance] clearDevicesList];
                [self.tableView reloadData];
                NSLog(@"refrehing");
            });
        });
    }
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.nearbyDevices count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"NearbyLostDevicesCell";
    NearbyLostDevicesCell *customizedCell = (NearbyLostDevicesCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (customizedCell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"NearbyLostDevicesCell" owner:nil options:nil];
        customizedCell = [nib objectAtIndex:0];
    }
    
    CrowdTrackLostItem *lostItem = (CrowdTrackLostItem *)[self.nearbyDevices objectAtIndex:indexPath.row];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(252, 79, 50, 20)];
    label.textColor = [UIColor redColor];
    label.text = @"New";
    
    [customizedCell.contentView addSubview:label];
    if ([[CrowdTrackNotificationHandler sharedInstance] isNewDevice:lostItem]) {
        [notificationLableAndLostItem setObject:label forKey:lostItem.macAdress];
        label.alpha = 1;
    }else{
        label.alpha = 0;
    }
    
    customizedCell.itemNameLabel.text = lostItem.itemName;
    NSDateFormatter *f = [NSDateFormatter new];
    f.dateStyle = NSDateFormatterShortStyle;
    customizedCell.lostTimeLabel.text = [f stringFromDate:lostItem.lastUpdateDate];
    customizedCell.timePastLabel.text = [NSString stringWithFormat:@"%d mins ago", (int)[lostItem.lastUpdateDate timeIntervalSinceNow] / -60];
   
    return customizedCell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    //Setting background color of cell
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
        cell.backgroundColor = [UIColor colorWithRed:.3 green:.3 blue:.3 alpha:.2];
    else
        cell.backgroundColor = [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:.4];
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 105;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DeviceDetailsViewController *detailViewController = [[DeviceDetailsViewController alloc] initWithNibName:@"DeviceDetailsViewController" bundle:nil];
    detailViewController.lostItem = [self.nearbyDevices objectAtIndex:indexPath.row];

    //not new device anymore
    [[CrowdTrackNotificationHandler sharedInstance] removeNewDevice:detailViewController.lostItem];
    UILabel *newLabel = [notificationLableAndLostItem objectForKey:detailViewController.lostItem.macAdress];
    newLabel.alpha = 0;
    
    [self.navigationController pushViewController:detailViewController animated:YES];
}

#pragma mark - private methods
- (NSArray *)filterLostItems:(NSArray *)input{
    NSMutableArray *result = [NSMutableArray array];
    
    for (CrowdTrackLostItem *item in input) {
        if (![trashBin containsObject:item]) {//no need to show item in trash bin
            [result addObject:item];
        }
    }
    
    return result;
}

@end
