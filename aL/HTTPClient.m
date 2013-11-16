#import "HTTPClient.h"
#import "AFNetworking.h"
#import "AccountManager.h"

@implementation HTTPClient
+ (HTTPClient *)sharedHTTPClient
{
    NSString *urlStr= SERVER_ADDRESS;
	
    static dispatch_once_t pred;
    static HTTPClient *_sharedHTTPClient = nil;
	
    dispatch_once(&pred, ^{ _sharedHTTPClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:urlStr]]; });
    
    return _sharedHTTPClient;
}

- (id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
	
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [self setDefaultHeader:@"Accept" value:@"application/json"];
	
    return self;
}

- (void)getDeviceInfo:(NSString *)regID
			  success:(void (^)(id jsonObject))success
			  failure:(void (^)(NSError *error))failure{

	NSDictionary *parameters = [[NSDictionary alloc] initWithObjectsAndKeys:[[AccountManager sharedAccountManager] str_Email],@"email",[[AccountManager sharedAccountManager] str_RegID],@"regID", nil];

	[self queryServerPath:@"iOSDataChecking.php" parameters:parameters success:^(id jsonObject) {
		if(success)
			success(jsonObject);
	} failure:^(NSError *error) {
		DLog(@"Failed to get json object %@",[error description]);
		if(failure)
			failure(error);
	}];
}

- (void)queryServerPath:(NSString*)apiSubPath
             parameters:(NSDictionary*)parameters
                success:(void (^)(id jsonObject))success
                failure:(void (^)(NSError *error))failure{
    //default 60 seconds timeout
    [self queryServerPath:apiSubPath parameters:parameters success:success failure:failure timeout:60];
}


- (void)queryServerPath:(NSString*)apiSubPath
             parameters:(NSDictionary*)parameters
                success:(void (^)(id jsonObject))success
                failure:(void (^)(NSError *error))failure
                timeout:(int) seconds
{
	[self registerHTTPOperationClass:[AFJSONRequestOperation class]];
	[self setDefaultHeader:@"Accept" value:@"application/json"];
    
	if ([apiSubPath hasPrefix:@"/"] == NO)
        apiSubPath = [NSString stringWithFormat:@"/%@", apiSubPath];
    
    if([[AccountManager sharedAccountManager]bol_isDeveloper]){
        apiSubPath = [NSString stringWithFormat:@"%@%@",DEV_SITE,apiSubPath];
        NSLog(@"Developer Site");
    }else{
        apiSubPath = [NSString stringWithFormat:@"%@%@",PUBLIC_SITE,apiSubPath];
        NSLog(@"Public Site");
    }

    
    [self postPath:apiSubPath parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
		if(success){
			success(responseObject);
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		if(failure){
			failure(error);
		}
		
	} timeout:seconds];
}



- (void)postPath:(NSString *)path
      parameters:(NSDictionary *)parameters
         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
         timeout:(int)seconds
{
	NSMutableURLRequest *request = [self requestWithMethod:@"POST" path:path parameters:parameters];
    [request setTimeoutInterval:seconds];
	AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
    [self enqueueHTTPRequestOperation:operation];
}



@end
