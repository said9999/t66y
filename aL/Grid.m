#import "Grid.h"

@implementation Grid

@synthesize _indexX;
@synthesize _indexY;
@synthesize _Reward;

-(id)init{
    if(self = [super init])
    {
        _Reward=0;
        _indexY=0;
        _indexX=0;
    }
    return self;
}

@end
