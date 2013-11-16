#import <UIKit/UIKit.h>

@interface ViewController_SignUpAndSignIn : UIViewController
{
    UIView *mainView;
    UIView *mobileView;
    UIView *RegisterView;
    UITextField *txtEmail;
    UITextField *txtPassword;
    UITextField *txtConfirmPassword;
    UIButton *btnRegister;
    UILabel *lblExistUser;
    UILabel *lblRegistration;
    UIView *LoginView;
    UITextField *txtEmailLogin;
    UITextField *txtPasswordLogin;
    UIButton *btnLogin;
    UILabel *lblNewUser;
    UIButton *btnSkip;
    UILabel *lblLogin;
    UIScrollView *scrollView;
    CGFloat offsetY;
}

+(id)sharedInstance;//Singleton
-(void)addInRegisterView;
-(void)addInLoginView;
//-(void)dataSourceAvailableAlert;
-(void)pressedSkip;
-(void)MobileView;
-(void)MainView;
-(void)loginButtonPressed:(UIButton *)sender;
-(void)loginSucceeded:(NSNotification*)notification;
-(void)loginFailed:(NSNotification*)notification;
-(void)lblNewUserTap;
- (void)performRegister:(UIButton *)sender;
-(void)registerSucceed:(NSNotification *)notification;
-(void)registerFail:(NSNotification *)notification;
-(void)lblExistUserTap;
- (UIView *)firstResponderWithin:(UIView *)view;
- (void)keyboardDidShow:(NSNotification *)notification;
- (void)keyboardWillHide:(NSNotification *)notification;
- (void)swiped:(UISwipeGestureRecognizer *)gr;
-(void)addNotification;


@end
