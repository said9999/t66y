//
//  CrowdTrackLostItem.h
//  PROTAG
//
//  Created by Sai on 10/16/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@class CrowdTrackLostItem;

@interface CrowdTrackLostItem : NSObject

@property (nonatomic) NSDate * lastUpdateDate;
@property (nonatomic) NSString * itemName;
@property (nonatomic) NSString * macAdress;
@property (nonatomic) NSString * userId;
@property (nonatomic) NSString * description;
@property (nonatomic) NSString * contactNo;
@property (nonatomic) NSString * message;
@property (nonatomic) CBPeripheral *peripheral;
@property (nonatomic) BOOL isPrivate;

@end
