//
//  BlueToothBackgroundManager.h
//  PROTAG
//
//  Created by Sai on 10/11/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface BlueToothBackgroundManager : NSObject

@property BOOL isCrowdTrackingEnabled;

+ (id)  sharedInstance;
-(void) enableBackgroundTracking;
-(void) disableBackgroundTracking;

@end
