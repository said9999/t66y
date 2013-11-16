//
//  DeviceDetailsViewController.m
//  PROTAG
//
//  Created by cc on 14/10/13.
//
//

#import "DeviceDetailsViewController.h"
#import "ViewController_Radar.h"
#import "CrowdTrackManager.h"

@interface DeviceDetailsViewController ()

@end

@implementation DeviceDetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.descriptionTextView.text = self.lostItem.description;
    
    NSString *msg = [@"Message: " stringByAppendingString:self.lostItem.message];
    self.messageTextView.text = msg;
    
    self.descriptionTextView.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0];
    self.descriptionTextView.textColor = [UIColor whiteColor];
    self.messageTextView.textColor = [UIColor whiteColor];
    self.messageTextView.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0];
    [self.radarButton setImage:[UIImage imageNamed:@"magnifier.png"] forState:UIControlStateNormal];
    [self.callButton setImage:[UIImage imageNamed:@"phone.png"] forState:UIControlStateNormal];
}

- (void)radarButtonDidClicked:(id)sender
{
    NSLog(@"radar!!");
    //NSLog(@"%@", self.lostItem.peripheral);
    //NSLog(@"%@", self.lostItem.macAdress);
    Protag_Device *device = [[Protag_Device alloc] init_WithPeripheral:self.lostItem.peripheral andMAC:self.lostItem.macAdress];
    ViewController_Radar *r = [[ViewController_Radar alloc] init];
    [self.navigationController pushViewController:r animated:YES];
    [r setRadarDevice:device];
}

- (IBAction)contactButtonDidClicked:(id)sender {
    UIApplication *app = [UIApplication sharedApplication];
    NSLog(@"clicked");
    NSString *urlStr = [@"tel://" stringByAppendingString:self.lostItem.contactNo];
    NSURL *callUrl = [NSURL URLWithString:urlStr];
    [app openURL:callUrl];
}

@end
