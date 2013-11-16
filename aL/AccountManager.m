#import "AccountManager.h"
#import "PopUp_Processing.h"
#import <CoreLocation/CoreLocation.h>
#import "DataManager.h"
#import "HTTPClient.h"
#import "GPSManager.h"
#import "CameraManager.h"
#import "BackupContactsManager.h"
#include <SystemConfiguration/SCNetworkReachability.h>

@interface AccountManager()

@end

@implementation AccountManager

@synthesize str_Email;
@synthesize str_RegID;
@synthesize str_UserID;
@synthesize str_PushToken;
@synthesize bol_isLogined;
@synthesize bol_isMissing;
@synthesize bol_isRegistered;
@synthesize bol_isDeveloper;
@synthesize user_Accuracy;
@synthesize interval_PreviousPoll;

- (id)init {
    if (self = [super init]) {
        str_Email = @"";
        str_RegID = @"";
        str_UserID = @"";
        str_PushToken = @"";
        bol_isLogined = false;
        bol_isMissing = false;
        bol_isDeveloper = false;
        bol_isRegistered = false;
        
        user_Accuracy = kCLLocationAccuracyHundredMeters;
        timer_Timeout = NULL;
        interval_PreviousPoll = 0;
	}
    return self;
}

+ (AccountManager *)sharedAccountManager {
    static dispatch_once_t pred;
    static AccountManager *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[AccountManager alloc] init];
    });
    return sharedInstance;
}

