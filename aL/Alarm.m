//Buttons must in the following order: Snooze, Reconnect, Stop. Else you will have to modify the index according to new needs

#import "Alarm.h"
#import "Protag_Device.h"
#import "DeviceManager.h"
#import "NotificationGrouper.h"
#import "DataManager.h"

//Animation guide
//http://iphonedevelopment.blogspot.sg/2010/05/custom-alert-views.html
#define kAnimationDuration  0.2555

//Class in charge of LocalNotification and Music and Alert (alarm)

@implementation Alarm

@synthesize bol_isShown;
@synthesize _localNotification;
@synthesize bol_playingVibration;


+(id)sharedInstance{
    static Alarm *_instance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

-(id)init{
    if(self = [super init]){
        NSArray *theView =  [[NSBundle mainBundle] loadNibNamed:@"Alarm" owner:self options:nil];
        _PopUpView = [theView objectAtIndex:0];
        _TimePicker = (UIDatePicker*)[_PopUpView viewWithTag:2];
        TextView_LostDeviceNames = (UITextView*)[_PopUpView viewWithTag:3];
        
        btn_Snooze = (UIButton*)[_PopUpView viewWithTag:4];
        btn_Reconnect = (UIButton*)[_PopUpView viewWithTag:5];
        btn_Stop = (UIButton*)[_PopUpView viewWithTag:6];
        
        [_TimePicker setCountDownDuration:300];
        [_TimePicker setDatePickerMode:UIDatePickerModeCountDownTimer];
        
        //Initialization
        bol_isShown=false;
        _timer=NULL;
        _localNotification = [[UILocalNotification alloc] init];
        _avAudioPlayer = NULL;
        _NotificationList = [[NSMutableArray alloc]init];
        bol_playingVibration  = NO;
        
        [btn_Snooze addTarget:self action:@selector(btnSnooze_Pressed) forControlEvents:UIControlEventTouchUpInside];
        [btn_Reconnect addTarget:self action:@selector(btnReconnect_Pressed) forControlEvents:UIControlEventTouchUpInside];
        [btn_Stop addTarget:self action:@selector(btnStop_Pressed) forControlEvents:UIControlEventTouchUpInside];
        }
    return self;
}

-(void)ShowAlarm{
    NSLog(@"Show Alarm");
    if(bol_isShown==false){
        bol_isShown=true;
        [self UpdateLostDeviceNames];
        [self ShowPopUp];
        [self Play_Music];
    }else
        [self UpdateLostDeviceNames];
    
    if([self isInBackground])
        [self ShowLocalNotification];
}

-(void)ShowPopUp{
    
    id appDelegate = [[UIApplication sharedApplication] delegate];
    UIWindow *window = [appDelegate window];
    [window addSubview:_PopUpView];
    
    _PopUpView.alpha = 1;
    _PopUpView.frame = window.frame;
    _PopUpView.center = window.center;
    bol_DimissingPopUp=false;
    
    [self animateBackgroundFadeIn];
    [self animateBoxPopIn];
}

-(void)DismissPopUp{
    //Stop Scanning
    [UIView beginAnimations:nil context:nil];
    _PopUpView.alpha = 0.0;
    [UIView commitAnimations];
   
    [self performSelector:@selector(FinishDismissAnimation) withObject:nil afterDelay:0.5];
    bol_DimissingPopUp=true;
    
}

-(void)FinishDismissAnimation{
    if(bol_DimissingPopUp==true)
        [_PopUpView removeFromSuperview];
}

-(void)animateBoxPopIn{
    //pop in animation
    CALayer *viewLayer = [_PopUpView viewWithTag:10].layer;
    CAKeyframeAnimation* popInAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    
    popInAnimation.duration = kAnimationDuration;
    popInAnimation.values = [NSArray arrayWithObjects:
                             [NSNumber numberWithFloat:0.6],
                             [NSNumber numberWithFloat:1.1],
                             [NSNumber numberWithFloat:.9],
                             [NSNumber numberWithFloat:1],
                             nil];
    popInAnimation.keyTimes = [NSArray arrayWithObjects:
                               [NSNumber numberWithFloat:0.0],
                               [NSNumber numberWithFloat:0.6],
                               [NSNumber numberWithFloat:0.8],
                               [NSNumber numberWithFloat:1.0],
                               nil];
    popInAnimation.delegate = nil;
    
    [viewLayer addAnimation:popInAnimation forKey:@"transform.scale"];
}

-(void)animateBackgroundFadeIn{
    CALayer *viewLayer = [_PopUpView viewWithTag:11].layer;
    CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeInAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    fadeInAnimation.toValue = [NSNumber numberWithFloat:0.4];
    fadeInAnimation.duration = kAnimationDuration;
    fadeInAnimation.delegate = nil;
    [viewLayer addAnimation:fadeInAnimation forKey:@"opacity"];
}

//Button actions
-(void)btnSnooze_Pressed{
    bol_isShown=false;
    NSLog(@"Pressed Snooze");
    [self Stop_MusicOnly];
    for(int i=0;i<[[DeviceManager sharedInstance]_LostDevices].count;i++)
    {
        Protag_Device *device = (Protag_Device*)[[[DeviceManager sharedInstance]_LostDevices]objectAtIndex:i];
        if([device get_StatusCode] != STATUS_SNOOZE)
            [device Set_Minutes:[_TimePicker countDownDuration]/60];
    }
    [self ScheduleLocalNotification:[_TimePicker countDownDuration]/60];
    
    //if timer was not previously created, create it here
    if(_timer == NULL)
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(ReduceSecondsForAllLostDevices) userInfo:nil repeats:true];
    [self DismissPopUp];
}

