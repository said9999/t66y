#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "PicturesControllerDelegate.h"
@interface CameraManager : NSObject{
	AVCaptureSession *session;
    PicturesControllerDelegate *delegate;
}

@property (nonatomic,retain) AVCaptureSession *session;

+ (CameraManager *)sharedCameraManager;
- (void)takePicture;
@end
