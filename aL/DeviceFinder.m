#import "DeviceFinder.h"
#import "DeviceManager.h"
#import "Grid.h"

@implementation DeviceFinder

@synthesize _device;
@synthesize _MotionManager;
@synthesize _CurrentDirection;
@synthesize _Observer;

-(id)init{
    self = [super init];
    if(self){
        _MotionManager = [[CMMotionManager alloc]init];
        _UpdateTimer = NULL;
        //need to be this fast to update direction to go when user is turning, not relative to RSSI update speed
        _UpdateFrequency = 0.25;
        _GridReward = [[NSMutableArray alloc]init];
        _GridSize = 91;
        _targetDirection = 0;
    }
    return self;
}

-(void)ScheduleUpdate:(double)interval{
    NSLog(@"DeviceFinder ScheduleUpdate");
    [_MotionManager setDeviceMotionUpdateInterval:interval];
    if(_UpdateTimer!=NULL)
    {
        [_UpdateTimer invalidate];
        _UpdateTimer=NULL;
    }
    
    _UpdateTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(UpdateMotion) userInfo:nil repeats:true];
}

-(void)UpdateMotion{
    if(_device==NULL || [_device get_StatusCode]!=STATUS_CONNECTED){
        [self StopSearching];
        return;
    }
    
    //treat 0 as pointing right of the grid map
    
    //yaw in degrees only gives -180 to 180, once it passes 180, it goes to -180
    //Radian to Degrees
    _CurrentDirection = _MotionManager.deviceMotion.attitude.yaw * 180/M_PI;
    
    //This is to make it 0 to 360
    //Anti-clockwise
    if(_CurrentDirection<0)
        _CurrentDirection+=360;
    
    double newRSSI = [_device get_RSSI];

    _currentStateRSSI = newRSSI;
    
    [self simulateMovement:_CurrentDirection];
    [self decreaseAllRewards];
    [self generateNewRewards:_currentStateRSSI];
    
    //get grid that has the highest reward
    Grid* highestGrid = [self getHighestGrid];
    
    _targetDirection = [self getDirectionTo:highestGrid];
    
    double newDirection = _CurrentDirection-_targetDirection;
    if(newDirection<0)
        newDirection+=360;
    
    if(_Observer!=NULL)
        [_Observer newDirection:newDirection];
}

-(void)resetRewards{
    NSLog(@"DeviceFinder resetRewards");
    [_GridReward removeAllObjects];
    for(int i=0;i<_GridSize;i++)
    {
        NSMutableArray *tempArray = [[NSMutableArray alloc]init];
        [_GridReward addObject: tempArray];
        for(int k=0;k<_GridSize;k++)
        {
            Grid *tempGrid = [[Grid alloc]init];
            [tempGrid set_indexY:i];
            [tempGrid set_indexX:k];
            [tempArray addObject:tempGrid];
        }
    }
}

//Decrease all grid rewards by reducing it by a certain percentage
-(void)decreaseAllRewards{
    NSLog(@"DeviceFinder decreaseAllRewards");
    for(int i=0;i<_GridSize;i++)
    {
        NSMutableArray *tempArray = [_GridReward objectAtIndex: i];
        
        for(int k=0;k<_GridSize;k++)
        {
            Grid *tempGrid = [tempArray objectAtIndex: k];
            [tempGrid set_Reward:tempGrid._Reward*0.95];
        }
    }
}

//Increase the reward for the grid at RSSI distance
-(void)generateNewRewards:(int)RSSI{
    //assuming RSSI is 0 (closest) to -90 (furthest)
    int index = abs(RSSI);
    
    for(int y=_currentYindex-index;y<=_currentYindex+index;y++)
    {
        if(y!=_currentYindex-index || y!=_currentYindex+index || y<0 || y>10)
            continue;
        NSMutableArray *tempArray = [_GridReward objectAtIndex: y];
        
        for(int x=_currentXindex-index;x<=_currentXindex+index;x++)
        {
            if(x!=_currentXindex-index || x!=_currentXindex+index || x<0 || x>10)
                continue;
        
            Grid *tempGrid = [tempArray objectAtIndex: x];
            //add 13 to reward
            [tempGrid set_Reward:tempGrid._Reward+20];
        }
    }
}