-(void)btnReconnect_Pressed {
    bol_isShown=false;
    
    NSLog(@"Pressed Reconnect");
    [self Stop_MusicOnly];
    NSMutableArray *tempArray = [[DeviceManager sharedInstance]_LostDevices].mutableCopy;
    [[DeviceManager sharedInstance]Clear_NonSnoozedLostDevices];
    for(int i=0;i<tempArray.count;i++)
    {
        Protag_Device *device = (Protag_Device*)[tempArray objectAtIndex:i];
        if(![device isConnected])
        {
            [tempArray removeObjectAtIndex:i];
            [device Connect];
            i--;
        }
    }
    [self DismissPopUp];
}

-(void)btnStop_Pressed{
    bol_isShown=false;
    NSLog(@"Pressed Stop");
    [self StopAlarm];
    [self DismissPopUp];
}

-(void)ProtagAlertsPhone:(Protag_Device*)device{
    NSString *str_Message = [NSString stringWithFormat:@"%@ is alerting the phone",device.str_Name];
    UIAlertView *_Alert = [[UIAlertView alloc]initWithTitle:nil message:str_Message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    _Alert.tag = 11;
    [self Play_Music];
    [_Alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    bol_isShown=false;
    if(alertView.tag==11)
    {
        //Pressed ok
        //For Protag alert phone
        [self Stop_MusicOnly];
    }
}

-(void)StopAlarm{
    //stop music
    [self Stop_MusicOnly];
    
    //Clear lost device will auto set the new status
    [[DeviceManager sharedInstance]Clear_NonSnoozedLostDevices];
}

-(void)UpdateLostDeviceNames{
    if(TextView_LostDeviceNames!=NULL)
    {
        NSString *str_DeviceNames = @" ";

        for(int i=0;i<[[DeviceManager sharedInstance]_LostDevices].count;i++)
        {
            Protag_Device *device = (Protag_Device*)[[[DeviceManager sharedInstance]_LostDevices]objectAtIndex:i];
          /*  if([device SnoozeSeconds]==0)
            {*/
               if(i==0)
                    str_DeviceNames = device.str_Name;
                else
                    str_DeviceNames = [str_DeviceNames stringByAppendingFormat:@", %@",device.str_Name];
          //  }
        }
        [TextView_LostDeviceNames setText:str_DeviceNames];
    }
}

-(void)Play_Music{
    [self Vibrate];
    [self Play_Music:[[RingtoneManager sharedInstance]get_ToneInt]];
    bol_playingVibration = YES;
}

-(void)Play_Music:(Ringtone)tone{
    [self Vibrate];
    
    // play sound
    if([[DataManager sharedInstance]Settings_Music])
        [_avAudioPlayer play];
    
    NSLog(@"Playing music");
}

-(void)Stop_MusicOnly{
    [_avAudioPlayer stop];
    
    //This is to fix the problem of the audio only playing once in the background
    [[Alarm sharedInstance]refreshAudioPath:[[RingtoneManager sharedInstance]get_ToneInt]];
    bol_playingVibration = NO;
}

-(void)Vibrate{
   if([[DataManager sharedInstance]Settings_Vibration])
   {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        AudioServicesAddSystemSoundCompletion(kSystemSoundID_Vibrate, 0, 0, soundCompletionProc, (__bridge void *)(self));
   }
}

/*if we are still supposed to be playing, play again, otherwise deregister the completion proc*/
-(void)soundCompletion: (SystemSoundID) ssID
{
    if (bol_playingVibration)
        AudioServicesPlaySystemSound (ssID);
    else
        AudioServicesRemoveSystemSoundCompletion (ssID);
}

/*this is called when a system sound -- just vibrate really -- ends.
 we use it to loop. one reason to only use this api for vibrate
 is that there's no volume control.
 */
void soundCompletionProc(SystemSoundID ssID, void*clientData)
{
     Alarm  *alarm = (__bridge Alarm *)(clientData);
    [alarm soundCompletion:ssID];
}

-(BOOL)isCharging{
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
    
    if ([[UIDevice currentDevice] batteryState] == UIDeviceBatteryStateCharging)
        return true;
    else
        return false;
}

-(BOOL)isInBackground{
    return [UIApplication sharedApplication].applicationState == UIApplicationStateBackground;

}

-(void)ShowLocalNotification{
    NSLog(@"Show Local Notification");
    //instant local notification
    [self ScheduleLocalNotification:0];
}


-(void)ScheduleLocalNotification:(NSInteger)minutes{
    if(minutes>=0)
    {
        NSLog(@"Schedule Local Notification");
        NotificationGrouper *_tempNotification = [[NotificationGrouper alloc]init];
        
        for(int i=0;i<[[DeviceManager sharedInstance]_LostDevices].count;i++)
        {
            Protag_Device *device = (Protag_Device*)[[[DeviceManager sharedInstance]_LostDevices]objectAtIndex:i];
            //Only select those that are not in snooze mode
            if([device SnoozeSeconds]==0 && [device get_StatusCode]!=STATUS_SNOOZE)
                [_tempNotification add_Device:device];
        }
        [_tempNotification Schedule:minutes*60];
        [_NotificationList addObject:_tempNotification];
   }
}

-(void)ReduceSecondsForAllLostDevices{
    
    if([[DeviceManager sharedInstance]_LostDevices].count==0)
    {
        //Reset alarm if there are no lost devices left
        if(_timer!=NULL)
        {
            [_timer invalidate];
            _timer = NULL;
        }
        return;
    }
    //If Snooze Timer reach 0, attempt to show alarm again
    for(int i=0;i<[[DeviceManager sharedInstance]_LostDevices].count;i++)
    {
        Protag_Device *device = (Protag_Device*)[[[DeviceManager sharedInstance]_LostDevices]objectAtIndex:i];
        [device reduce_Second];
        if([device SnoozeSeconds]==0 && [device get_StatusCode] == STATUS_SNOOZE)
        {
            [device set_Status:STATUS_DISCONNECTED];
            [self ShowAlarm];
        }
    }
}

-(void)PauseTimer{
    //NSTimer does not work in background so require to save the timing between background and active to update the timer values
    interval_FromBackground = [[NSDate date]timeIntervalSinceReferenceDate];
}

-(void)ResumeTimer{
    NSLog(@"Resuming Timer");
    interval_FromBackground = [[NSDate date]timeIntervalSinceReferenceDate] - interval_FromBackground;
    
    if(interval_FromBackground>0)
    {
        bool bol_ShowAlarm = false;
        for(int i=0;i<[[DeviceManager sharedInstance]_LostDevices].count;i++)
        {
            Protag_Device *device = (Protag_Device*)[[[DeviceManager sharedInstance]_LostDevices]objectAtIndex:i];
            [device reduce_Seconds:(int)interval_FromBackground];
            if([device SnoozeSeconds] == 0 && [device isConnected] == false)
                bol_ShowAlarm = true;
        }
        if(bol_ShowAlarm==true)
            [self ShowAlarm];
    }
    NSLog(@"Finish Resuming Timer");
}

-(void)refreshAudioPath:(Ringtone)tone{
    NSString *soundPath = [[NSBundle mainBundle] pathForResource: [[RingtoneManager sharedInstance]get_ToneGenericName:tone] ofType:[[RingtoneManager sharedInstance]get_ToneType:tone]];
    NSData *soundData = [NSData dataWithContentsOfFile:soundPath];
    
    if(_avAudioPlayer!=NULL)
    {
        NSLog(@"resetting _avAudioPlayer to NULL");
        [_avAudioPlayer stop];
        _avAudioPlayer = NULL;
    }
    
    NSError *ErrorLog = NULL;
    
    NSLog(@"Initializing _avAudioPlayer");
    _avAudioPlayer = [[AVAudioPlayer alloc] initWithData:soundData error:&ErrorLog];
    
    if(ErrorLog){
        NSLog(@"Error setting up avAudioPlayer: %@",ErrorLog);
        ErrorLog = NULL;
    }
    
    //infinite loop
    [_avAudioPlayer setNumberOfLoops:-1];
    
    //Reroute music through speaker (because this is the only way to play through lock screen
    [[AVAudioSession sharedInstance]setCategory:AVAudioSessionCategoryPlayback error:&ErrorLog];
    
    NSLog(@"Reroute music to speaker");
    
    if(ErrorLog){
        NSLog(@"Error setting category for avAudioPlayer: %@",ErrorLog);
        ErrorLog = NULL;
    }
    
    [[AVAudioSession sharedInstance]setActive:true error:&ErrorLog];
    [_avAudioPlayer prepareToPlay];
    
    if(ErrorLog){
        NSLog(@"Error setting active: %@",ErrorLog);
        ErrorLog = NULL;
    }
}

-(void)destroyNotificationPastFiringDate{
    NSLog(@"Checking for Notifications to unschedule");
    for(int i=0;i<_NotificationList.count;i++)
    {
        NotificationGrouper *tempGroup = (NotificationGrouper*)[_NotificationList objectAtIndex:i];
        if([tempGroup hasPastFireDate]){
            [_NotificationList removeObjectAtIndex:i];
            i--;
            [tempGroup Unschedule];
            tempGroup  = NULL;
        }
    }
    //[_NotificationList removeAllObjects];
}

@end
