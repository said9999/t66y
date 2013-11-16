#import <Foundation/Foundation.h>
#import "FencingData.h"

@protocol FencingObserver <NSObject>
- (void) refreshView;
@end

@interface FencingManager : NSObject{
    FencingData *_TempData;
}

@property (nonatomic) NSMutableArray *_FencingList;
@property (nonatomic) NSMutableArray *_ObserverList;
@property (nonatomic) FencingData *_CurrentViewFence;

+(id)sharedInstance; //Singleton
//update current region before using this function to add
-(void)addCurrentRegion;
-(void)removeRegion:(int)index;
-(void)updateCurrentRegion:(FencingData*)region;
-(FencingData*)getCurrentRegion;
-(void)registerObserver:(id<FencingObserver>) Observer;
-(void)deregisterObserver:(id<FencingObserver>) Observer;

@end
