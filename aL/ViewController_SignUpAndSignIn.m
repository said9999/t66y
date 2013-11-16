#import "ViewController_SignUpAndSignIn.h"
#import "PopUp_Processing.h"
#import "PopUp_RequireGPS.h"
#import "DataManager.h"
#import "GPSManager.h"
#import "AccountManager.h"

@interface ViewController_SignUpAndSignIn ()<UITextFieldDelegate>
@end


@implementation ViewController_SignUpAndSignIn

NSInteger numberOfViews = 2;

+(id)sharedInstance{
    static ViewController_SignUpAndSignIn *_instance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self MainView];
    
    if([[DataManager sharedInstance]Hints_Step] == -1){
        [[DataManager sharedInstance]setHints_Step:0];
        [[DataManager sharedInstance]save_Settings];
    }

    //This is the fix the 20px bug created by UINavigationController
  //  [self.view setFrame:CGRectOffset(self.view.frame, 0, -20)];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
        self.navigationController.navigationBar.translucent = NO;
        self.navigationController.navigationBar.barTintColor = [UIColor darkGrayColor];
        self.navigationController.navigationBar.titleTextAttributes = @{UITextAttributeTextColor : [UIColor whiteColor]};
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(void)addInRegisterView
{
    RegisterView = [[[NSBundle mainBundle]loadNibNamed:@"View_SignUpAndSignIn" owner:self options:nil]objectAtIndex:2];
    if(self.view == mobileView)
        [RegisterView setFrame:CGRectMake(self.view.frame.size.width,0,self.view.frame.size.width,self.view.frame.size.height)];
    else
        [RegisterView setFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)];
    txtEmail = (UITextField *) [RegisterView viewWithTag:6];
    txtPassword =(UITextField *)[RegisterView viewWithTag:7];
    txtConfirmPassword = (UITextField *)[RegisterView viewWithTag:8];
    
    btnRegister = (UIButton *)[RegisterView viewWithTag:9];
    [btnRegister addTarget:self action:@selector(performRegister:) forControlEvents:UIControlEventTouchUpInside];
    
    btnSkip = (UIButton *)[RegisterView viewWithTag:15];
    [btnSkip addTarget:self action:@selector(pressedSkip) forControlEvents:UIControlEventTouchUpInside];
    
    lblExistUser = (UILabel *)[RegisterView viewWithTag:10];
	[lblExistUser addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(lblExistUserTap)]];

    lblRegistration = (UILabel *)[RegisterView viewWithTag:16];

    if(self.view == mobileView)
    {
        btnSkip.hidden = true;
        [lblExistUser setFrame:CGRectMake(72, 235, 180, 20)];
    }
    else
        lblRegistration.hidden = true;

    [txtEmail setDelegate:self];
    [txtPassword setDelegate:self];
    [txtConfirmPassword setDelegate:self];
    
    [txtPassword setSecureTextEntry:true];
    [txtConfirmPassword setSecureTextEntry:true];
    
    [txtEmail setReturnKeyType:UIReturnKeyNext];
    [txtPassword setReturnKeyType:UIReturnKeyNext];
    [txtConfirmPassword setReturnKeyType:UIReturnKeyDone];
    
    [scrollView addSubview:RegisterView];
}

-(void)addInLoginView
{
    LoginView = [[[NSBundle mainBundle]loadNibNamed:@"View_SignUpAndSignIn" owner:self options:nil]objectAtIndex:3];
    if(self.view == mobileView)
        [LoginView setFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)];
    else
        [LoginView setFrame:CGRectMake(self.view.frame.size.width,0,self.view.frame.size.width,self.view.frame.size.height)];
    txtEmailLogin = (UITextField *) [LoginView viewWithTag:11];
    txtPasswordLogin = (UITextField *) [LoginView viewWithTag:12];
    btnLogin = (UIButton *) [ LoginView viewWithTag:13];

    [btnLogin addTarget:self action:@selector(loginButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    lblNewUser = (UILabel *)[LoginView viewWithTag:14];
	[lblNewUser addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(lblNewUserTap)]];
    
    lblLogin = (UILabel *)[LoginView viewWithTag:17];
    
    if(self.view != mobileView)
    {
        lblLogin.hidden = true;
    }
    
    [txtEmailLogin setDelegate:self];
    [txtPasswordLogin setDelegate:self];
    
    [txtPasswordLogin setSecureTextEntry:true];
    
    [txtEmailLogin setReturnKeyType:UIReturnKeyNext];
    [txtPasswordLogin setReturnKeyType:UIReturnKeyDone];
   
    [scrollView addSubview:LoginView];
}

