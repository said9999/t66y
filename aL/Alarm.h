#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioServices.h>
#import <AVFoundation/AVFoundation.h>
#import "RingtoneManager.h"

@class Protag_Device;

@protocol AlarmContainer <NSObject>
-(void)reduce_Second;
-(void)Set_Minutes:(int)minutes;
-(void)reduce_Seconds:(int)seconds;
@end


@interface Alarm : NSObject <UIAlertViewDelegate>{
    UIView *_PopUpView;
    UIView *_DatePickerView;
    UITextView *TextView_LostDeviceNames;
    UIDatePicker *_TimePicker;
    NSTimer *_timer;
    NSTimeInterval interval_FromBackground;
    AVAudioPlayer* _avAudioPlayer;
    NSMutableArray *_NotificationList;
    UIButton *btn_Snooze;
    UIButton *btn_Reconnect;
    UIButton *btn_Stop;
    bool bol_DimissingPopUp;
    NSTimer *timer;

}

@property (nonatomic) bool bol_isShown;
@property (nonatomic,retain) UILocalNotification *_localNotification;
@property (nonatomic,retain) UIApplication *_app;
@property (nonatomic) bool bol_playingVibration;


+(id)sharedInstance;
-(void)ShowAlarm;
-(void)Vibrate;
-(void)Play_Music;
-(void)Play_Music:(Ringtone)tone;
-(void)Stop_MusicOnly; //Only used when choosing alarm, does not clear lost device
-(void)UpdateLostDeviceNames;
-(BOOL)isCharging;
-(BOOL)isInBackground;
-(void)ReduceSecondsForAllLostDevices;
-(void)ShowLocalNotification;
-(void)StopAlarm;
-(void)PauseTimer;
-(void)ResumeTimer;
-(void)ProtagAlertsPhone:(Protag_Device*)device;
-(void)refreshAudioPath:(Ringtone)tone;
-(void)destroyNotificationPastFiringDate;
-(void)btnSnooze_Pressed;
-(void)btnReconnect_Pressed;
-(void)btnStop_Pressed;
@end
