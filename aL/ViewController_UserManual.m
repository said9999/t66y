#import "ViewController_UserManual.h"

@interface ViewController_UserManual ()

@end

@implementation ViewController_UserManual


- (void)viewDidLoad
{
    [super viewDidLoad];

    UIWebView *webView = [[UIWebView alloc]initWithFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)];
	
    self.title = @"Help";
  
    NSString *thePath = [[NSBundle mainBundle] pathForResource:@"inAppHelp" ofType:@"htm"];
    if (thePath) {
        NSURL *url = [NSURL fileURLWithPath:thePath];
        NSURLRequest *rq = [NSURLRequest requestWithURL:url];
        [webView loadRequest:rq];
    }

    webView.delegate = self;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
        self.navigationController.navigationBar.translucent = NO;
        self.navigationController.navigationBar.barTintColor = [UIColor darkGrayColor];
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        self.navigationController.navigationBar.titleTextAttributes = @{UITextAttributeTextColor : [UIColor whiteColor]};
        //self.edgesForExtendedLayout = UIRectEdgeNone;
    }

    [self.view addSubview:webView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