// Register View Methods
- (void)performRegister:(UIButton *)sender {
    [RegisterView endEditing:true];
    
    NSCharacterSet *lowercaseLetters = [NSCharacterSet lowercaseLetterCharacterSet];
    NSCharacterSet *uppercaseLetters = [NSCharacterSet uppercaseLetterCharacterSet];
    NSCharacterSet *numbers = [NSCharacterSet decimalDigitCharacterSet];
 
    //Input checks
    if(![[AccountManager sharedAccountManager]hasInternetConnection]){
        //Check for data connection
        [self showAlert:@"Registration Failed" withMessage:@"Data Connection is required, please switch on your Cellular Data / WIFI"];
        return;
    }else if(txtEmail.text.length==0 || txtPassword.text.length==0){
        //Check for Email and Password field cannot be empty
        [self showAlert:@"Registration Failed" withMessage:@"Email and Password field cannot be empty"];
        return;
    }else if([txtEmail.text rangeOfString:@"@"].location == NSNotFound  || [txtEmail.text rangeOfString:@"."].location == NSNotFound){
        //Check that email is valid with @ and .
        [self showAlert:@"Registration Failed" withMessage:@"Please enter a Valid Email Address"];
        return;
    }else if(![txtPassword.text isEqualToString:txtConfirmPassword.text]){
        //Check that both Password and Confirm password is the same
        [self showAlert:@"Registration Failed" withMessage:@"Password and Confirm Password field does not match"];
        return;
	}else if([txtPassword.text length] > 25 || ([txtPassword.text rangeOfCharacterFromSet:lowercaseLetters].location == NSNotFound && [txtPassword.text rangeOfCharacterFromSet:uppercaseLetters].location == NSNotFound) || [txtPassword.text rangeOfCharacterFromSet:numbers].location == NSNotFound){
        //Check that Password less than or equal to 8 alpha numeric characters
        [self showAlert:@"Registration Failed" withMessage:@"Password need to be at least eight characters and alphanumeric"];
    return;
    }
  
    [[PopUp_Processing sharedInstance]showView];
    
	NSDictionary *param = [[NSDictionary alloc] initWithObjectsAndKeys:@"register",@"action",txtEmail.text,@"email",txtPassword.text,@"password",[[AccountManager sharedAccountManager]getCurrentDate],@"dateCreate",nil];
    
	[[AccountManager sharedAccountManager] userRegisterWithInfo:param];
}

-(void)registerSucceed:(NSNotification *)notification
{
    NSLog(@"Registration Succeeded!");
    
    if([self.view superview]!=NULL)
        [self.view removeFromSuperview];

    [[PopUp_Processing sharedInstance]dismissView];
    
    //For hint/wizard
    if([[DataManager sharedInstance]Hints_Step]==0){
        [[PopUp_RequireGPS sharedInstance]showView];
#warning to test the add button will still glow
        [[DataManager sharedInstance]setHints_Step:1];
        [[DataManager sharedInstance]save_Settings];
    }
    
    [txtEmailLogin setText:[[AccountManager sharedAccountManager]str_Email]];
    
    [self showAlert:@"Registration Success" withMessage:[NSString stringWithFormat:@"Registration was successful, you will receive an activation mail shortly at %@",[[AccountManager sharedAccountManager]str_Email]]];

    if(self.view == mobileView){
        UITabBarController *MyTabController = (UITabBarController *)[[UIApplication sharedApplication] delegate].window.rootViewController;
        [MyTabController setSelectedIndex:0];
        [MyTabController setSelectedIndex:1];
    }

}

