#import "btn_AddDevice.h"
#import "BluetoothManager.h"
#import "PopUp_AddDevice.h"
#import "DataManager.h"

@implementation btn_AddDevice

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        //Hint
        img_Hint = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"hint1.png"]];
        [img_Hint setUserInteractionEnabled:false];
        
        glowCounter=0;
        bol_Glow_Shrink=false;
        timer_Glow=NULL;
        
        //set the button image
        [self refreshDeviceView];
        [self addTarget:self action:@selector(pressed) forControlEvents:UIControlEventTouchDown];
        [[DeviceManager sharedInstance]registerObserver:self];
    }
    return self;
}

-(void)animateButton{
    UIImage *animatedImage = [UIImage animatedImageWithImages: [[NSArray alloc]initWithObjects:[UIImage imageNamed:@"glow white"],[UIImage imageNamed:@"glow white2"],[UIImage imageNamed:@"glow white3"],[UIImage imageNamed:@"glow white3"],[UIImage imageNamed:@"glow white2"],[UIImage imageNamed:@"glow white"],nil] duration:1.5];
            
    [self setImage:animatedImage forState:UIControlStateNormal];
}

//no animation
-(void)staticButton{
    [self setImage: [UIImage imageNamed:@"glow white"] forState:UIControlStateNormal];
}

//Hint
-(void)showHint{
    if(![self.subviews containsObject:img_Hint])
    {
        NSLog(@"Show Add Protag Hint");
        [img_Hint setFrame:self.imageView.frame];
        
        [self addSubview:img_Hint];
        [self startGlowingHint];
    }
}

-(void)removeHint{
    if([self.subviews containsObject:img_Hint])
    {
        
        NSLog(@"Remove Add Protag Hint");
        [img_Hint removeFromSuperview];
        [self stopGlowingHint];
    }
}

//Glowing effects
-(void)startGlowingHint{
    NSLog(@"startGlowing");
    if(timer_Glow==NULL)
    {
        bol_Glow_Shrink=true;
        timer_Glow = [NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(intermediateGlowHint) userInfo:nil repeats:true];
    }
}

-(void)intermediateGlowHint{
    //Used counter instead of adding and subtracting alpha because the values does not seem accurate
    if(bol_Glow_Shrink==true)
    {
        if(glowCounter>-3){
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
    
    [img_Hint setAlpha:1+(glowCounter*0.3)];
}

-(void)stopGlowingHint{
    if(timer_Glow!=NULL)
    {
        [timer_Glow invalidate];
        timer_Glow=NULL;
        [img_Hint setAlpha:1];
    }
}

-(void)pressed{
    if([[BluetoothManager sharedInstance]is_BluetoothOn])
        [[PopUp_AddDevice sharedInstance]ShowPopUp];
    else
    {
        if([[[UIDevice currentDevice]systemVersion]floatValue] >= 7.0){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Information" message:@"Bluetooth is currently OFF, please turn ON Bluetooth in iPhone Settings" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"\n\n\n\n\n" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            
            UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(90, 10, 130, 40)];
            [title setTextColor:[UIColor whiteColor]];
            [title setFont:[UIFont boldSystemFontOfSize:20]];
            [title setText:@"Information"];
            [title setBackgroundColor:[UIColor clearColor]];
            [alertView addSubview:title];
    
            UITextView *contentTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, 45, 260, 100)];
            [contentTextView setEditable:FALSE];
            [contentTextView setTextColor:[UIColor blackColor]];
            [contentTextView setFont:[UIFont systemFontOfSize:18]];
            contentTextView.contentMode = UIViewAutoresizingFlexibleWidth;
            [contentTextView setBackgroundColor:[UIColor clearColor]];
            [contentTextView setClipsToBounds:TRUE];
            [contentTextView setTextAlignment:NSTextAlignmentCenter];
            [contentTextView setText:@"Bluetooth is currently OFF, please turn ON Bluetooth in iPhone Settings"];
            [alertView addSubview:contentTextView];
        
            [alertView show];
        }
    
    }
}

//extended method from DeviceObserver
- (void) refreshDeviceView{
    //this will cause it to animate if there are no devices paired
    if([[[DeviceManager sharedInstance]_currentDevices]count]==0)
        [self animateButton];
    else
        [self staticButton];
   if([[[DeviceManager sharedInstance]_currentDevices]count]==0 && [[DataManager sharedInstance]Hints_Step]==1)
        [self showHint];
   else
       [self removeHint];
}



@end
