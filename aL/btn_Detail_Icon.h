#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//Large button used in details

@interface btn_Detail_Icon : UIButton{
    UIImageView *img_Icon;
    UILabel *lbl_Name;
    UILabel *lbl_Status;
    double imgSize;
    double btnHeight;
    double btnWidth;
    double spacing;
    double lblNameSize;
    double lblStatusSize;
}

-(id)init;
-(void)refresh:(NSString*)status;//refresh status only
-(void)refresh:(NSString*)name andStatus: (NSString*)status;//refresh text only
-(void)refresh:(UIImage*)image andName: (NSString*)name andStatus: (NSString*)status;//refresh text and change image
-(void)setX:(double)x andY:(double)y;

@end