-(void)userLoginWithInfo:(NSDictionary *)userInfo{
	[[HTTPClient sharedHTTPClient] queryServerPath:@"phoneDataReceive.php" parameters:userInfo success:^(id jsonObject) {
        if(![jsonObject isKindOfClass:[NSDictionary class]]){
			return;
		}
        NSDictionary *status = [jsonObject objectForKey:@"status"];
		NSString *statusCode = [status objectForKey:@"code"];
        int int_StatusCode = [statusCode intValue];
        
        if(int_StatusCode == 200){
            //success
             NSDictionary *data = [jsonObject objectForKey:@"data"];
             NSString *userID = [data objectForKey:@"userID"];
             str_RegID = [[UIDevice currentDevice] identifierForVendor].UUIDString;
             str_Email = [userInfo objectForKey:@"email"];
             str_UserID = userID;
             bol_isLogined=false;
             bol_isMissing=false;
             user_Accuracy=kCLLocationAccuracyHundredMeters;
             
             [[DataManager sharedInstance]save_Account];
             //Proceed to send phone parameters before login is success
             [self sendPhoneParameters];
           }else if(int_StatusCode == 100){
            //failure
             NSDictionary *message = [jsonObject objectForKey:@"message"];
             NSString *messageCode = [message objectForKey:@"code"];
             int int_MessageCode = [messageCode intValue];
             
             switch(int_MessageCode){
                case 119:
                [[[UIAlertView alloc] initWithTitle:@"Login Failed" message:@"Username and Password do not match, please try again" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"loginFailed" object:nil];
                break;
                case 118:
                [[[UIAlertView alloc] initWithTitle:@"Login Failed" message:@"Account has not been activated yet. Please activate your email" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"loginFailed" object:nil];
                break;
                case 105:
                [[[UIAlertView alloc] initWithTitle:@"Login Failed" message:@"User does not exist, please try registering" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"loginFailed" object:nil];
                break;
                 default:
                 //Show error when this happens
                 break;
             }
        }
	} failure:^(NSError *error) {
		[[[UIAlertView alloc] initWithTitle:@"Opps" message:@"Server is busy, please try again later" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"loginFailed" object:nil];
		}];
}

- (void)userRegisterWithInfo:(NSDictionary *)userInfo{
	[[HTTPClient sharedHTTPClient] queryServerPath:@"phoneDataReceive.php" parameters:userInfo success:^(id jsonObject) {
        NSLog(@"Received: %@",jsonObject);
		if(![jsonObject isKindOfClass:[NSDictionary class]]){
            return;
        }
        NSDictionary *status = [jsonObject objectForKey:@"status"];
		NSString *statusCode = [status objectForKey:@"code"];
        int int_StatusCode = [statusCode intValue];
				
		if(int_StatusCode == 200){
            str_Email = [userInfo objectForKey:@"email"];
            bol_isRegistered=true;
            bol_isMissing=false;
            user_Accuracy=kCLLocationAccuracyHundredMeters;
            
            [[DataManager sharedInstance]save_Account];
          	[[NSNotificationCenter defaultCenter] postNotificationName:@"registerSucceed" object:nil];
  		}else if(int_StatusCode == 100){
            //failure
             NSDictionary *message = [jsonObject objectForKey:@"message"];
             NSString *messageCode = [message objectForKey:@"code"];
             int int_MessageCode = [messageCode intValue];

             if(int_MessageCode == 101)
                 [[NSNotificationCenter defaultCenter] postNotificationName:@"registerFail" object:nil];
        }
    } failure:^(NSError *error) {
		NSLog(@"Failed to Register!: %@",[error description]);
        [[[UIAlertView alloc] initWithTitle:@"Opps" message:@"Server is busy, please try again later" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        [[PopUp_Processing sharedInstance]dismissView];
	}];    
}

- (void)userLogout {
    str_Email = @"";
    str_RegID = [[UIDevice currentDevice] identifierForVendor].UUIDString;
    str_UserID = @"";
    bol_isLogined = false;
    bol_isMissing = false;
    bol_isRegistered = false;
    user_Accuracy = kCLLocationAccuracyHundredMeters;

    [[DataManager sharedInstance]save_Account];
}

//Push Notification Data
-(void)updateServerPushToken:(NSString*)Token{
    if(Token==NULL)
        return;
    
    //Remove the <> and empty space
    Token = [Token stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    Token = [Token stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if(Token.length!=0){
        str_PushToken = Token;
    }
    
    NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:@"sendiOSNotiToken",@"action",str_RegID,@"regID",Token,@"iOSNotiToken",nil];
    
    [[HTTPClient sharedHTTPClient] queryServerPath:@"phoneDataReceive.php" parameters:userInfo success:^(id jsonObject) {
		NSDictionary *status;
		//NSDictionary *message;
		if([jsonObject isKindOfClass:[NSDictionary class]]){
			status = [jsonObject objectForKey:@"status"];
		//	message = [jsonObject objectForKey:@"message"];
		}
		
		NSString *statusString = [status objectForKey:@"status"];
		NSString *statusCode = [status objectForKey:@"code"];
		        
		if([statusString isEqualToString:@"success"] && [statusCode intValue] == 200){
            NSLog(@"Notification Token Send succeed");
		}else if([statusString isEqualToString:@"fail"] && [statusCode intValue] == 100){
            NSLog(@"Notification Token Send failed");
			return;
        }
		
	} failure:^(NSError *error) {
        NSLog(@"Notification Token Send failed");
    }];
}

-(void)sendPhoneParameters{
    NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:@"sendRegID",@"action",[self str_RegID],@"regID",@"iOS",@"typePhone",[self str_UserID],@"userID",[[AccountManager sharedAccountManager]getCurrentDate],@"dateCreate",nil];

	[[HTTPClient sharedHTTPClient] queryServerPath:@"phoneDataReceive.php" parameters:userInfo success:^(id jsonObject) {
        NSLog(@"Received: %@",jsonObject);
		if(![jsonObject isKindOfClass:[NSDictionary class]]){
            return;
        }
        NSDictionary *status = [jsonObject objectForKey:@"status"];
		NSString *statusCode = [status objectForKey:@"code"];
        int int_StatusCode = [statusCode intValue];
        
		if(int_StatusCode == 200){
            bol_isLogined=true;
            bol_isRegistered=true;
            [[DataManager sharedInstance]save_Account];
            
            //Ask for permission for notification
            [[UIApplication sharedApplication]registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound)];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"loginSucceeded" object:nil];
  		}else if(int_StatusCode == 100){
            //failure
             NSDictionary *message = [jsonObject objectForKey:@"message"];
             NSString *messageCode = [message objectForKey:@"code"];
             int int_MessageCode = [messageCode intValue];
             
             if(int_MessageCode == 102){
                [[[UIAlertView alloc] initWithTitle:@"Login Failed" message:@"Phone has already been registered" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"loginFailed" object:nil];
             }else{
                 //show Error when this happens
             }
		}else{
            //Show error when this happens
        }
	} failure:^(NSError *error) {
		NSLog(@"Failed to Register!: %@",[error description]);
        [[[UIAlertView alloc] initWithTitle:@"Opps" message:@"Server is busy, please try again later" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
	}];
}

-(void)syncProtag:(Protag_Device*)device{
    CLLocation *lastLocation = [[GPSManager sharedInstance] latestLocation];
     NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:@"protagCardApply",@"action",str_UserID,@"userID",[device str_Name],@"protagName",device.str_MAC,@"macAddress",[NSNumber numberWithDouble:lastLocation.coordinate.latitude],@"latitude",[NSNumber numberWithDouble:lastLocation.coordinate.longitude],@"longitude",[self getCurrentDate],@"lastDateKnown",device.str_DateLost,@"dateCreate",nil];
    
    NSLog(@"Syncing Protag: %@",userInfo);
    
    [[HTTPClient sharedHTTPClient] queryServerPath:@"protagApplication.php" parameters:userInfo success:^(id jsonObject) {
        NSLog(@"%@ Sync success",[device str_Name]);
        //Server does not reply success or fail message
	} failure:^(NSError *error) {
        NSLog(@"%@ Sync failed",[device str_Name]);
    }];
}

-(NSString*)getCurrentDate{
    //Used for dateCreate
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	return [formatter stringFromDate:[NSDate date]];
}

-(BOOL)hasInternetConnection{
    Boolean success;
    const char *host_name = "www.innovatechnology.com.sg";
    
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, host_name);
    SCNetworkReachabilityFlags flags;
    success = SCNetworkReachabilityGetFlags(reachability, &flags);
    success = success && (flags & kSCNetworkFlagsReachable) && !(flags & kSCNetworkFlagsConnectionRequired);
    CFRelease(reachability);
    return success;
}

-(void)clearServerPushToken{
    [self updateServerPushToken:@""];
}

-(void)checkBackgroundAppRefresh{
     if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
        if ([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusAvailable)
        {
            NSLog(@"Background updates are available");
        }else{
            NSLog(@"Background updates not available");
        }
     }else{
         NSLog(@"Not iOS 7, can just do background updates");
     }
}

-(void)pollServerForActions{
    if(bol_isLogined && bol_isRegistered){
        
        //Only poll the server between intervals of 10min so that it does not overload the server
        if([NSDate timeIntervalSinceReferenceDate]-interval_PreviousPoll<600){
            return;
        }
        
		HTTPClient *client = [HTTPClient sharedHTTPClient];
		[client getDeviceInfo:[[AccountManager sharedAccountManager] str_RegID] success:^(id jsonObject) {
            
            interval_PreviousPoll = [NSDate timeIntervalSinceReferenceDate];
            
			if(![jsonObject isKindOfClass:[NSDictionary class]]){
				return;
			}
			DLog(@"%@",jsonObject);
			
			NSDictionary *status = [jsonObject objectForKey:@"status"];
			NSString *statusString = [status objectForKey:@"status"];
			NSString *statusCode = [status objectForKey:@"code"];
			
			if([statusString isEqualToString:@"success"] &&  [statusCode intValue] == 200){
				
				NSDictionary *data = [jsonObject objectForKey:@"data"];
				int track = [[data objectForKey:@"track"] intValue];
				if(track == 0){
					//If device is not missing, but server tell that it is missing, enable all location sensors
                    if(bol_isMissing == NO){
                        user_Accuracy = kCLLocationAccuracyBest;
                        bol_isMissing = true;
                        //optimize track will turn on precise GPS if bol_isMissing is true
                        [[GPSManager sharedInstance] optimizeTrack];
                    }
					
				}else if (track == 1 || track == 2){
                    bol_isMissing = false;
                    [[GPSManager sharedInstance]optimizeTrack];
				}
                
                int backup = [[data objectForKey:@"bContact"]intValue];
                DLog(@"Backup: %d",backup);
                if(backup == 0 && [[DataManager sharedInstance] Settings_Backup]) {
 					[[BackupContactsManager sharedInstance] sendContactsToServer];
                }
                
				int imageCapture = [[data objectForKey:@"imageCapture"]intValue];
				if(imageCapture == 0){
                    //0 means initiated by user on server
					[[CameraManager sharedCameraManager] takePicture];
				}
			}
		} failure:^(NSError *error) {
			NSLog(@"Failed to poll from server");
		}];
	}
}

@end
