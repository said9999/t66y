//
//  BackupContactsController.h
//  aL
//
//  Created by Pham Minh Viet on 17/5/13.
//
//

#import <Foundation/Foundation.h>

@interface BackupContactsManager : NSObject
+(id)sharedInstance;
-(NSString *)backupContacts;
-(void)sendContactsToServer;

@end
