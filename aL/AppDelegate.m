#import "AppDelegate.h"
#import "DataManager.h"
#import "Alarm.h"
#import "GPSManager.h"
#import "BluetoothManager.h"
#import "ViewController_Configuration.h"
#import "ViewController_DevicesWithSideMenu.h"
#import "ViewController_Settings.h"
#import "ViewController_UserManual.h"
#import "DeviceManager.h"
#import "ViewController_SignUpAndSignIn.h"
#import "AccountManager.h"
#import "AFNetworking.h"
#import "CameraManager.h"
#import "BackupContactsManager.h"
#import "NearbyDevicesViewController.h"
#import <Crashlytics/Crashlytics.h>
#import "BlueToothBackgroundManager.h"
#import "CrowdTrackManager.h"

@interface AppDelegate(){
    UIBackgroundTaskIdentifier bgTask;
}

@end

@implementation AppDelegate
    




@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //Crashlytics Code Added
    [Crashlytics startWithAPIKey:@"23abc7f6512b4eda2c694f867fcff88eb18dafa9"];
	//Initialize non-view controllers so that they will check and respond with warnings
    [DataManager sharedInstance];
    [GPSManager sharedInstance];
    [BluetoothManager sharedInstance];
    //Loading of data done by DeviceController itself
    [DeviceManager sharedInstance];
    [WifiDetector sharedInstance];
    
    HasLaunchedOnce = false;
    
    // register remote notifications
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    //This only cancels if app was closed and not put in background
    [[UIApplication sharedApplication]cancelAllLocalNotifications];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.window.backgroundColor = [UIColor darkGrayColor];
   
    //Home, mobile, settings, help
 
    ViewController_DevicesWithSideMenu  *GUIDevicesController = [[ViewController_DevicesWithSideMenu alloc]init];
    GUIDevicesController.tabBarItem.image = [UIImage imageNamed:@"home.png"];
    GUIDevicesController.tabBarItem.title = @"Home";
    UINavigationController *NavController_GUIDevices = [[UINavigationController alloc]initWithRootViewController:GUIDevicesController];
   
    ViewController_Configuration *ConfigurationController = [[ViewController_Configuration alloc]init];
    ConfigurationController.tabBarItem.image = [UIImage imageNamed:@"mobile.png"];
    ConfigurationController.tabBarItem.title = @"Mobile";
    UINavigationController *NavController_Configuration = [[UINavigationController alloc]initWithRootViewController:ConfigurationController];
    
    
    ViewController_Settings *SettingsController = [[ViewController_Settings alloc]init];
    SettingsController.tabBarItem.image = [UIImage imageNamed:@"settings.png"];
    SettingsController.tabBarItem.title = @"Settings";
    UINavigationController *NavController_Settings = [[UINavigationController alloc]initWithRootViewController:SettingsController];
    
    ViewController_UserManual *UserManualController = [[ViewController_UserManual alloc]init];
    UserManualController.tabBarItem.image = [UIImage imageNamed:@"help.png"];
    UserManualController.tabBarItem.title = @"Help";
    UINavigationController *NavController_UserManual = [[UINavigationController alloc]initWithRootViewController:UserManualController];

    [[GPSManager sharedInstance]StopMonitoringAll];
    [[GPSManager sharedInstance]StartMonitoringAll];
    [[GPSManager sharedInstance]CheckForGeofence];
    
    UITabBarController *TabbarController = [[UITabBarController alloc] init];

    [TabbarController setViewControllers:[NSArray arrayWithObjects:NavController_GUIDevices, NavController_Configuration,NavController_Settings,NavController_UserManual, nil]];
    [self.window setRootViewController:TabbarController];
	    
    [TabbarController.view setAutoresizesSubviews:true];
    
    TabbarController.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    NavController_Configuration.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    [NavController_Configuration.view setAutoresizesSubviews:true];
    
    NavController_GUIDevices.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    [NavController_GUIDevices.view setAutoresizesSubviews:true];
    
    NavController_Settings.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    [NavController_Settings.view setAutoresizesSubviews:true];
    NavController_UserManual.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    [NavController_UserManual.view setAutoresizesSubviews:true];
    if([[AccountManager sharedAccountManager] bol_isRegistered] == NO || [[AccountManager sharedAccountManager] bol_isLogined] == NO){
       // [TabbarController presentViewController:[ViewController_SignUpAndSignIn sharedInstance] animated:YES completion:nil];
        [TabbarController.view addSubview:[[ViewController_SignUpAndSignIn sharedInstance]view]];
    }
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        UIView *addStatusBar = [[UIView alloc] init];
        addStatusBar.frame = CGRectMake(0, 0, 320, 20);
        //addStatusBar.backgroundColor = [UIColor colorWithRed:0.973 green:0.973 blue:0.973 alpha:1]; //change this to match your navigation bar
        addStatusBar.backgroundColor = [UIColor blackColor];
        //addStatusBar.tintColor = [UIColor whiteColor];
        [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
        TabbarController.tabBar.tintColor = [UIColor whiteColor];
        TabbarController.tabBar.translucent = NO;
        [[UITabBar appearance]setBarStyle:UIBarStyleBlack];
        [[UINavigationBar appearance]setTintColor:[UIColor whiteColor]];
        //[self.window.rootViewController.view addSubview:addStatusBar];
        [self.window.rootViewController.view insertSubview:addStatusBar atIndex:1];
    }
    else
    {
        [[UINavigationBar appearance]setTintColor:[UIColor blackColor]];
    }
  /*  mapManager = [[BMKMapManager alloc]init];
    
    //either one can use i think so, registered for two api key
      BOOL unique_Identifier = [mapManager start: @"3cf99a6c628cae126cd34f95e3672fe6" generalDelegate: nil];
    //BOOL unique_Identifier = [mapManager start: @"5E4C7ce641dca63331ac501d7ea06310" generalDelegate: nil];
    
    if(!(unique_Identifier))
    {
        NSLog(@"Manager Start Failed");
    }*/
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [[Alarm sharedInstance]PauseTimer];
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

    [[DataManager sharedInstance]save_Settings];
    [[DataManager sharedInstance]save_Devices];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    [self backgroundTask];
    //[self startBackgroundTask:10];
}

