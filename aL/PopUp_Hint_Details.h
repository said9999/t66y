#import <Foundation/Foundation.h>

@interface PopUp_Hint_Details : NSObject{
    UIView *_popUpView;
    BOOL bol_DismissingView;
}

@property IBOutlet UIButton *btn_Skip;

+(id)sharedInstance;
-(void)showView;
-(void)dismissView;

@end
