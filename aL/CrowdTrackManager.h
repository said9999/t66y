//
//  CrowdTrackManager.h
//  PROTAG
//
//  Created by Sai on 10/11/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface CrowdTrackManager : NSObject

@property NSDate *latestUpdateTime;

+ (id)sharedInstance;

//+ (void)retrieveInfoWith:(NSString *)macAddress;

- (void)retrieveInfoWith:(NSString *)macAddress peripheral:(CBPeripheral *)peripheral;

- (NSArray *)retrieveLostItemList;

@end
