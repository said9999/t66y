#import "ViewController_PageScroll.h"
#import "WarningManager.h"
#import "ViewController_TableDevices.h"
#import "ViewController_OrbDevices.h"

//This ViewController houses ViewController_TableDevices and ViewController_OrbDevices


@interface ViewController_PageScroll ()

@end

@implementation ViewController_PageScroll


@synthesize PageControl;
@synthesize PagesScrollView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView *tempView = [[[NSBundle mainBundle] loadNibNamed:@"View_PageScroll" owner:self options:nil]objectAtIndex:0];
    [self.view addSubview:tempView];
    
    [PagesScrollView setPagingEnabled:true];
    [PagesScrollView setDirectionalLockEnabled:true];
    [PagesScrollView setDelegate:self];
    [PageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
    
    //initalize the 2 views
    [self addChildViewController:[[ViewController_OrbDevices alloc]init]];
	[self addChildViewController:[[ViewController_TableDevices alloc]init]];

    bol_initializedPages = false;
    
    //Initalization
    numOfPages = [self.childViewControllers count];
    //Set number of pages for the scrollview
    PageControl.numberOfPages = numOfPages;
    PageBeforeChange = PageControl.currentPage;
    
    self.view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    tempView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);

    [self.view setAutoresizesSubviews:true];
    
    //This is the fix the 20px bug created by UINavigationController
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
        self.navigationController.navigationBar.translucent = NO;
        self.navigationController.navigationBar.barTintColor = [UIColor darkGrayColor];
        self.navigationController.navigationBar.titleTextAttributes = @{UITextAttributeTextColor : [UIColor whiteColor]};
    }
    else
        [self.view setFrame:CGRectOffset(self.view.frame, 0, -20)];
    
    
    [tempView setFrame:self.view.frame];
}

-(void)viewWillAppear:(BOOL)animated
{
    if(bol_initializedPages==false)
    {
        [PagesScrollView setContentSize: CGSizeMake(PagesScrollView.frame.size.width * [self.childViewControllers count], PagesScrollView.frame.size.height)];
        [PagesScrollView setFrame: CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)];
        
        for (NSUInteger i =0; i < [self.childViewControllers count]; i++) {
            [self loadScrollViewWithChildController:i];
        }
        
        [PageControl sendActionsForControlEvents:UIControlEventValueChanged];
        bol_initializedPages=true;
    }
    
    [super viewWillAppear:animated];
    
    
    //Notify current child controller viewWillAppear
    UIViewController *viewController = [self.childViewControllers objectAtIndex:PageControl.currentPage];
    if (viewController!=NULL)
        [viewController viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //Notify current child controller viewWillAppear
    UIViewController *viewController = [self.childViewControllers objectAtIndex:PageControl.currentPage];
	if (viewController != NULL)
		[viewController viewWillDisappear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    //Notify child controller viewWillAppear
    for(int i=0;i<numOfPages;i++)
    {
        UIViewController *viewController = [self.childViewControllers objectAtIndex:i];
        if (viewController != NULL)
            [viewController viewDidUnload];
    }
}

- (BOOL)automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers {
	return NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)loadScrollViewWithChildController:(int)index {
    if (index < 0 || index>=self.childViewControllers.count)
        return;
    
    UIViewController *controller = [self.childViewControllers objectAtIndex:index];
    
    if(controller==NULL)
    {
        NSLog(@"loadScrollViewWithPage had null controller");
        return;
    }
	
	// add the controller's view to the scroll view
    if (controller.view.superview == nil) {
        CGRect frame = PagesScrollView.frame;
        frame.origin.x = frame.size.width * index;
        frame.origin.y = 0;
        controller.view.frame = frame;
        [PagesScrollView addSubview:controller.view];
    }
}

#pragma mark - ScrollView delegate
-(void)scrollViewDidScroll:(UIScrollView *)sender {
    if([sender isEqual:PagesScrollView])
        [PageControl setCurrentPage:[self PageInView]];
    
    
    //This is to prevent the overlay from getting stuck on screen due to scrolling
    ViewController_OrbDevices *tempController = (ViewController_OrbDevices*)[self.childViewControllers objectAtIndex:0];
    
    [tempController LetGoLargeOrb:nil WithEvent:nil];
}


#pragma mark - PageControl action
-(void)changePage:(id)sender{
    // update the scroll view to the appropriate page
    CGRect frame;
    frame.origin.x = PagesScrollView.frame.size.width * PageControl.currentPage;
    frame.origin.y = 0;

    frame.size = PagesScrollView.frame.size;
    
    //Call the relevant child controllers
    UIViewController *PreviousViewController = NULL;
    if(PageBeforeChange>=0)
        PreviousViewController = [self.childViewControllers objectAtIndex:PageBeforeChange];
    if(PreviousViewController!=NULL)
        [PreviousViewController viewWillDisappear:true];
    UIViewController *CurrentViewController = NULL;
    if(PageControl.currentPage>=0)
        CurrentViewController = [self.childViewControllers objectAtIndex:PageControl.currentPage];
    if(CurrentViewController!=NULL)
        [CurrentViewController viewWillAppear:true];
    
    PageBeforeChange = PageControl.currentPage;
    [PagesScrollView scrollRectToVisible:frame animated:bol_initializedPages];
    
    if(PreviousViewController!=NULL)
        [PreviousViewController viewDidDisappear:true];
    if(CurrentViewController!=NULL)
        [CurrentViewController viewDidAppear:true];
}


-(int)PageInView{
    CGFloat pageWidth = PagesScrollView.frame.size.width;
    return floor((PagesScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    //The pageWidth divided by 2 is about 50% of the page in view
}

@end
