#import "btn_Detail_Icon.h"

@implementation btn_Detail_Icon

-(id)init{
    if (self = [super init]) {
        //tweak values here to change the button size and stuff
        btnHeight=110;
        btnWidth=170;
        imgSize = 60;
        spacing = 8;
        lblNameSize = 12;
        lblStatusSize = 11;
        
        [self setFrame:CGRectMake(0,0,btnWidth,btnHeight)];
        
        img_Icon = [[UIImageView alloc] initWithFrame:CGRectMake((btnWidth-imgSize)/2, (btnHeight-imgSize)/2-lblStatusSize/2-lblNameSize/2-spacing, imgSize, imgSize)];
        [self addSubview:img_Icon];
        
        lbl_Name = [[UILabel alloc] initWithFrame:CGRectMake(0, btnHeight-lblStatusSize-lblNameSize-spacing*2, btnWidth,lblNameSize+spacing)];
        lbl_Name.textColor = [UIColor whiteColor];
        lbl_Name.backgroundColor = [UIColor clearColor];
        lbl_Name.textAlignment = NSTextAlignmentCenter;
        lbl_Name.font = [UIFont boldSystemFontOfSize:lblNameSize];
        [self addSubview:lbl_Name];
        
        lbl_Status = [[UILabel alloc] initWithFrame:CGRectMake(0, btnHeight-lblStatusSize-spacing, btnWidth,lblStatusSize+spacing)];
        lbl_Status.textColor = [UIColor whiteColor];
        lbl_Status.backgroundColor = [UIColor clearColor];
        lbl_Status.textAlignment = NSTextAlignmentCenter;
        lbl_Status.font = [UIFont fontWithName:@"Symbol" size:lblStatusSize];
        [self addSubview:lbl_Status];
        
        //button animation
        [self addTarget:self action:@selector(buttonUp) forControlEvents:UIControlEventTouchUpInside];
        [self addTarget:self action:@selector(buttonUp) forControlEvents:UIControlEventTouchUpOutside];
        [self addTarget:self action:@selector(buttonDown) forControlEvents:UIControlEventTouchDown];
    }
    
    return self;   
}

-(void)refresh:(NSString*)status{
    [lbl_Status setText:status];
}

-(void)refresh:(NSString*)name andStatus: (NSString*)status{
    [lbl_Name setText:name];
    [self refresh:status];
}

-(void)refresh:(UIImage*)image andName: (NSString*)name andStatus: (NSString*)status{
    [img_Icon setImage:image];
    [self refresh:name andStatus:status];
}

-(void)setX:(double)x andY:(double)y{
    [self setFrame:CGRectMake(x,y,self.frame.size.width,self.frame.size.height)];
}

-(void)buttonDown{
    NSLog(@"buttonDown");
    double sizeIncrease = 20;

    [img_Icon setFrame:CGRectMake((btnWidth-imgSize-sizeIncrease)/2, (btnHeight-imgSize-sizeIncrease)/2-lblStatusSize/2-lblNameSize/2-spacing, imgSize+sizeIncrease, imgSize+sizeIncrease)];
}

-(void)buttonUp{
    NSLog(@"buttonUp");
    
    [img_Icon setFrame:CGRectMake((btnWidth-imgSize)/2, (btnHeight-imgSize)/2-lblStatusSize/2-lblNameSize/2-spacing, imgSize, imgSize)];
}

@end
