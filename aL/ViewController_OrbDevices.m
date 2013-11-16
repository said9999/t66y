#import "ViewController_OrbDevices.h"
#import "btn_SmallOrb.h"
#import "DeviceManager.h"
#import "Protag_Device.h"
#import "ViewController_DevicesWithSideMenu.h"

//Internal Interface
@interface ViewController_OrbDevices ()<DeviceObserver>

@end

@implementation ViewController_OrbDevices

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    _OrbDevices = [[NSMutableArray alloc]init];
    
    //Load the Nib
    UIView *mainView = [[[NSBundle mainBundle] loadNibNamed:@"View_OrbDevices" owner:self options:nil]objectAtIndex:0];
    [self setView: mainView];
    btn_BigButton = (UIButton*)[mainView viewWithTag:1];
    
    [btn_BigButton addTarget:self action:@selector(PressedLargeOrb:) forControlEvents:UIControlEventTouchDown];
    
    [btn_BigButton addTarget:self action:@selector(LetGoLargeOrb:WithEvent:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside];
    
    [btn_BigButton addTarget:self action:@selector(DragLargeOrb:WithEvent:) forControlEvents:UIControlEventTouchDragEnter|UIControlEventTouchDragExit|UIControlEventTouchDragInside|UIControlEventTouchDragOutside];
    
    bol_iphone5=false;
    
    //Check for iphone 5, change background if neccessary
    if([[UIScreen mainScreen] bounds].size.height-568 == 0)
    {
        NSLog(@"iphone 5 orb background");
        UIImageView *background = (UIImageView*)[mainView viewWithTag:2];
        [background setImage:[UIImage imageNamed:@"home background i5"]];
        bol_iphone5=true;
    }
    
    _OrbOverlay = [[ViewController_LargeOrb alloc]init];
    int_LargeOrbDetectionWidth=50;
    
    //Invisible button on the left side so that ViewController_DevicesWithSideMenu can scroll to the WarningMenu. This button does no action
    /*UIButton *btn_InvisibleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn_InvisibleBtn setBackgroundColor:[UIColor clearColor]];
    
    [btn_InvisibleBtn setFrame:CGRectMake(05, 0, 40,self.view.frame.size.height)];
    [self.view addSubview:btn_InvisibleBtn];*/
    
    //Initialize the orbs
    for(int i=0;i<[[DeviceManager sharedInstance]_currentDevices].count;i++)
    {
        [self CreateOrbWithDevice: (Protag_Device*)[[[DeviceManager sharedInstance]_currentDevices]objectAtIndex:i] withIndex:i];
    }
    
    
    //Register for refresh with MainController
    [[DeviceManager sharedInstance]registerObserver:self];
    
    self.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    [self.view setAutoresizesSubviews:true];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
        //Add button Position
        UIButton *btn_AddButton = (UIButton *)[mainView viewWithTag:3];
        [btn_AddButton setFrame:CGRectMake(225,75,70,70)];
        //to avoid hiding behind the navigation
        self.navigationController.navigationBar.translucent = NO;
        self.navigationController.navigationBar.barTintColor = [UIColor darkGrayColor];
        self.navigationController.navigationBar.titleTextAttributes = @{UITextAttributeTextColor : [UIColor whiteColor]};
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self RefreshSmallOrbs];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    //deregister for refresh with MainController
    [[DeviceManager sharedInstance]deregisterObserver:self]; 

}

-(void)CreateOrbWithDevice:(Protag_Device*)device withIndex:(int)index{
    btn_SmallOrb *temp_Orb = [[btn_SmallOrb alloc]initWithDevice:device];
    [self.view addSubview:temp_Orb];
    [self SetOrbLocation:temp_Orb withIndex:index];
    [temp_Orb addTarget:self action:@selector(PressedSmallOrb:)forControlEvents:UIControlEventTouchUpInside];
    
    [_OrbDevices addObject:temp_Orb];
}

-(void)SetOrbLocation:(btn_SmallOrb*)orb withIndex:(int)index{
    int orb_size = 60;
    int coord_x=0,coord_y=0;
    
    int rel_x = btn_BigButton.frame.origin.x;
    int rel_y = btn_BigButton.frame.origin.y;
    
#warning change orb positions
    if([[[UIDevice currentDevice]systemVersion]floatValue] >= 7.0)
    {
        if([[DeviceManager sharedInstance]_currentDevices].count<=3)
        {
            // Set orb starting location here (use relative position to the Large Orb)
            switch(index){
                case 0:
                    coord_x=rel_x-15;
                    if(bol_iphone5)
                        coord_y=rel_y+260;
                    else
                        coord_y=rel_y+200;
                    break;
                case 1:
                    coord_x=rel_x+200;
                    coord_y=rel_y+220;
                    break;
                case 2:
                    coord_x=rel_x-10;
                    coord_y=rel_y-10;
                    break;
                default:
                    coord_x=0;
                    coord_y=0;
                    break;
            }
        }else{
            switch(index){
                case 0:
                    coord_x=rel_x+85;
                    coord_y=rel_y-25;
                    break;
                case 1:
                    coord_x=rel_x-25;
                    coord_y=rel_y+25;
                    break;
                case 2:
                    coord_x=rel_x-40;
                    coord_y=rel_y+120;
                    break;
                case 3:
                    coord_x=rel_x-05;
                    coord_y=rel_y+210;
                    break;
                case 4:
                    coord_x=rel_x+215;
                    coord_y=rel_y+115;
                    break;
                case 5:
                    coord_x=rel_x+185;
                    coord_y=rel_y+200;
                    break;
                case 6:
                    coord_x=rel_x+85;
                    coord_y=rel_y+245;
                    break;
                default:
                    coord_x=0;
                    coord_y=0;
                    break;
            }
        }
    }
    else if([[[UIDevice currentDevice]systemVersion]floatValue]<7.0)
    {
        if([[DeviceManager sharedInstance]_currentDevices].count<=3)
        {
            // Set orb starting location here (use relative position to the Large Orb)
            switch(index){
                case 0:
                coord_x=rel_x-25;
                    if(bol_iphone5)
                        coord_y=rel_y+230;
                    else
                        coord_y=rel_y+160;
                    break;
                case 1:
                    coord_x=rel_x+200;
                    coord_y=rel_y+200;
                    break;
                case 2:
                    coord_x=rel_x-10;
                    coord_y=rel_y-30;
                    break;
                default:
                    coord_x=0;
                    coord_y=0;
                    break;
                }
            }else{
                switch(index){
                    case 0:
                        coord_x=rel_x+75;
                        coord_y=rel_y-45;
                        break;
                    case 1:
                        coord_x=rel_x-15;
                        coord_y=rel_y;
                        break;
                    case 2:
                        coord_x=rel_x-45;
                        coord_y=rel_y+90;
                        break;
                    case 3:
                        coord_x=rel_x-05;
                        coord_y=rel_y+175;
                        break;
                    case 4:
                        coord_x=rel_x+180;
                        coord_y=rel_y+170;
                        break;
                    case 5:
                        coord_x=rel_x+210;
                        coord_y=rel_y+85;
                        break;
                    case 6:
                        coord_x=rel_x+80;
                        coord_y=rel_y+213;
                        break;
                    default:
                        coord_x=0;
                        coord_y=0;
                        break;
                }
            }
    }
    [orb setFrame: CGRectMake(coord_x,coord_y,orb_size,orb_size)];
}