- (void)backgroundTask{
    UIApplication *app = [UIApplication sharedApplication];
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    
    if (!app.applicationState == UIApplicationStateActive ){
        if ([[BlueToothBackgroundManager sharedInstance] isCrowdTrackingEnabled]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                [[BlueToothBackgroundManager sharedInstance] disableBackgroundTracking];
                [[BlueToothBackgroundManager sharedInstance] enableBackgroundTracking];
            });
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSelector:@selector(endTask) withObject:nil afterDelay:3];
        });
    }
}

/*
- (void)startTrackingBg{
    NSTimeInterval timeLeft = [[UIApplication sharedApplication] backgroundTimeRemaining];
    NSLog(@"Background time remaining: %f seconds (%d mins)", timeLeft, (int)(timeLeft / 60));
   // [[BlueToothBackgroundManager sharedInstance] disableBackgroundTracking];
    [[BlueToothBackgroundManager sharedInstance] enableBackgroundTracking];
*/

- (void)endTask{
    if ([[NSDate date] timeIntervalSince1970] - [[[CrowdTrackManager sharedInstance]latestUpdateTime] timeIntervalSince1970] <= 90) {
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.fireDate = [[NSDate date] dateByAddingTimeInterval:1];
        notification.alertBody = @"You've found a lost item in the last 90s";
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[Alarm sharedInstance]ResumeTimer];
    [[GPSManager sharedInstance]CheckGPSStatus];
    [[BluetoothManager sharedInstance]CheckBluetoothStatus];
    [[AccountManager sharedAccountManager]checkBackgroundAppRefresh];
    //[[WifiDetector sharedInstance]CheckWiFiStatus];
    [[Alarm sharedInstance]destroyNotificationPastFiringDate];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[DataManager sharedInstance]save_Devices];
    [[DataManager sharedInstance]save_Settings];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskPortrait;
}

//For Push Notification
-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
#warning problem with this is that if connection is off or down
    NSLog(@"token is %@", deviceToken);
    NSString *strToken =  [NSString stringWithFormat:@"%@",deviceToken];
    [[AccountManager sharedAccountManager]updateServerPushToken:strToken];
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    NSLog(@"Failed to get token for remote Notification: %@",error);
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    //For all iOS, only runs when app is running
    NSLog(@"received remote notification :%@",userInfo);
    
    NSDictionary *aps = [userInfo objectForKey:@"aps"];
    NSString *action = [aps objectForKey:@"action"];
    
    if([action isEqualToString: @"testTrack"]){
        NSLog(@"Detected push message as testTrack");
        [[GPSManager sharedInstance]testTrack];
    }else if([action isEqualToString:@"imageCapture"]){
        NSLog(@"Detected push message as imageCapture");
        [[CameraManager sharedCameraManager]takePicture];
    }else if([action isEqualToString:@"bContact"]){
        NSLog(@"Detected push message as BackUpContact");
        [[BackupContactsManager sharedInstance]sendContactsToServer];
    }
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    //iOS 7+ only, runs in background, can get userInfo, need to turn on background fetch mode

    NSLog(@"received remote notification in background:%@",userInfo);
    NSDictionary *aps = [userInfo objectForKey:@"aps"];
    NSString *action = [aps objectForKey:@"action"];
    
    if([action isEqualToString: @"testTrack"]){
        NSLog(@"Detected push message as testTrack");
        [[GPSManager sharedInstance]testTrack];
        completionHandler(UIBackgroundFetchResultNewData);
    }else if([action isEqualToString:@"imageCapture"]){
        NSLog(@"Detected push message as imageCapture");
        [[CameraManager sharedCameraManager]takePicture];
        completionHandler(UIBackgroundFetchResultNewData);
    }else if([action isEqualToString:@"bcontact"]){
        NSLog(@"Detected push message as BackupContact");
        [[BackupContactsManager sharedInstance]sendContactsToServer];
        completionHandler(UIBackgroundFetchResultNewData);
    }else{
        completionHandler(UIBackgroundFetchResultNoData);
    }
}

-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    //iOS 7+ only, background fetch
    [[AccountManager sharedAccountManager]pollServerForActions];
#warning to check if doing completionHandler before any data has been polled from server will prevent the app from doing anything
    completionHandler(UIBackgroundFetchResultNoData);
}

/*
- (void)onGetNetworkState:(int)iError
{
    NSLog(@"onGetNetworkState %d",iError);
}

- (void)onGetPermissionState:(int)iError
{
    NSLog(@"onGetPermissionState %d",iError);
}
*/

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    NSLog(@"Launched from push notification: %@", notification.alertBody);
    if (!application.applicationState == UIApplicationStateActive ){//in background mode
        UITabBarController *tabBarController = (UITabBarController *)_window.rootViewController;
        NearbyDevicesViewController *nb = [[NearbyDevicesViewController alloc] initWithNibName:@"NearbyDevicesViewController" bundle:nil];
        tabBarController.selectedIndex = 1;
        UINavigationController *mobileController = (UINavigationController *)tabBarController.selectedViewController;
        // pop any viewcontrollers on stack
        [mobileController popToRootViewControllerAnimated:NO];
        [mobileController pushViewController:nb animated:NO];
    }
}

@end
