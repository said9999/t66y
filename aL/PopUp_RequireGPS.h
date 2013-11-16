#import <Foundation/Foundation.h>

@interface PopUp_RequireGPS : NSObject{
    UIView *_popUpView;
    BOOL bol_DismissingView;
}

@property IBOutlet UIButton *btn_Ok;

+(id)sharedInstance;
-(void)showView;
-(void)dismissView;

@end