-(void)PressedLargeOrb:(id)sender{
    NSLog(@"Pressed Large Orb");
    
    ViewController_PageScroll *tempScroll = (ViewController_PageScroll*)[self parentViewController];
    
    if([tempScroll PageInView]==0)
    {
        //Only allow the Overlay if at the current page
        ViewController_DevicesWithSideMenu *tempParent = (ViewController_DevicesWithSideMenu*)[[self parentViewController]parentViewController];
        
        [tempParent DisablePanning];
        
        //Initialize new View
        [_OrbOverlay ShowOverlay];
    }
}

-(void)DragLargeOrb:(id)sender WithEvent:(UIEvent*)event{
    NSSet *touches = [event touchesForView:sender];
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self.view];
    
    if(touchPoint.x<self.view.bounds.size.width/2-int_LargeOrbDetectionWidth)
       [_OrbOverlay HighlightConnect];
    else if(touchPoint.x>self.view.bounds.size.width/2+int_LargeOrbDetectionWidth)
        [_OrbOverlay HighlightDisconnect];
    else
        [_OrbOverlay FadeBoth];

}

//Because of overlay, once you move the touch, this orb will no longer be receive touch notification
-(void)LetGoLargeOrb:(id)sender WithEvent:(UIEvent*)event{
    NSLog(@"Let Go Large Orb");
    
    [_OrbOverlay DismissOverlay];
    
    if(event!=nil && sender!=nil)
    {
        NSSet *touches = [event touchesForView:sender];
        UITouch *touch = [touches anyObject];
        CGPoint touchPoint = [touch locationInView:self.view];

        if(touchPoint.x<self.view.bounds.size.width/2-int_LargeOrbDetectionWidth)
         [[DeviceManager sharedInstance]ConnectAll];
         else if(touchPoint.x>self.view.bounds.size.width/2+int_LargeOrbDetectionWidth)
         [[DeviceManager sharedInstance]DisconnectAll];
         else
         NSLog(@"Let go on orb, no action performed");    
    }
    ViewController_DevicesWithSideMenu *tempParent = (ViewController_DevicesWithSideMenu*)[[self parentViewController]parentViewController];
    
    [tempParent EnablePanning];
}


-(void)PressedSmallOrb:(id)sender{
    NSLog(@"Pressed Small Orb");
    if([sender isKindOfClass:[btn_SmallOrb class]])
    {
        [[DeviceManager sharedInstance]set_DetailsDevice:((btn_SmallOrb*)sender)._device];
        
        [((btn_SmallOrb*)sender)._device set_Hint:false];
        
        //Access Parent View to push to details view so that we only have 1 details viewcontroller
        UIViewController *tempController = [self parentViewController];
        while(![tempController isKindOfClass:[ViewController_DevicesWithSideMenu class]])tempController = [tempController parentViewController];
        
        [((ViewController_DevicesWithSideMenu*)tempController) PushToDetails];
    }
}

-(void)refreshDeviceView{
    //Called by MainController
    [self RefreshSmallOrbs];
}

-(void)RefreshSmallOrbs{
    
    if([[DeviceManager sharedInstance]_currentDevices].count == _OrbDevices.count)
    {
        for(int i=0;i<_OrbDevices.count;i++)
        {
            [((btn_SmallOrb*)[_OrbDevices objectAtIndex:i])updateImages];
        }
    }
    else
    {
        //Reset all orb positions if the number of devices has changed
        for(int i=0;i<_OrbDevices.count;i++)
        {
            [((btn_SmallOrb*)[_OrbDevices objectAtIndex:i])removeFromSuperview];
        }
        
        [_OrbDevices removeAllObjects];
        
        //Initialize the orbs
        for(int i=0;i<[[DeviceManager sharedInstance]_currentDevices].count;i++)
        {
            [self CreateOrbWithDevice: (Protag_Device*)[[[DeviceManager sharedInstance]_currentDevices]objectAtIndex:i] withIndex:i];
        }
    }
}

@end
