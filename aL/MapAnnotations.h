#import <Foundation/Foundation.h>
#import <MapKit/MKAnnotation.h>

@interface MapAnnotations : NSObject <MKAnnotation>{
    CLLocationCoordinate2D coordinate;
    NSString *title;
    NSString *subtitle;
}

//These properties are from the protocol, please do not rename them
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

@end