-(void)registerFail:(NSNotification *)notification
{
    NSLog(@"Registration Failed!");
    [[PopUp_Processing sharedInstance]dismissView];
    
    [self showAlert:@"Registration Failed" withMessage:@"Username already exist in database, please try again with another username"];
}

-(void)lblExistUserTap
{
	DLog(@"Tap Already a Protag User");
    if(self.view == mobileView)
        [scrollView scrollRectToVisible:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) animated:YES];
    else
        [scrollView scrollRectToVisible:CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height) animated:YES];
    
}

// For Login View Methods
-(void)loginButtonPressed:(UIButton *)sender {
    [LoginView endEditing:true];
    
    NSLog(@"%@ %@",txtEmailLogin.text, txtPasswordLogin.text);
    //Check Inputs
    if(![[AccountManager sharedAccountManager]hasInternetConnection]){
        //Check for data connection
        [self showAlert:@"Login Failed" withMessage:@"Data Connection is required, please switch on your Cellular Data / WIFI"];
        return;
    }else if(txtEmailLogin.text.length==0 || txtPasswordLogin.text.length==0){
        //Check that Email and password field is not empty
        [self showAlert:@"Login Failed" withMessage:@"Email and Password field cannot be empty"];
        return;
    }else if([txtEmailLogin.text rangeOfString:@"@"].location == NSNotFound  || [txtEmailLogin.text rangeOfString:@"."].location == NSNotFound){
        //Check that Email has . and @
        [self showAlert:@"Login Failed" withMessage:@"Please enter a Valid Email Address"];
        return;
    }
    
	NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:@"login",@"action",txtEmailLogin.text,@"email",txtPasswordLogin.text,@"password",@"iOS",@"typePhone",nil];
    [[AccountManager sharedAccountManager] userLoginWithInfo:userInfo];
    [[PopUp_Processing sharedInstance]showView];
}

-(void)loginSucceeded:(NSNotification *)notification
{
    NSLog(@"Login Successful");
    
    if([self.view superview]!=NULL)
        [self.view removeFromSuperview];

    [[PopUp_Processing sharedInstance]dismissView];
    if(self.view == mobileView){
        UITabBarController *MyTabController = (UITabBarController *)[[UIApplication sharedApplication] delegate].window.rootViewController;
        [MyTabController setSelectedIndex:0];
        [MyTabController setSelectedIndex:1];
    }
}

-(void)loginFailed:(NSNotification *)notification
{
    NSLog(@"Login Failed");

    [[PopUp_Processing sharedInstance]dismissView];
    //Login fail alert will be processed by AccountManager
}

-(void)lblNewUserTap
{
	DLog(@"Tap New User");
    if(self.view == mobileView)
        [scrollView scrollRectToVisible:CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height) animated:YES];
    else
        [scrollView scrollRectToVisible:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) animated:YES];
    
 }

#pragma marks - Keyboard utilities functions
- (UIView *)firstResponderWithin:(UIView *)view {
    
    if ([view isFirstResponder]) return view;
    
    for (UIView *subview in view.subviews) {
        UIView *answer = [self firstResponderWithin:subview];
        if (answer) return answer;
    }
    return nil;
}
- (void)keyboardDidShow:(NSNotification *)notification {
    
    CGRect keyboardFrameW = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    CGRect keyboardFrame = [window convertRect:keyboardFrameW toView:self.view];
	
    // put the bottom of the login button's frame just above the top of the keyboard
    CGFloat signupButtonBottom = 0;
    CGFloat targetBottom = 0;
    
    if(self.view != mobileView)
        signupButtonBottom = CGRectGetMaxY(btnRegister.frame);
    else
        signupButtonBottom = CGRectGetMaxY(btnLogin.frame);
    if(self.view != mobileView)
        targetBottom = keyboardFrame.origin.y - 210.0;
    else
        targetBottom = keyboardFrame.origin.y - 20.0;
    
    offsetY = MAX(0.0, signupButtonBottom - targetBottom);
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame = CGRectOffset(self.view.frame, 0.0, -offsetY);
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    [UIView animateWithDuration:0.3 animations:^{
		self.view.frame = CGRectOffset(self.view.frame, 0.0, offsetY);
    }];
}

