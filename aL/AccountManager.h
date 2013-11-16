#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Protag_Device.h"

@interface AccountManager : NSObject{
    NSTimer *timer_Timeout;
}

@property (nonatomic,copy) NSString* str_RegID;
@property (nonatomic,copy) NSString* str_UserID;
@property (nonatomic,copy) NSString* str_Email;
@property (nonatomic,copy) NSString* str_PushToken;
@property (nonatomic) BOOL bol_isRegistered;
@property (nonatomic) BOOL bol_isLogined;
@property (nonatomic) BOOL bol_isMissing;
@property (nonatomic) BOOL bol_isDeveloper;
//@property (nonatomic) BOOL isUserRadarOn;
@property (nonatomic) CLLocationAccuracy user_Accuracy; //this accuracy is set by user
@property (nonatomic) NSTimeInterval interval_PreviousPoll;

+(AccountManager *)sharedAccountManager;

-(void)userRegisterWithInfo:(NSDictionary *)userInfo;

-(void)userLoginWithInfo:(NSDictionary *)userInfo;

-(void)userLogout;

-(void)updateServerPushToken:(NSString*)Token;

-(void)clearServerPushToken;

-(void)syncProtag:(Protag_Device*)device;

-(NSString*)getCurrentDate;

-(BOOL)hasInternetConnection;

-(void)checkBackgroundAppRefresh;

-(void)pollServerForActions;

@end