#import "ViewController_DevicesWithSideMenu.h"
#import "PopUp_Hint_DidYouKnow.h"
#import "DataManager.h"

//This view controller houses the ViewController_WarningMenu and ViewController_PageScroll


@interface ViewController_DevicesWithSideMenu ()

@end

@implementation ViewController_DevicesWithSideMenu

@synthesize btn_Warning;

-(id)init{
    
    self = [super init];
    
    CenterController = [[ViewController_PageScroll alloc]init];
    
    WarningMenu = [[ViewController_WarningMenu alloc]init];
    
    self = [super initWithCenterViewController:CenterController leftViewController:WarningMenu];
    
    if (self) {
        UIImage *animatedImage = [UIImage animatedImageWithImages: [[NSArray alloc]initWithObjects:[UIImage imageNamed:@"attention red.png"],[UIImage imageNamed:@"attention yellow.png"], nil] duration:1];
        
        ProtagDetailsController = [[ViewController_ProtagDetails alloc]init];
           
        btn_Warning = [[UIBarButtonItem alloc]initWithImage:animatedImage style:UIBarButtonItemStyleBordered target:self action:@selector(ToggleSideMenu)];
        [self setDelegate:self];
        
         self.title = @"PROTAG Elite";
        
        [self.view setAutoresizesSubviews:true];
        }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[WarningManager sharedInstance]registerObserver:self];
    [self UpdateVisibilityOfWarningMenuBtn];
  
    //For hint/wizard
    if([[DataManager sharedInstance]Hints_Step]==3){
        [[PopUp_Hint_DidYouKnow sharedInstance]showView];
        [[DataManager sharedInstance]setHints_Step:4];
        [[DataManager sharedInstance]save_Settings];
    }

}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[WarningManager sharedInstance]deregisterObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark delegate methods

- (void)viewDeckController:(IIViewDeckController*)viewDeckController willCloseViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated{
    [CenterController PagesScrollView].scrollEnabled=true;
  }

- (void)viewDeckController:(IIViewDeckController*)viewDeckController willOpenViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated{
    [CenterController PagesScrollView].scrollEnabled=false;
}

#pragma mark end of delegate methods

-(void)ToggleSideMenu{
    [self toggleLeftViewAnimated:true];
}

-(void)PushToDetails{
    NSLog(@"PushToDetails");
    [self.navigationController pushViewController:ProtagDetailsController animated:true];
}

-(void)UpdateVisibilityOfWarningMenuBtn{
    if([[WarningManager sharedInstance]_WarningList].count>0)
        //show the warning button
        ((UINavigationItem*)[self.navigationController.navigationBar.items objectAtIndex:0]).leftBarButtonItem=btn_Warning;
    else
        //hide warning button
        ((UINavigationItem*)[self.navigationController.navigationBar.items objectAtIndex:0]).leftBarButtonItem=NULL;
}

-(void)AlertEvent:(WarningEvents)event{
    [self UpdateVisibilityOfWarningMenuBtn];
}

@end
