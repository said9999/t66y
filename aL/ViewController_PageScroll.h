#import <UIKit/UIKit.h>
#import "IIViewDeckController.h"

//Includes WarningMenu

@interface ViewController_PageScroll : UIViewController<UIScrollViewDelegate>{
    NSInteger numOfPages;
    NSInteger PageBeforeChange;
    bool bol_initializedPages;
}

@property IBOutlet UIScrollView *PagesScrollView;
@property IBOutlet UIPageControl *PageControl;

-(void)changePage:(id)sender;
-(void)loadScrollViewWithChildController:(int)index;
-(int)PageInView;

@end
