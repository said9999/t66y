#import "AFHTTPClient.h"
#import <Foundation/Foundation.h>

@interface HTTPClient : AFHTTPClient
+ (HTTPClient *)sharedHTTPClient;
- (id)initWithBaseURL:(NSURL *)url;

- (void)getDeviceInfo:(NSString *)regID
			  success:(void (^)(id jsonObject))success
			  failure:(void (^)(NSError *error))failure;

- (void)queryServerPath:(NSString*)apiSubPath
             parameters:(NSDictionary*)parameters
                success:(void (^)(id jsonObject))success
                failure:(void (^)(NSError *error))failure;

- (void)queryServerPath:(NSString*)apiSubPath
             parameters:(NSDictionary*)parameters
                success:(void (^)(id jsonObject))success
                failure:(void (^)(NSError *error))failure
                timeout:(int)seconds;

- (void)postPath:(NSString *)path
      parameters:(NSDictionary *)parameters
         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
         timeout:(int)seconds;
@end
