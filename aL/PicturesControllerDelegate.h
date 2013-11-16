#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface PicturesControllerDelegate : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic) NSMutableArray *pictures;
@property (nonatomic) NSObject *targetObject;
@property (nonatomic) AVCaptureSession *_session;

-(id)initWithSession:(AVCaptureSession*)session onTarget:(id)target;

@end