- (void)swiped:(UISwipeGestureRecognizer *)gr {
    
    UIView *firstResponder = [self firstResponderWithin:self.view];
    [firstResponder resignFirstResponder];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if([textField returnKeyType]==UIReturnKeyDone)
    {
        [textField resignFirstResponder];
        return NO;
    }
    else{
        //Easy navigation for user
        if(textField==txtEmail)
            [txtPassword becomeFirstResponder];
        else if(textField==txtPassword)
            [txtConfirmPassword becomeFirstResponder];
        else if(textField==txtEmailLogin)
            [txtPasswordLogin becomeFirstResponder];
        return NO;
    }
    return YES;
}

-(void)pressedSkip{
    if(self.view.superview!=NULL)
        [self.view removeFromSuperview];
  
    //For hint/wizard
    if([[DataManager sharedInstance]Hints_Step]==0){
        [[PopUp_RequireGPS sharedInstance]showView];
#warning to test the add button will still glow
        [[DataManager sharedInstance]setHints_Step:1];
        [[DataManager sharedInstance]save_Settings];
    }
}

-(void)MobileView{
    
    mobileView = [[[NSBundle mainBundle]loadNibNamed:@"View_SignUpAndSignIn" owner:self options:nil]objectAtIndex:1];
   // [mobileView setFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)];
    [self setView:mobileView];
    mobileView.tag = 10;
    scrollView = (UIScrollView *)[mobileView viewWithTag:16];
    [scrollView setFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)];
    scrollView.pagingEnabled = YES;
    scrollView.scrollEnabled = NO;
    [scrollView setContentSize:CGSizeMake(self.view.frame.size.width * numberOfViews,self.view.frame.size.height)];
    self.title = @"Mobile";
    
    [self addInLoginView];
    [self addInRegisterView];
   
    [self addNotification];
}

-(void)MainView{
    
    mainView = [[[NSBundle mainBundle] loadNibNamed:@"View_SignUpAndSignIn" owner:self options:nil]objectAtIndex:0];
    [mainView setFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height+120)];
    [self setView:mainView];
    
    scrollView = (UIScrollView *)[mainView viewWithTag:1];
   [scrollView setFrame:CGRectMake(0,140,self.view.frame.size.width,self.view.frame.size.height)];
    scrollView.pagingEnabled = YES;
    scrollView.scrollEnabled = NO;
    [scrollView setContentSize:CGSizeMake(self.view.frame.size.width * numberOfViews,self.view.frame.size.height)];
 
    [self addInRegisterView];
    [self addInLoginView];
    
    [self addNotification];
}

-(void)addNotification{
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    //For Registration
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"registerSucceed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registerSucceed:) name:@"registerSucceed" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"registerFail" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registerFail:) name:@"registerFail" object:nil];
    
    // For Login
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"LoginSucceeded" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSucceeded:) name:@"loginSucceeded" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"LoginFailed" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginFailed:) name:@"loginFailed" object:nil];
    
    //Keyboard shown
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    // add a swipe down gesture to drop first responder
    UISwipeGestureRecognizer *swipeGR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swiped:)];
    [swipeGR setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.view addGestureRecognizer:swipeGR];
    
 //   [self dataSourceAvailableAlert];
    
    self.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    [self.view setAutoresizesSubviews:true];

}

-(void)showAlert:(NSString*)title withMessage:(NSString*)message{
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

@end
