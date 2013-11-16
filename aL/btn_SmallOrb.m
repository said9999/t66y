#import "btn_SmallOrb.h"
#import "Protag_Device.h"
#import "DeviceManager.h"
#import "DataManager.h"
#import <QuartzCore/QuartzCore.h>

@implementation btn_SmallOrb

@synthesize img_Icon;
@synthesize img_Background;
@synthesize _device;

-(id)initWithDevice:(Protag_Device*)device{
    
    if(self = [super init]){
        _device = device;
        
        glowCounter=0;
        timer_Glow=NULL;
        
        img_Icon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"1+wallet.png"]];
        [img_Icon setUserInteractionEnabled:false];
        img_Background = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"red.png"]];
        [img_Background setUserInteractionEnabled:false];
        
        [self setBackgroundColor:[UIColor clearColor]];
        
        [self addSubview:img_Background];
        [self addSubview:img_Icon];
    }
    [self updateImages];

    return self;
}

-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [img_Background setFrame:CGRectMake(0,0,frame.size.width,frame.size.height)];
    [img_Icon setFrame:CGRectMake(0,0,frame.size.width,frame.size.height)];
}

-(void)updateImages{
    if(_device!=NULL)
    {
        //Update Icon
        switch(_device.int_Icon)
        {
             case 6:
                [img_Icon setImage:[UIImage imageNamed:@"6+luggage.png"]];
             break;
             case 5:
                [img_Icon setImage:[UIImage imageNamed:@"5+purse.png"]];
             break;
             case 4:
                [img_Icon setImage:[UIImage imageNamed:@"4+briefcase.png"]];
             break;
             case 3:
                [img_Icon setImage:[UIImage imageNamed:@"3+laptop.png"]];
             break;
             case 2:
                [img_Icon setImage:[UIImage imageNamed:@"2+camera.png"]];
             break;
             case 1:
                [img_Icon setImage:[UIImage imageNamed:@"1+wallet.png"]];
             break;
             case 0:
             default:
                [img_Icon setImage:[UIImage imageNamed:@"silver.png"]];
             break;
        }
        if([[DataManager sharedInstance]Hints_Step]==2  && [[DeviceManager sharedInstance]_currentDevices].count == 1)
        {
            [img_Background setImage:[UIImage imageNamed:@"hint2.png"]];
            [self startGlowing];
        }
        else
        {
            [self stopGlowing];
        //Update Color of Orb (status)
            switch([_device get_StatusCode])
            {
                case STATUS_CONNECTED:
                    [img_Background setImage:[UIImage imageNamed:@"green.png"]];
                    break;
                case STATUS_SECURE_ZONE:
                    [img_Background setImage:[UIImage imageNamed:@"blue.png"]];
                    break;
                case STATUS_SNOOZE:
                    [img_Background setImage:[UIImage imageNamed:@"yellow.png"]];
                    break;
                case STATUS_NOT_CONNECTED:
                case STATUS_DISCONNECTED:
                case STATUS_CONNECTING:
                default:
                    [img_Background setImage:[UIImage imageNamed:@"red.png"]];
                    break;
            }
        }
    }
}


//Glowing effects
-(void)startGlowing{
    NSLog(@"startGlowing");
    if(timer_Glow==NULL)
    {
        bol_Glow_Shrink=true;
        timer_Glow = [NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(intermediateGlow) userInfo:nil repeats:true];
    }
}

-(void)intermediateGlow{
    //Used counter instead of adding and subtracting alpha because the values does not seem accurate
    if(bol_Glow_Shrink==true)
    {
        if(glowCounter>-4){
            glowCounter--;
        }else{
            bol_Glow_Shrink=false;
        }
    }
    else
    {
        if(glowCounter<0){
            glowCounter++;
        }else{
            bol_Glow_Shrink=true;
        }
    }
    
    [img_Background setAlpha:1+(glowCounter*0.2)];
}

-(void)stopGlowing{
    if(timer_Glow!=NULL)
    {
        [timer_Glow invalidate];
        timer_Glow=NULL;
        [img_Background setAlpha:1];
    }
}

//Fix the refresh issue with the timer
-(void)removeFromSuperview{
    [super removeFromSuperview];
    [self stopGlowing];
}


@end
