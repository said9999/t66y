#import <Foundation/Foundation.h>
#include <CoreMotion/CoreMotion.h>
#import "Protag_Device.h"

@protocol FinderObserver <NSObject>
- (void) newDirection:(double)degree;
@end

@interface DeviceFinder : NSObject{
    NSTimer *_UpdateTimer;
    double _UpdateFrequency;
    int _GridSize;
    NSMutableArray *_GridReward;
    int _currentXindex;
    int _currentYindex;
    int _currentStateRSSI;
    double _targetDirection;
}

@property (nonatomic) CMMotionManager *_MotionManager;
@property (nonatomic) Protag_Device *_device;
@property (nonatomic) id<FinderObserver> _Observer;
@property (nonatomic) double _CurrentDirection;

-(void)StartSearching;
-(void)StopSearching;

@end