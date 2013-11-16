
#import <Foundation/Foundation.h>

typedef enum{
    TONE_DEFAULT,
    TONE_RINGER,
    TONE_HILO,
    TONE_KITTEN,
    TONE_SWEET,
    TONE_BELL,
    TONE_DIGITAL,
    TONE_ALARM,
    TONE_TING,
    TONE_BEEPS,
    TONE_SWEEP
} Ringtone;

//This class does not plays music, it stores the reference to the ringtones
//Refer to Alarm.m for playing music

@interface RingtoneManager : NSObject{
    int int_Tone;
}

+(id)sharedInstance;//Singleton
-(void)set_Tone:(Ringtone)tone;
-(int)get_ToneInt;
-(NSString*)get_ToneFilename; //returns the current selected tone full file name
-(NSString*)get_ToneGenericName; //returns the current selected tone file name without the type
-(NSString*)get_ToneType; //returns the type of the current selected tone e.g mp3 or wav

-(NSString*)get_ToneFilename:(Ringtone)tone; //returns the full file name
-(NSString*)get_ToneGenericName:(Ringtone)tone; //returns the file name without the type
-(NSString*)get_ToneType:(Ringtone)tone; //returns the type of the file e.g mp3 or wav

@end
