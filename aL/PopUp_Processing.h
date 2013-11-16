#import <Foundation/Foundation.h>

@interface PopUp_Processing : NSObject{
    UIView *_popUpView;
    BOOL bol_DismissingView;
    NSTimer *timer;
}

+(id)sharedInstance;
-(void)showView;
-(void)dismissView;


@end
