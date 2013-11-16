//
//  CrowdTrackNotificationHandler.h
//  PROTAG
//
//  Created by Sai on 11/8/13.
//
//

#import <Foundation/Foundation.h>
#import "CrowdTrackLostItem.h"

@protocol CrowdTrackNotificationDelegate <NSObject>

- (void)updateNumberOfDevices:(int)numberofDevices;
@end

@class CrowdTrackNotificationHandler;

@interface CrowdTrackNotificationHandler : NSObject

@property (weak,nonatomic) id<CrowdTrackNotificationDelegate> delegate;

+ (CrowdTrackNotificationHandler *)sharedInstance;

- (void)Register:(id)observer;

- (void)addNewDetectLostItem:(CrowdTrackLostItem *)lostItem;
- (void)clearDevicesList;

- (BOOL)isNewDevice:(CrowdTrackLostItem *)lostItem;
- (void)removeNewDevice:(CrowdTrackLostItem *)lostItem;

@end
