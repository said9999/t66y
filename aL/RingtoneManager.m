

#import "RingtoneManager.h"
#import "Alarm.h"

@implementation RingtoneManager
//Singleton
+(id)sharedInstance{
    static RingtoneManager *_instance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

-(id)init{
    self = [super init];
    if(self)
    {
        //set default tone here
        int_Tone = TONE_RINGER;
    }
    return self;
}

-(void)set_Tone:(Ringtone)tone{
    int_Tone = tone;
    [[Alarm sharedInstance]refreshAudioPath:tone];
}

-(int)get_ToneInt{
    return int_Tone;
}

-(NSString*)get_ToneFilename{
    return [NSString stringWithFormat:@"%@.%@",[self get_ToneGenericName],[self get_ToneType]];
}

-(NSString*)get_ToneGenericName{
    return [self get_ToneGenericName:int_Tone];
}

-(NSString*)get_ToneType{
    return [self get_ToneType:int_Tone];
}

-(NSString*)get_ToneFilename:(Ringtone)tone{
    return [NSString stringWithFormat:@"%@.%@",[self get_ToneGenericName:tone],[self get_ToneType:tone]];
}
-(NSString*)get_ToneGenericName:(Ringtone)tone{
    switch(tone){
       /* case TONE_HILO:
            return @"hilo";
        case TONE_KITTEN:
            return @"kitten";
        case TONE_SWEET:
            return @"sweet";
        case TONE_BELL:
            return @"bell";
        case TONE_DIGITAL:
            return @"digital";
        case TONE_ALARM:
            return @"alarm";
        case TONE_TING:
            return @"ting";
        case TONE_BEEPS:
            return @"beeps";
        case TONE_SWEEP:
            return @"sweep";
        case TONE_RINGER:
            return @"ringer";*/
        case TONE_DEFAULT:
        default:
            return @"Default";
    }
}
-(NSString*)get_ToneType:(Ringtone)tone{
    switch(tone){
        default:
            return @"wav";
    }
}

@end

