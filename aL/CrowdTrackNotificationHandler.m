//
//  CrowdTrackNotificationHandler.m
//  PROTAG
//
//  Created by Sai on 11/8/13.
//
//

#import "CrowdTrackNotificationHandler.h"

@interface CrowdTrackNotificationHandler(){
    NSMutableSet *notifiedDevices;//new detected devices that need to be notifed
    NSMutableSet *newDevices; //devices haven't been open in radar page
}
@end


@implementation CrowdTrackNotificationHandler
static CrowdTrackNotificationHandler *instance;

+ (CrowdTrackNotificationHandler *)sharedInstance{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (id)init{
    self = [super init];
    if(self){
        notifiedDevices = [NSMutableSet set];
        newDevices = [NSMutableSet set];
    }
    
    return self;
}

- (void)addNewDetectLostItem:(CrowdTrackLostItem *)lostItem{
    NSString *mac_ad = lostItem.macAdress;
    
    [self.delegate updateNumberOfDevices:[notifiedDevices count]+1];
    [self pushLocalNotificationWithLostItem:lostItem];
    [newDevices addObject:mac_ad];
    [notifiedDevices addObject:mac_ad];
}

- (void)clearDevicesList{
    notifiedDevices = nil;
    notifiedDevices = [NSMutableSet set];
    [self.delegate updateNumberOfDevices:[notifiedDevices count]];
}

- (void)Register:(id)observer{
    self.delegate = observer;
    [self.delegate updateNumberOfDevices:[notifiedDevices count]];
}

- (void)pushLocalNotificationWithLostItem:(CrowdTrackLostItem *)lostItem{
    if ([notifiedDevices containsObject:lostItem.macAdress]) {//has notified before, then no need to notify again
        return;
    }
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [[NSDate date] dateByAddingTimeInterval:1];
    notification.alertBody = @"You've found a lost item";
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

- (BOOL)isNewDevice:(CrowdTrackLostItem *)lostItem{
    return [newDevices containsObject:lostItem.macAdress];
}

- (void)removeNewDevice:(CrowdTrackLostItem *)lostItem{
    if ([newDevices containsObject:lostItem.macAdress]) {
        [newDevices removeObject:lostItem.macAdress];
    }
}
@end
