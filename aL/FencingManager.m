#import "FencingManager.h"
#import "DataManager.h"
#import "GPSManager.h"
#import "DeviceManager.h"

@implementation FencingManager

@synthesize _FencingList;
@synthesize _ObserverList;
@synthesize _CurrentViewFence;

//Singleton
+(id)sharedInstance{
    static FencingManager *_instance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

-(id)init{
    self = [super init];
    if(self){
        _FencingList = [[DataManager sharedInstance]load_Secure_Geofencing];
        _ObserverList = [[NSMutableArray alloc]init];
        _TempData = NULL;
        _CurrentViewFence = NULL;
    }
    return self;
}

-(void)addRegion:(FencingData*)region{
    #warning do not let them add too many regions
    [_FencingList addObject:region];
    [[DataManager sharedInstance]save_Secure_Geofencing];
    [self refreshObservers];
    [[GPSManager sharedInstance]StartMonitoring:region];
    [[DeviceManager sharedInstance]SecureZone_On];
}

-(void)addCurrentRegion{
    [self addRegion:_TempData];
    _TempData=NULL;
}

-(void)removeRegion:(int)index{
    if(index>=0 && index<_FencingList.count){
        NSLog(@"Removing Region");
        [[GPSManager sharedInstance]StopMonitoring:(FencingData*)[_FencingList objectAtIndex:index]];
        
        [_FencingList removeObjectAtIndex:index];
        [[DataManager sharedInstance]save_Secure_Geofencing];
        [[GPSManager sharedInstance]CheckForGeofence];
        [self refreshObservers];
    }
    
    //For Bug fix due to sometimes it does not remove them properly
    if(_FencingList.count==0){
        [[GPSManager sharedInstance]StopMonitoringAll];
        [[DeviceManager sharedInstance]SecureZone_Off];
    }
}

-(void)registerObserver:(id<FencingObserver>)Observer{
    if(![_ObserverList containsObject:Observer])
       [_ObserverList addObject:Observer];
}

-(void)deregisterObserver:(id<FencingObserver>)Observer{
    if([_ObserverList containsObject:Observer])
        [_ObserverList removeObject:Observer];
}

-(void)refreshObservers{
    for(int i=0;i<_ObserverList.count;i++)
        [(id<FencingObserver>)[_ObserverList objectAtIndex:i]refreshView];
}

-(void)updateCurrentRegion:(FencingData*)region{
    _TempData=region;
    [self refreshObservers];
}

-(FencingData*)getCurrentRegion{
    return _TempData;
}


@end
