//
//  DeviceDetailsViewController.h
//  PROTAG
//
//  Created by cc on 14/10/13.
//
//

#import <UIKit/UIKit.h>
#import "CrowdTrackLostItem.h"

@interface DeviceDetailsViewController : UIViewController

@property (nonatomic) CrowdTrackLostItem *lostItem;
@property (nonatomic) IBOutlet UITextView *descriptionTextView;
@property (nonatomic) IBOutlet UITextView *messageTextView;
@property (nonatomic) IBOutlet UIButton *radarButton;
@property (nonatomic) IBOutlet UIButton *callButton;
@property (nonatomic) IBOutlet UIButton *smsButton;

- (IBAction)radarButtonDidClicked:(id)sender;
- (IBAction)contactButtonDidClicked:(id)sender;
- (IBAction)smsButtonClicked:(id)sender;

@end
