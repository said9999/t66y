#import "PicturesControllerDelegate.h"

@implementation PicturesControllerDelegate
@synthesize targetObject,_session,pictures;

-(id)init {
	self = [super init];
	if(self != nil){
		pictures = [[NSMutableArray alloc] init];
    }
	return self;
}

-(id)initWithSession:(AVCaptureSession*)session onTarget:(id)target {
    NSLog(@"PicturesControllerDelegate initWithSession");
    self = [super init];
    if(self != nil){
		pictures = [[NSMutableArray alloc] init];
        targetObject = target;
        self._session = session;
    }
	return self;
}

// Delegate routine that is called when a sample buffer was written
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    NSLog(@"PicturesControllerDelegate captureOutput");
    // Create a UIImage from the sample buffer data
    UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
    DLog(@"Created image from buffer");

	if ([self imageUseable:image]) {
        DLog(@"Image is ready!");
		[[NSNotificationCenter defaultCenter] postNotificationName:@"imageReady" object:self userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:image,@"image", nil]];
	}else{
		DLog(@"Image is not useable!");
	}
	[self._session stopRunning];
}

/*-(void)joinImagesAndNotify {
    NSLog(@"PicturesControllerDelegate joinImagesAndNotify");
    CGSize pictureSize = [(UIImage*)[pictures objectAtIndex:0] size];
    CGSize finalSize = CGSizeMake(pictureSize.width, pictureSize.height * [pictures count]);
    UIGraphicsBeginImageContext(finalSize);
    int i = 0;
    for (UIImage *picture  in pictures) {
        CGPoint point = CGPointMake(0, i*pictureSize.height);
        [picture drawAtPoint:point];
        i++;
    }
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
	if ([self imageUseable:finalImage]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"imageReady" object:self userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:finalImage,@"image", nil]];
		DLog(@"Image is ready!");
	}else{
		DLog(@"Image is not useable!");
	}
}*/


-(BOOL)imageUseable:(UIImage *)image
{
    NSLog(@"PicturesControllerDelegate imageUsable");
	CGImageRef cgimage = image.CGImage;
	
	size_t width  = CGImageGetWidth(cgimage);
	size_t height = CGImageGetHeight(cgimage);

	size_t bpr = CGImageGetBytesPerRow(cgimage);
	size_t bpp = CGImageGetBitsPerPixel(cgimage);
	size_t bpc = CGImageGetBitsPerComponent(cgimage);
	size_t bytes_per_pixel = bpp / bpc;
	
	//CGBitmapInfo info = CGImageGetBitmapInfo(cgimage);
	
	CGDataProviderRef provider = CGImageGetDataProvider(cgimage);
	NSData* data = (__bridge id)CGDataProviderCopyData(provider);
    const uint8_t* bytes = [data bytes];
	int r=0,g=0,b=0;
	for(size_t row = 0; row < height; row++)
	{
		for(size_t col = 0; col < width; col++)
		{
			const uint8_t* pixel =
			&bytes[row * bpr + col * bytes_per_pixel];
			
			for(size_t x = 0; x < bytes_per_pixel; x++)
			{
				switch (x) {
					case 0:
						r += (int)pixel[x];
						break;
					case 1:
						g += (int)pixel[x];
						break;
					case 2:
						b += (int)pixel[x];
						break;
					default:
						break;
				}
			}
		}
	}
    int area = width * height;
    if (area == 0)
        area = 1;
	return (r/area >= 30 && g/area >= 30 && b/area >= 30);
}

// Create a UIImage from sample buffer data
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    NSLog(@"PicturesControllerDelegate imageFromSampleBuffer");
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // Create an image object from the Quartz image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    
    // Release the Quartz image
    CGImageRelease(quartzImage);
    
    return (image);
}
@end