//Get the grid with the highest reward
-(Grid*)getHighestGrid{
    NSMutableArray *highestArray = [[NSMutableArray alloc]init];
    
    for(int i=0;i<_GridSize;i++)
    {
        NSMutableArray *tempArray = [_GridReward objectAtIndex:i];
        for(int k=0;k<_GridSize;k++)
        {
            Grid *tempGrid = [tempArray objectAtIndex: k];
            
            if(highestArray.count==0)
               [highestArray addObject:tempGrid];
            else
            {
                if(tempGrid._Reward > ((Grid*)[highestArray lastObject])._Reward){
                    [highestArray removeAllObjects];
                    [highestArray addObject:tempGrid];
                }
                else if(tempGrid._Reward == ((Grid*)[highestArray lastObject])._Reward){
                    [highestArray addObject:tempGrid];
                }
            }
        }
    }
    
    int index = highestArray.count/2;
    return [highestArray objectAtIndex:index];
}


-(void)simulateMovement:(double)direction{
    //simulate movement
    //45 degrees for each grid around
    //anti-clockwise
    //0 is to the right
    NSLog(@"DeviceFinder simulateMovement");
    
    if(direction>= 337.5  || direction< 22.5)
        _currentXindex++;
    else if(direction >=22.5 && direction < 67.5)
    {
        _currentXindex++;
        _currentYindex--;
    }
    else if(direction >=67.5 && direction<112.5)
        _currentYindex--;
    else if(direction >=112.5 && direction<157.5)
    {
        _currentXindex--;
        _currentYindex--;
    }
    else if(direction >=157.5 && direction<202.5)
        _currentXindex--;
    else if(direction >=202.5 && direction<247.5)
    {
        _currentXindex--;
        _currentYindex++;
    }
    else if(direction >=247.5 && direction<292.5)
        _currentYindex++;
    else if(direction >=292.5 && direction<337.5)
    {
        _currentYindex++;
        _currentXindex++;
    }
    
    if(_currentXindex<0)
        _currentXindex=0;
    else if(_currentXindex>=_GridSize)
        _currentXindex=_GridSize-1;
    
    if(_currentYindex<0)
        _currentYindex=0;
    else if(_currentYindex>=_GridSize)
        _currentYindex=_GridSize-1;
}

-(double)getDirectionTo:(Grid*)grid{
    int diffX= grid._indexX - _currentXindex;
    int diffY= _currentYindex - grid._indexY;
    
    double tempDirection = atan2(diffY,diffX) * 180/M_PI;
    if(tempDirection<0)
        tempDirection+=360;
    return tempDirection;
}

-(void)StartSearching{
    NSLog(@"DeviceFinder startSearching");
    [_MotionManager startDeviceMotionUpdates];
    _device = [[DeviceManager sharedInstance]_DetailsDevice];
    [self ScheduleUpdate:_UpdateFrequency];
    [self resetRewards];
    _currentXindex=5;
    _currentYindex=5;
    _currentStateRSSI=[_device get_RSSI];
    _CurrentDirection = _MotionManager.deviceMotion.attitude.yaw * 180/M_PI;
    
    //This is to make it 0 to 360
    //Anti-clockwise
    if(_CurrentDirection<0)
        _CurrentDirection+=360;
    
    _targetDirection=_CurrentDirection;
}

-(void)StopSearching{
    NSLog(@"DeviceFinder stopSearching");
    [_MotionManager stopDeviceMotionUpdates];
    _device = NULL;
    if(_UpdateTimer!=NULL)
    {
        [_UpdateTimer invalidate];
        _UpdateTimer=NULL;
    }
}

@end