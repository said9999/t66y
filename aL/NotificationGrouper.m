#import "NotificationGrouper.h"
#import "RingtoneManager.h"
#import "DeviceManager.h"

//Used to group the local notification for devices together
//Because iOS cannot call the application to pop up
//This notification refers to iOS notification

NSString *str_DeviceNames = @" ";

@implementation NotificationGrouper

-(id)init{
    self = [super init];
    if(self)
    {
        //initalization
        _DeviceList = [[NSMutableArray alloc]init];
        _LocalNotification = [[UILocalNotification alloc] init];
        _LocalNotification.fireDate = NULL;
        bol_Unscheduling=false;
    }
    return self;
}

-(void)add_Device:(Protag_Device*)device{
    if(![_DeviceList containsObject:device])
    {
        [_DeviceList addObject:device];
        device._Notification=self;
    }
}

-(void)Schedule:(int)interval{ //iOS interval (seconds)
    //It is in interval and not minutes because settings might cause local notification to turn on and off at unpredictable timings
    _LocalNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:interval];
    _LocalNotification.timeZone = [NSTimeZone defaultTimeZone];
   
    //device names
    if(_DeviceList.count>0)
    {
        str_DeviceNames = @" ";
        for(int i=0;i<_DeviceList.count;i++)
        {
            Protag_Device *device = (Protag_Device*)[_DeviceList objectAtIndex:i];
            str_DeviceNames = [str_DeviceNames stringByAppendingFormat:@"%@   ",device.str_Name];
            NSLog(@"Str Device Names %@",str_DeviceNames);
        }
    }
    else if ([[[DeviceManager sharedInstance]_LostDevices]count]>0)
    {
        str_DeviceNames = @" ";
        for(int i=0;i<[[[DeviceManager sharedInstance]_LostDevices]count];i++)
        {
            Protag_Device *device = (Protag_Device *)[[[DeviceManager sharedInstance]_LostDevices]objectAtIndex:i];
            str_DeviceNames = [str_DeviceNames stringByAppendingFormat:@"%@   ",device.str_Name];
            NSLog(@"Str Device Names %@",str_DeviceNames);
        }
    }
  	// Notification details
    _LocalNotification.alertBody = [NSString stringWithFormat:@"The following device(s) are lost: %@",str_DeviceNames];
    
	// Set the action button
    _LocalNotification.alertAction = @"View";
    
    _LocalNotification.soundName = [[RingtoneManager sharedInstance]get_ToneFilename];
    //_LocalNotification.soundName = UILocalNotificationDefaultSoundName;
    
    _LocalNotification.applicationIconBadgeNumber+=1;
    
    _LocalNotification.repeatInterval = NSMinuteCalendarUnit;
   
    NSLog(@"scheduling notification grouper, %@",str_DeviceNames);

    [[UIApplication sharedApplication] scheduleLocalNotification:_LocalNotification];
    
   // [[UIApplication sharedApplication]presentLocalNotificationNow:_LocalNotification];
}

-(void)Unschedule{
    if(bol_Unscheduling==false){
        NSLog(@"Unscheduling Notification Grouper");
        
        bol_Unscheduling=true;

        NSLog(@"CancelingLocalNotification");
       
        //Unschedule the localnotification
        if([self hasPastFireDate] && _LocalNotification!=NULL)
        {
            [[UIApplication sharedApplication] cancelLocalNotification:_LocalNotification];
        }
        
        //Remove all pointers to this notification
        while(_DeviceList.count>0)
        {
            Protag_Device *device = (Protag_Device*)[_DeviceList objectAtIndex:0];
            [device set_Notification:NULL];//Do not use UnscheduleNotification else will cause loop
            [_DeviceList removeObjectAtIndex:0];
        }
        NSLog(@"Notification Grouper finished Unscheduling");
    }
}

-(BOOL)hasPastFireDate{
    //Unschedule the localnotification
    if(_LocalNotification!=NULL && _LocalNotification.fireDate!=NULL)
    {
        NSComparisonResult result = [_LocalNotification.fireDate compare:[NSDate date]];
        return result == NSOrderedAscending;
    }
    return true;
}

@end
