#import "CameraManager.h"
#import "HTTPClient.h"
#import "AccountManager.h"
#import <AVFoundation/AVFoundation.h>

@implementation CameraManager
@synthesize session;

+ (CameraManager *)sharedCameraManager {
    static dispatch_once_t pred;
    static CameraManager *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[CameraManager alloc] init];
    });
    return sharedInstance;
}

-(void)sendImage:(NSNotification *)notification
{
	if([[notification name] isEqualToString:@"imageReady"]){
		UIImage *image = [[notification userInfo] objectForKey:@"image"];
        image = [self fixrotation:image];
		NSData *dataToUpload = UIImageJPEGRepresentation(image, 1.0);
        
        NSString *strToUpload = [self base64forData:dataToUpload];
        NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:@"okImageCapUpload",@"action",@"iOS",@"typePhone",[[AccountManager sharedAccountManager]str_RegID],@"regID",strToUpload,@"image",[[AccountManager sharedAccountManager]str_Email],@"email",nil];
        
        NSLog(@"Sending image: %@",userInfo);
        
        [[HTTPClient sharedHTTPClient] queryServerPath:@"phoneUpload.php" parameters:userInfo success:^(id jsonObject) {
            NSLog(@"Image send succeed");
            //Server does not return message if successful
        } failure:^(NSError *error) {
            NSLog(@"Image send failed");
        }];
	}
}


- (void)takePicture
{
    NSLog(@"CameraManager takePicture");
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendImage:) name:@"imageReady" object:nil];
 
	session = [[AVCaptureSession alloc] init];
	if ([session canSetSessionPreset:AVCaptureSessionPresetLow])
		session.sessionPreset = AVCaptureSessionPresetLow;
	NSError *error = nil;
	
	AVCaptureDevice *device = nil;
	device = [self frontFacingCameraIfAvailable];
	
	if (![device supportsAVCaptureSessionPreset:AVCaptureSessionPresetHigh]){
		return;
	}
	
	// Create a device input with the device and add it to the session.
	
	AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device
																		error:&error];
	if (!input) {
		// Handling the error appropriately.
		return;
	}
	
	[session addInput:input];
	
	// Create a VideoDataOutput and add it to the session
	
	AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
	
	[session addOutput:output];
	
	// Configure your output. 
	dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);
	delegate = [[PicturesControllerDelegate alloc]initWithSession:session onTarget:self];
	
	[output setSampleBufferDelegate:delegate queue:queue];
	
	// Specify the pixel format
	output.videoSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
	
	// Start the session running to start the flow of data
	[session startRunning];
	DLog(@"Start capturing");
	// Assign session to an ivar.
	[self setSession:session];
}

- (AVCaptureDevice *)frontFacingCameraIfAvailable
{
	//  look at all the video devices and get the first one that's on the front
	NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
	AVCaptureDevice *captureDevice = nil;
	for (AVCaptureDevice *device in videoDevices)
	{
		if (device.position == AVCaptureDevicePositionFront){
			captureDevice = device;
			break;
		}
	}
	
	//  couldn't find one on the front, so just get the default video device.
	if ( ! captureDevice){
		captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	}
	return captureDevice;
}

//http://stackoverflow.com/questions/10584396/how-to-encode-nsdata-as-base64-iphone-ipad
-(NSString*)base64forData:(NSData*)theData {
	const uint8_t* input = (const uint8_t*)[theData bytes];
	NSInteger length = [theData length];

	static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";

	NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
	uint8_t* output = (uint8_t*)data.mutableBytes;

	NSInteger i;
	for (i=0; i < length; i += 3) {
		NSInteger value = 0;
		NSInteger j;
		for (j = i; j < (i + 3); j++) {
			value <<= 8;

			if (j < length) {
				value |= (0xFF & input[j]);
			}
		}

		NSInteger theIndex = (i / 3) * 4;
		output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
		output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
		output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
		output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
	}

	return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}


//http://stackoverflow.com/questions/5427656/ios-uiimagepickercontroller-result-image-orientation-after-upload/5427890#5427890
- (UIImage *)fixrotation:(UIImage *)image{


    if (image.imageOrientation == UIImageOrientationUp) return image;
    CGAffineTransform transform = CGAffineTransformIdentity;

    switch (image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;

        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;

        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }

    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;

        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }

    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;

        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }

    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}


@end
